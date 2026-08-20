import Foundation

/// Keys and defaults for the handful of things stored in UserDefaults.
enum Settings {
    static let platformKey = "defaultPlatform"
    static let rateKey = "mileageRate"

    static let defaultPlatform = "DoorDash"
    /// The IRS standard mileage rate changes every year — this is only a
    /// starting value, and Settings lets you set the current one.
    static let defaultRate = 0.70
}
