import Foundation
import Combine

@MainActor
class TimelineViewModel: ObservableObject {
    @Published var timelineItems: [FeedItem] = []
    @Published var cursor: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var refreshTimer: AnyCancellable?
    
    init() {
        // Load the initial timeline and set up periodic refresh.
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
    /// It updates the posts array and cursor for pagination.
    func loadTimeline() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Call our updated API client using the current cursor for pagination.
            let timelineResponse = try await BlueskyClient.shared.fetchTimeline(limit: 50, cursor: cursor)
            // Update the posts with the latest feed data.
            self.timelineItems = timelineResponse.feed
            // Save the cursor for potential pagination.
            self.cursor = timelineResponse.cursor
        } catch {
            errorMessage = "Error fetching timeline: \(error.localizedDescription)"
            print("Error fetching timeline: \(error)")
        }
        
        isLoading = false
    }
}
