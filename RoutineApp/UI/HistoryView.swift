import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: [SortDescriptor(\DailyEntry.createdAt, order: .reverse)]) private var entries: [DailyEntry]

    var body: some View {
        List(entries) { entry in
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.dayKey)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.intent.isEmpty ? "No intent" : entry.intent)
                    .font(.body)
            }
        }
        .navigationTitle("History")
    }
}
