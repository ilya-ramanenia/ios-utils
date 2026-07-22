import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.myapp"

    static let network = Logger(subsystem: subsystem, category: "Network")
    static let subsystem2 = Logger(subsystem: subsystem, category: "Subsystem 2")
}
