// OPTION 1: UNIVERSAL LOGGER FACTORY
// Best for: Multi-module projects, Swift Packages (SPM), or scalable apps.
// Why it's great: It eliminates duplicate extension files across different targets. 
// It automatically falls back to the App Bundle ID for simple targets, but allows 
// explicit subsystem overrides for isolated architectural frameworks.
import OSLog

extension Logger {
    nonisolated static func make(category: String, subsystem: String? = nil) -> Logger {
        let fallbackSubsystem = MainActor.assumeIsolated { Bundle.main.bundleIdentifier ?? "com.app.default" }
        return Logger(subsystem: subsystem ?? fallbackSubsystem, category: category)
    }
}
class ExampleUsage {
    init() {
        // 1. Inside a monolithic app or simple feature target:
        let logger = Logger.make(category: "Network")
        
        // 2. Inside a strictly isolated Swift Package Manager (SPM) module:
        let logger = Logger.make(category: "HTTPClient", subsystem: "com.app.NetworkModule")
    }
}


// OPTION 2: STATIC CONTEXT LOGGER
// Best for: Small projects or rapid prototyping.
// Why it's great: Zero boilerplate inside your business logic services. 
// No need to initialize anything locally; just type the static property.
import OSLog

extension Logger {
    private static var currentSubsystem: String {
        return MainActor.assumeIsolated { Bundle.main.bundleIdentifier ?? "com.app.default" }
    }

    static let network = Logger(subsystem: currentSubsystem, category: "Network")
    static let auth = Logger(subsystem: currentSubsystem, category: "Authorization")
}
class ExampleUsage {
    init() {
        Logger.network.error("Network request timed out")
        Logger.auth.fault("User session refresh failed completely")
    }
}
