import Foundation

/// One dash: the clock starts when you tap Start Dash and stops when you tap
/// End Dash. Everything between those two taps is one deductible trip.
struct Shift: Identifiable, Codable, Equatable {
    var id: UUID
    var startedAt: Date
    var endedAt: Date?
    /// Distance is stored in meters (what CoreLocation gives us) and converted
    /// for display, so rounding never accumulates into the saved number.
    var meters: Double
    var platform: String
    var note: String
    var earnings: Double?

    init(id: UUID = UUID(),
         startedAt: Date,
         endedAt: Date? = nil,
         meters: Double = 0,
         platform: String = "DoorDash",
         note: String = "",
         earnings: Double? = nil) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.meters = meters
        self.platform = platform
        self.note = note
        self.earnings = earnings
    }

    static let metersPerMile = 1609.344

    var isActive: Bool { endedAt == nil }

    var miles: Double {
        get { meters / Shift.metersPerMile }
        set { meters = max(0, newValue) * Shift.metersPerMile }
    }

    /// For a finished shift this is fixed; for a live one it grows with `now`.
    func duration(now: Date = Date()) -> TimeInterval {
        max(0, (endedAt ?? now).timeIntervalSince(startedAt))
    }

    /// Decoding tolerates older/partial files so an app update never wipes history.
    enum CodingKeys: String, CodingKey {
        case id, startedAt, endedAt, meters, platform, note, earnings
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        startedAt = try c.decode(Date.self, forKey: .startedAt)
        endedAt = try? c.decode(Date.self, forKey: .endedAt)
        meters = (try? c.decode(Double.self, forKey: .meters)) ?? 0
        platform = (try? c.decode(String.self, forKey: .platform)) ?? "DoorDash"
        note = (try? c.decode(String.self, forKey: .note)) ?? ""
        earnings = try? c.decode(Double.self, forKey: .earnings)
    }
}
