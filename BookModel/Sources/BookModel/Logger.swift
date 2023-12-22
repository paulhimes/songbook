import Foundation
import OSLog

extension Logger {
    /// Build a `Logger` which uses the app name version and build number as the subsystem and the
    /// current module, filename, and line number as the category. Use this to build a new `Logger`
    /// for each log message, so each message is correctly attributed to the current file and line
    /// number.
    /// - Parameters:
    ///   - fileID: The fileID of the current file.
    ///   - lineNumber: The line number where this `Logger` was created.
    /// - Returns: A `Logger`.
    static func auto(
        fileID: String = #fileID,
        lineNumber: Int = #line
    ) -> Logger {
        let appName = Bundle.main.bundleIdentifier!
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let subsystem = "\(appName) \(version) (\(build))"
        let category = "\(fileID):\(lineNumber)"
        return Logger(
            subsystem: subsystem,
            category: category
        )
    }
}
