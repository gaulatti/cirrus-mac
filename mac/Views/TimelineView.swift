import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()

    var body: some View {
        NavigationView {
            HStack {
                Text("Menubar. Something will replace this.")
            }
            content
                .navigationTitle("Timeline")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            Task {
                                await viewModel.loadTimeline()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("Refresh Timeline")
                    }
                }
        }
        .navigationViewStyle(.columns)
    }

    @ViewBuilder
    var content: some View {
        if viewModel.isLoading && viewModel.timelineItems.isEmpty {
            VStack {
                ProgressView("Loading Timeline...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            VStack {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                Button("Retry") {
                    Task {
                        await viewModel.loadTimeline()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
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
                        // Determine whether this is a repost or original post
                        let postAuthor = timelineItem.post?.author
                        let repostedBy = timelineItem.reason?.by

                        // Avatar - Use original author's avatar
                        if let avatarUrl = postAuthor?.avatar,
                            let url = URL(string: avatarUrl)
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
                            // Display the original post's author
                            if let originalAuthor = postAuthor {
                                Text(originalAuthor.displayName ?? originalAuthor.handle)
                                    .font(.headline)
                            }

                            // If it's a repost, mention who reposted it
                            if let repostedBy = repostedBy {
                                Text("Reposted by \(repostedBy.displayName ?? repostedBy.handle)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            // Post content or context
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
                .buttonStyle(PlainButtonStyle())  // Removes button styling
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
