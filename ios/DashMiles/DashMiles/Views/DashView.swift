import UIKit
import CoreLocation
import SwiftUI

/// The only screen that matters while you are working: one big button, and
/// the miles ticking up.
struct DashView: View {
    @EnvironmentObject private var store: ShiftStore
    @AppStorage(Settings.platformKey) private var platform = Settings.defaultPlatform

    @State private var confirmEnd = false
    @State private var confirmDiscard = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    permissionBanner
                    odometer
                    mainButton
                    if store.activeShift != nil { liveDetails }
                    totals
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("DashMiles")
        }
    }

    // MARK: - Odometer

    private var odometer: some View {
        // Re-renders once a second so the clock stays honest even when no GPS
        // fix has arrived.
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let shift = store.activeShift
            VStack(spacing: 6) {
                Text(Fmt.miles(shift?.miles ?? 0, decimals: 2))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("miles this dash")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(Fmt.clock(shift?.duration(now: context.date) ?? 0))
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(shift == nil ? Color.secondary : Color.primary)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.secondarySystemGroupedBackground)))
        }
    }

    // MARK: - Start / End

    private var mainButton: some View {
        VStack(spacing: 12) {
            Button {
                if store.activeShift == nil {
                    store.startShift(platform: platform)
                } else {
                    confirmEnd = true
                }
            } label: {
                Text(store.activeShift == nil ? "Start Dash" : "End Dash")
                    .font(.title2.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.borderedProminent)
            .tint(store.activeShift == nil ? .green : .red)
            .confirmationDialog("End this dash?", isPresented: $confirmEnd, titleVisibility: .visible) {
                Button("End Dash", role: .destructive) { store.endShift() }
                Button("Keep Going", role: .cancel) {}
            } message: {
                Text("\(Fmt.miles(store.activeShift?.miles ?? 0, decimals: 2)) miles will be saved to your history.")
            }

            if store.activeShift != nil {
                Button("Discard this dash", role: .destructive) { confirmDiscard = true }
                    .font(.footnote)
                    .confirmationDialog("Discard this dash?",
                                        isPresented: $confirmDiscard,
                                        titleVisibility: .visible) {
                        Button("Discard", role: .destructive) { store.discardActiveShift() }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("The miles recorded since you started will not be saved.")
                    }
            }
        }
    }

    private var liveDetails: some View {
        HStack {
            stat("Speed", "\(Int(store.currentSpeedMPH.rounded())) mph")
            Divider()
            stat("GPS", store.gpsAccuracy > 0 ? "±\(Int(store.gpsAccuracy.rounded())) m" : "—")
            Divider()
            stat("Platform", platform)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }

    // MARK: - Totals

    private var totals: some View {
        VStack(spacing: 0) {
            row("Today", store.miles(since: Date().startOfDay()))
            Divider().padding(.leading)
            row("This week", store.miles(since: Date().startOfWeek()))
            Divider().padding(.leading)
            row("This year", store.miles(since: Date().startOfYear()))
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }

    private func row(_ title: String, _ miles: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(Fmt.miles(miles)) mi")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Permission

    @ViewBuilder
    private var permissionBanner: some View {
        switch store.authorizationStatus {
        case .notDetermined:
            banner("DashMiles needs location access to count your miles.",
                   action: "Allow") { store.requestPermission() }
        case .denied, .restricted:
            banner("Location is off for DashMiles, so miles will not be counted.",
                   action: "Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        case .authorizedWhenInUse:
            banner("Set location to \"Always\" so miles keep counting with your screen off.",
                   action: "Allow") { store.requestPermission() }
        default:
            EmptyView()
        }
    }

    private func banner(_ message: String, action: String, perform: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "location.slash.fill").foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 8) {
                Text(message).font(.footnote)
                Button(action, action: perform).font(.footnote.weight(.semibold))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.orange.opacity(0.12)))
    }
}
