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
        }.navigationViewStyle(.columns)
    }
    
    // Use a @ViewBuilder to conditionally build the content.
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
                VStack(alignment: .leading, spacing: 6) {
                    // Display the actor’s display name (or fallback to handle) from reason.by.
                    if let actor = timelineItem.reason?.by {
                        Text(actor.displayName ?? actor.handle)
                            .font(.headline)
                    }
                    
                    // Display the post text from the post record if available,
                    // otherwise use feedContext if that exists.
                    if let text = timelineItem.post?.record.text, !text.isEmpty {
                        Text(text)
                            .font(.body)
                    } else if let context = timelineItem.feedContext, !context.isEmpty {
                        Text(context)
                            .font(.body)
                    } else {
                        Text("No content")
                            .font(.body)
                    }
                    
                    // Display the creation date from reason.createdAt.
                    if let createdAt = timelineItem.reason?.createdAt {
                        Text(createdAt, style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)

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
