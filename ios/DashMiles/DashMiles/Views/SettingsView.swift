import UIKit
import CoreLocation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ShiftStore
    @AppStorage(Settings.rateKey) private var rate = Settings.defaultRate
    @AppStorage(Settings.platformKey) private var platform = Settings.defaultPlatform

    @State private var export: HistoryView.ExportFile?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Rate per mile")
                        Spacer()
                        TextField("0.70", value: $rate, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 100)
                    }
                    TextField("Default platform", text: $platform)
                } header: {
                    Text("Mileage")
                } footer: {
                    Text("The IRS publishes a new standard mileage rate each year. Check the current one and set it here — the app only uses it to estimate your deduction.")
                }

                Section("Location") {
                    LabeledContent("Permission", value: permissionText)
                    if store.authorizationStatus != .authorizedAlways {
                        Button("Open iOS Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    if !store.canTrackInBackground {
                        Label("Background location is not enabled in this build, so miles stop counting when you leave the app.",
                              systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }

                Section("Your data") {
                    LabeledContent("Dashes recorded", value: "\(store.shifts.count)")
                    LabeledContent("Total miles", value: Fmt.miles(ShiftStore.totalMiles(store.shifts)))
                    Button {
                        if let url = store.csvFileURL() { export = HistoryView.ExportFile(url: url) }
                    } label: {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                    }
                }

                Section {
                    Text("DashMiles keeps everything on your phone. Nothing is uploaded anywhere.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("Estimates only — this app is not tax advice.")
                }
            }
            .navigationTitle("Settings")
            .sheet(item: $export) { file in
                ShareSheet(url: file.url)
            }
        }
    }

    private var permissionText: String {
        switch store.authorizationStatus {
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "While Using"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not asked yet"
        @unknown default: return "Unknown"
        }
    }
}
