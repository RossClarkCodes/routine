import Foundation

enum DayKeying {
    static func today(in timeZone: TimeZone = .current, calendar: Calendar = .current) -> String {
        dayKey(for: Date(), in: timeZone, calendar: calendar)
    }

    static func dayKey(for date: Date, in timeZone: TimeZone = .current, calendar: Calendar = .current) -> String {
        var calendar = calendar
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let normalized = calendar.date(from: components) else {
            return fallbackDayKey(for: date, timeZone: timeZone)
        }
        return formatter(in: timeZone).string(from: normalized)
    }

    private static func fallbackDayKey(for date: Date, timeZone: TimeZone) -> String {
        formatter(in: timeZone).string(from: date)
    }

    private static func formatter(in timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
