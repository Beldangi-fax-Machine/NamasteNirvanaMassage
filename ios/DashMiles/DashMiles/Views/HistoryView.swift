import SwiftUI

/// Every dash you have recorded, grouped by month, with the totals a tax
/// form asks for.
struct HistoryView: View {
    @EnvironmentObject private var store: ShiftStore
    @AppStorage(Settings.rateKey) private var rate = Settings.defaultRate

    @State private var editing: Shift?
    @State private var addingPastDash = false
    @State private var export: ExportFile?

    var body: some View {
        NavigationStack {
            Group {
                if store.shifts.isEmpty {
                    ContentUnavailableView("No dashes yet",
                                           systemImage: "car",
                                           description: Text("Tap Start Dash when you go online and your miles show up here."))
                } else {
                    list
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            addingPastDash = true
                        } label: {
                            Label("Add a past dash", systemImage: "plus")
                        }
                        Button {
                            if let url = store.csvFileURL() { export = ExportFile(url: url) }
                        } label: {
                            Label("Export CSV", systemImage: "square.and.arrow.up")
                        }
                        .disabled(store.shifts.allSatisfy { $0.isActive })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $editing) { shift in
                ShiftEditView(shift: shift).environmentObject(store)
            }
            .sheet(isPresented: $addingPastDash) {
                ShiftEditView(shift: nil).environmentObject(store)
            }
            .sheet(item: $export) { file in
                ShareSheet(url: file.url)
            }
        }
    }

    private var list: some View {
        List {
            Section("This year") {
                summaryRow("Miles", "\(Fmt.miles(yearMiles)) mi")
                summaryRow("Dashes", "\(store.shiftsStarting(onOrAfter: Date().startOfYear()).count)")
                if yearEarnings > 0 {
                    summaryRow("Earnings logged", Fmt.money(yearEarnings))
                }
                summaryRow("Estimated deduction", Fmt.money(yearMiles * rate))
                    .foregroundStyle(.secondary)
            }

            ForEach(months) { month in
                Section {
                    ForEach(month.shifts) { shift in
                        Button {
                            editing = shift
                        } label: {
                            ShiftRow(shift: shift)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        for index in offsets { store.delete(month.shifts[index]) }
                    }
                } header: {
                    HStack {
                        Text(month.title)
                        Spacer()
                        Text("\(Fmt.miles(ShiftStore.totalMiles(month.shifts))) mi")
                    }
                }
            }
        }
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).monospacedDigit()
        }
    }

    private var yearMiles: Double {
        store.miles(since: Date().startOfYear())
    }

    private var yearEarnings: Double {
        ShiftStore.totalEarnings(store.shiftsStarting(onOrAfter: Date().startOfYear()))
    }

    /// Newest month first, matching the newest-first shift order.
    private var months: [MonthGroup] {
        let calendar = Calendar.current
        var order: [Date] = []
        var buckets: [Date: [Shift]] = [:]

        for shift in store.shifts {
            let key = shift.startedAt.startOfMonth(calendar)
            if buckets[key] == nil {
                buckets[key] = []
                order.append(key)
            }
            buckets[key]?.append(shift)
        }

        return order.map { key in
            MonthGroup(id: key,
                       title: key.formatted(.dateTime.month(.wide).year()),
                       shifts: buckets[key] ?? [])
        }
    }

    struct MonthGroup: Identifiable {
        let id: Date
        let title: String
        let shifts: [Shift]
    }

    struct ExportFile: Identifiable {
        let url: URL
        var id: String { url.absoluteString }
    }
}

private struct ShiftRow: View {
    let shift: Shift

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(shift.startedAt.formatted(Fmt.dayAndDate))
                        .font(.body.weight(.medium))
                    if shift.isActive {
                        Text("LIVE")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.green.opacity(0.2)))
                            .foregroundStyle(.green)
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(Fmt.miles(shift.miles)) mi")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }

    private var subtitle: String {
        let start = shift.startedAt.formatted(Fmt.time)
        guard let end = shift.endedAt else { return "\(start) — running" }
        return "\(start) – \(end.formatted(Fmt.time)) · \(Fmt.compact(shift.duration()))"
    }
}
