import Foundation

enum Fmt {
    static func miles(_ value: Double, decimals: Int = 1) -> String {
        String(format: "%.\(decimals)f", value)
    }

    /// 1:04:09 while a dash is running.
    static func clock(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }

    /// 3h 12m in lists and totals.
    static func compact(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let h = total / 3600, m = (total % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    static func money(_ value: Double) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    static let dayAndDate: Date.FormatStyle = .dateTime.weekday(.abbreviated).month(.abbreviated).day()
    static let time: Date.FormatStyle = .dateTime.hour().minute()
}

extension Date {
    func startOfDay(_ cal: Calendar = .current) -> Date { cal.startOfDay(for: self) }

    func startOfWeek(_ cal: Calendar = .current) -> Date {
        cal.dateInterval(of: .weekOfYear, for: self)?.start ?? startOfDay(cal)
    }

    func startOfMonth(_ cal: Calendar = .current) -> Date {
        cal.dateInterval(of: .month, for: self)?.start ?? startOfDay(cal)
    }

    func startOfYear(_ cal: Calendar = .current) -> Date {
        cal.dateInterval(of: .year, for: self)?.start ?? startOfDay(cal)
    }
}
