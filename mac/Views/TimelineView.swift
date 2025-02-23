import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()
    @State private var topPostID: String?  // Track the ID of the first post

    var body: some View {
        NavigationView {
            HStack {
                Text("Menubar. Something will replace this.")
            }
            ScrollViewReader { scrollView in
                List(viewModel.timelineItems, id: \.id) { timelineItem in
                    Button(action: {
                        // Serialize and print JSON
                        if let jsonData = try? JSONEncoder().encode(timelineItem),
                            let jsonString = String(data: jsonData, encoding: .utf8)
                        {
                            print("TimelineItem JSON: \(jsonString)")
                        } else {
                            print("Failed to serialize TimelineItem")
                        }

                        // Open post URL in browser
                        if let uri = timelineItem.post?.uri, let url = convertAtUriToWebUrl(uri) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(alignment: .top, spacing: 10) {
                            let postAuthor = timelineItem.post?.author
                            let repostedBy = timelineItem.reason?.by

                            // Avatar
                            if let avatarUrl = postAuthor?.avatar, let url = URL(string: avatarUrl)
                            {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                // Original post author
                                if let originalAuthor = postAuthor {
                                    Text(originalAuthor.displayName ?? originalAuthor.handle)
                                        .font(.headline)
                                }

                                // Reposted by
                                if let repostedBy = repostedBy {
                                    Text(
                                        "Reposted by \(repostedBy.displayName ?? repostedBy.handle)"
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }

                                // Post content
                                if let text = timelineItem.post?.record.text, !text.isEmpty {
                                    Text(text)
                                        .font(.body)
                                        .lineLimit(4)
                                } else if let context = timelineItem.feedContext, !context.isEmpty {
                                    Text(context)
                                        .font(.body)
                                        .lineLimit(4)
                                } else {
                                    Text("No content")
                                        .font(.body)
                                }

                                // Post creation date
                                if let createdAt = timelineItem.post?.indexedAt {
                                    HStack {
                                        Text(createdAt, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(createdAt, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .id(timelineItem.id)  // Assign a unique ID for scrolling
                }
                .listStyle(PlainListStyle())
                .onChange(of: viewModel.timelineItems) { newItems in
                    if let firstItem = newItems.first {
                        topPostID = firstItem.id
                        withAnimation {
                            scrollView.scrollTo(topPostID, anchor: .top)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.columns)
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
