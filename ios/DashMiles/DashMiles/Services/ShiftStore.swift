import Combine
import CoreLocation
import Foundation

/// Owns the shift list, the JSON file it lives in, and the GPS tracker.
/// Everything here runs on the main thread: SwiftUI calls in on main, and
/// CoreLocation delivers its callbacks on the thread the manager was created
/// on, which is also main.
final class ShiftStore: ObservableObject {

    @Published private(set) var shifts: [Shift] = []      // newest first
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var gpsAccuracy: Double = -1
    @Published private(set) var currentSpeedMPH: Double = 0

    private let tracker = LocationTracker()
    private let fileURL: URL
    private var lastWrite = Date.distantPast

    var activeShift: Shift? { shifts.first(where: { $0.isActive }) }
    var canTrackInBackground: Bool { tracker.canTrackInBackground }

    init(fileURL: URL? = nil) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = fileURL ?? documents.appendingPathComponent("shifts.json")

        load()

        tracker.onDistance = { [weak self] meters in self?.addDistance(meters) }
        tracker.onStatusChange = { [weak self] status in self?.authorizationStatus = status }
        tracker.onSample = { [weak self] accuracy, speed in
            self?.gpsAccuracy = accuracy
            self?.currentSpeedMPH = speed
        }
        authorizationStatus = tracker.authorizationStatus

        // The app was killed mid-dash (or iOS relaunched it). Pick the shift
        // back up instead of silently leaving it stopped.
        if activeShift != nil { tracker.start() }
    }

    // MARK: - Running a dash

    func requestPermission() { tracker.requestPermission() }

    func startShift(platform: String) {
        guard activeShift == nil else { return }
        shifts.insert(Shift(startedAt: Date(), platform: platform), at: 0)
        tracker.start()
        save(force: true)
    }

    func endShift() {
        guard let index = shifts.firstIndex(where: { $0.isActive }) else { return }
        tracker.stop()
        shifts[index].endedAt = Date()
        currentSpeedMPH = 0
        sort()
        save(force: true)
    }

    /// Throw away a dash you started by mistake.
    func discardActiveShift() {
        tracker.stop()
        shifts.removeAll { $0.isActive }
        currentSpeedMPH = 0
        save(force: true)
    }

    private func addDistance(_ meters: Double) {
        guard meters > 0, let index = shifts.firstIndex(where: { $0.isActive }) else { return }
        shifts[index].meters += meters
        save()
    }

    // MARK: - Editing

    func add(_ shift: Shift) {
        shifts.append(shift)
        sort()
        save(force: true)
    }

    func update(_ shift: Shift) {
        guard let index = shifts.firstIndex(where: { $0.id == shift.id }) else { return }
        shifts[index] = shift
        sort()
        save(force: true)
    }

    func delete(_ shift: Shift) {
        if shift.isActive { tracker.stop() }
        shifts.removeAll { $0.id == shift.id }
        save(force: true)
    }

    // MARK: - Totals

    func shiftsStarting(onOrAfter start: Date) -> [Shift] {
        shifts.filter { $0.startedAt >= start }
    }

    func miles(since start: Date) -> Double {
        Self.totalMiles(shiftsStarting(onOrAfter: start))
    }

    static func totalMiles(_ list: [Shift]) -> Double {
        list.reduce(0) { $0 + $1.miles }
    }

    static func totalEarnings(_ list: [Shift]) -> Double {
        list.reduce(0) { $0 + ($1.earnings ?? 0) }
    }

    // MARK: - Persistence

    /// Distance updates land every few seconds while driving, so writes are
    /// throttled. `force` is for anything the user would be upset to lose.
    private func save(force: Bool = false) {
        guard force || Date().timeIntervalSince(lastWrite) > 10 else { return }
        lastWrite = Date()
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(shifts)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("DashMiles: could not save shifts — \(error)")
        }
    }

    /// Called when the app goes to the background so an in-progress dash is
    /// on disk even if iOS terminates us.
    func flush() { save(force: true) }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([Shift].self, from: data) {
            shifts = decoded
            sort()
        }
    }

    private func sort() {
        shifts.sort { $0.startedAt > $1.startedAt }
    }

    // MARK: - Export

    func csv() -> String {
        var rows = ["Date,Start,End,Duration,Miles,Platform,Earnings,Note"]
        let day = Date.FormatStyle.dateTime.year().month(.twoDigits).day(.twoDigits)
        let time = Date.FormatStyle.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)

        for shift in shifts.reversed() where !shift.isActive {
            let fields = [
                shift.startedAt.formatted(day),
                shift.startedAt.formatted(time),
                (shift.endedAt ?? shift.startedAt).formatted(time),
                Fmt.compact(shift.duration()),
                Fmt.miles(shift.miles, decimals: 2),
                shift.platform,
                shift.earnings.map { String(format: "%.2f", $0) } ?? "",
                shift.note
            ]
            rows.append(fields.map(Self.escape).joined(separator: ","))
        }
        return rows.joined(separator: "\n") + "\n"
    }

    private static func escape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    /// Writes the CSV to a temp file so it can be shared into Mail, Files,
    /// or a spreadsheet app.
    func csvFileURL() -> URL? {
        let name = "DashMiles-\(Date().formatted(.dateTime.year().month(.twoDigits).day(.twoDigits))).csv"
            .replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try csv().data(using: .utf8)?.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
