import SwiftUI

/// Fix up a dash after the fact, or type in one you forgot to track — GPS
/// occasionally drops out, and a tax log with a hole in it is worse than one
/// with an honest manual entry.
struct ShiftEditView: View {
    @EnvironmentObject private var store: ShiftStore
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Shift
    @State private var earningsText: String
    @State private var endedAt: Date
    @State private var confirmDelete = false
    private let isNew: Bool

    init(shift: Shift?) {
        let base = shift ?? Shift(startedAt: Date().addingTimeInterval(-3600),
                                  endedAt: Date(),
                                  platform: UserDefaults.standard.string(forKey: Settings.platformKey)
                                      ?? Settings.defaultPlatform)
        _draft = State(initialValue: base)
        _earningsText = State(initialValue: base.earnings.map { String(format: "%.2f", $0) } ?? "")
        _endedAt = State(initialValue: base.endedAt ?? Date())
        isNew = shift == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("When") {
                    DatePicker("Started", selection: $draft.startedAt)
                        .disabled(draft.isActive)
                    if draft.isActive {
                        LabeledContent("Ended", value: "Still running")
                    } else {
                        DatePicker("Ended", selection: $endedAt, in: draft.startedAt...)
                    }
                }

                Section("Miles") {
                    if draft.isActive {
                        LabeledContent("Miles", value: "\(Fmt.miles(draft.miles, decimals: 2)) — recording")
                    } else {
                        HStack {
                            TextField("0.0", value: $draft.miles, format: .number)
                                .keyboardType(.decimalPad)
                            Text("mi").foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Details") {
                    TextField("Platform", text: $draft.platform)
                    HStack {
                        Text("Earnings")
                        Spacer()
                        TextField("Optional", text: $earningsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 120)
                    }
                    TextField("Note", text: $draft.note, axis: .vertical)
                        .lineLimit(1...4)
                }

                if !isNew {
                    Section {
                        Button("Delete this dash", role: .destructive) { confirmDelete = true }
                    }
                }
            }
            .navigationTitle(isNew ? "Add Dash" : "Edit Dash")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .confirmationDialog("Delete this dash?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    store.delete(draft)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func save() {
        var shift = draft
        if !shift.isActive {
            shift.endedAt = max(endedAt, shift.startedAt)
        }
        shift.platform = shift.platform.trimmingCharacters(in: .whitespaces).isEmpty
            ? Settings.defaultPlatform
            : shift.platform
        shift.earnings = Double(earningsText.replacingOccurrences(of: ",", with: "."))

        if isNew {
            store.add(shift)
        } else {
            store.update(shift)
        }
        dismiss()
    }
}
