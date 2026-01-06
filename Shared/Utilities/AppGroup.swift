import Foundation

enum AppGroup {
    static let identifier = "group.com.rossclark.routine"

    static var containerURL: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        return url
    }
}
