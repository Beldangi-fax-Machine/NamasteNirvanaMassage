import CoreLocation
import Foundation

/// Turns GPS fixes into meters driven.
///
/// The filtering here matters more than anything else in the app: raw GPS
/// wanders several meters while you sit at a red light, and if you add up
/// every wobble a two hour dash reports miles you never drove — which is
/// exactly the number the IRS would care about.
final class LocationTracker: NSObject, CLLocationManagerDelegate {

    /// Meters driven since the last accepted fix.
    var onDistance: ((Double) -> Void)?
    var onStatusChange: ((CLAuthorizationStatus) -> Void)?
    /// (horizontal accuracy in meters, current speed in mph)
    var onSample: ((Double, Double) -> Void)?

    private let manager = CLLocationManager()
    /// Last fix we counted from. Kept (not replaced) when the phone barely
    /// moves, so creeping through traffic still adds up instead of being
    /// thrown away one meter at a time.
    private var anchor: CLLocation?
    private(set) var isTracking = false

    var authorizationStatus: CLAuthorizationStatus { manager.authorizationStatus }

    /// True only if the Background Modes → Location updates capability is
    /// actually in the built Info.plist. Setting
    /// `allowsBackgroundLocationUpdates` without it crashes the app, so every
    /// use of it is gated on this.
    var canTrackInBackground: Bool {
        let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String]
        return modes?.contains("location") ?? false
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        manager.activityType = .automotiveNavigation
        manager.pausesLocationUpdatesAutomatically = false
    }

    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // Upgrading to Always is what keeps counting with the screen off.
            manager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    func start() {
        guard !isTracking else { return }
        isTracking = true
        anchor = nil
        requestPermission()
        applyBackgroundMode()
        manager.startUpdatingLocation()
    }

    func stop() {
        guard isTracking else { return }
        isTracking = false
        anchor = nil
        manager.stopUpdatingLocation()
        if canTrackInBackground {
            manager.allowsBackgroundLocationUpdates = false
        }
    }

    private func applyBackgroundMode() {
        guard canTrackInBackground else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.allowsBackgroundLocationUpdates = true
            manager.showsBackgroundLocationIndicator = true
        default:
            break
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onStatusChange?(manager.authorizationStatus)
        if isTracking {
            // Permission may have been granted after the dash started.
            applyBackgroundMode()
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }

        for location in locations {
            // Garbage fixes: unknown accuracy, a wide "somewhere in this
            // neighborhood" fix, or a stale cached one from before the dash.
            guard location.horizontalAccuracy > 0,
                  location.horizontalAccuracy <= 50,
                  abs(location.timestamp.timeIntervalSinceNow) < 15 else { continue }

            let speedMPH = location.speed >= 0 ? location.speed * 2.2369362920544 : 0
            onSample?(location.horizontalAccuracy, speedMPH)

            guard let last = anchor else {
                anchor = location
                continue
            }

            let meters = location.distance(from: last)
            let seconds = location.timestamp.timeIntervalSince(last.timestamp)
            guard seconds > 0 else { continue }

            // Below the noise floor of the two fixes it is drift, not driving.
            // Keep the old anchor so slow movement accumulates across fixes.
            let noiseFloor = max(10, (location.horizontalAccuracy + last.horizontalAccuracy) / 2)
            if meters < noiseFloor { continue }

            // ~140 mph: a GPS jump (tunnel, parking garage), not a delivery.
            if meters / seconds > 62 {
                anchor = location
                continue
            }

            anchor = location
            onDistance?(meters)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Transient failures are normal (no signal in a garage). Keep the
        // anchor and wait for the next usable fix.
    }
}
