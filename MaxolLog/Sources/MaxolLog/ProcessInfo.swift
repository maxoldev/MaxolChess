import Foundation

public final class MaxolLoggingProcessInfo: NSObject {

    public static let consoleMinLogLevel = ProcessInfo.processInfo.environment["MAXOL_CONSOLE_MIN_LOG_LEVEL"] ?? ""
    public static let consoleDisabledLogCategories = ProcessInfo.processInfo.environment["MAXOL_CONSOLE_DISABLED_LOG_CATEGORIES"] ?? ""
    public static let consoleMark = ProcessInfo.processInfo.environment["MAXOL_CONSOLE_MARK"]

}
