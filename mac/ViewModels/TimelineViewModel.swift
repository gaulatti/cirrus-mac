import AppKit
import Combine
import Foundation
import UserNotifications

@MainActor
class TimelineViewModel: ObservableObject {
    @Published var timelineItems: [FeedItem] = []
    @Published var cursor: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var refreshTimer: AnyCancellable?

    init() {
        requestNotificationPermission()

        // Load initial timeline and set up auto-refresh
        Task {
            await loadTimeline()
        }

        refreshTimer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.loadTimeline()
                }
            }
    }

    /// Loads the timeline by calling the BlueskyAPIClient.
    /// Appends new posts in correct order, avoids duplicates, and triggers notifications.
    func loadTimeline() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let timelineResponse = try await BlueskyClient.shared.fetchTimeline(
                limit: 50, cursor: cursor)
            let newItems = timelineResponse.feed

            // Avoid duplicate posts
            let existingPostURIs = Set(timelineItems.map { $0.post?.uri ?? "" })
            let filteredItems = newItems.filter { !existingPostURIs.contains($0.post?.uri ?? "") }

            DispatchQueue.main.async {
                if !filteredItems.isEmpty {
                    self.showNewPostNotification(for: filteredItems)  // 🔔 Notify new posts
                }
                self.timelineItems.insert(contentsOf: filteredItems, at: 0)  // Insert at top
                self.cursor = timelineResponse.cursor
            }
        } catch {
            errorMessage = "Error fetching timeline: \(error.localizedDescription)"
            print("Error fetching timeline: \(error)")
        }

        isLoading = false
    }

    /// Requests notification permission from the user
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }

    /// Displays a system notification when new posts arrive
    private func showNewPostNotification(for newPosts: [FeedItem]) {
        // Request notification permissions if not granted
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
                return
            }

            if granted {
                DispatchQueue.main.async {
                    for post in newPosts {
                        guard let postText = post.post?.record.text, !postText.isEmpty else {
                            continue
                        }

                        let content = UNMutableNotificationContent()
                        content.title =
                            post.post?.author.displayName ?? post.post?.author.handle ?? "New Post"
                        content.body = postText.prefix(200) + (postText.count > 200 ? "..." : "")  // Limit text length
                        content.sound = .default

                        let request = UNNotificationRequest(
                            identifier: UUID().uuidString,
                            content: content,
                            trigger: nil
                        )

                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                print("Failed to send notification: \(error.localizedDescription)")
                            } else {
                                print("🔔 Notification sent for post: \(content.body)")
                            }
                        }
                    }
                }
            } else {
                print("User denied notifications.")
            }
        }
    }
}
