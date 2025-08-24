import os
import Foundation

private let osLogSubsystem = "maxol"

public typealias LogParameters = [String: Any?]

private enum ConsoleLogPreferences {

    nonisolated(unsafe) fileprivate static let minLogLevel = LogLevel(string: MaxolLoggingProcessInfo.consoleMinLogLevel) ?? .debug

    private static let disabledLogCategoryHashes = Set<Int>(
        MaxolLoggingProcessInfo.consoleDisabledLogCategories.lowercased().split(separator: ",").map { String($0).hashValue }
    )

    fileprivate static func shouldLog(category: LogCategory) -> Bool {
        return !disabledLogCategoryHashes.contains(category.lowercasedNameHash)
    }

    fileprivate static let mark = MaxolLoggingProcessInfo.consoleMark ?? "🔥🔥🔥"

}

/// Class methods to use from global functions.
/// Use primary global functions (`log`, `logDebug`, `logError`, etc.) from your Swift code
@objc
public final class Log: NSObject {

    static func console(
        _ items: [Any?],
        category: LogCategory = .general,
        logLevel: LogLevel = .debug,
        isSecured: Bool = false)
    {
        guard logLevel >= ConsoleLogPreferences.minLogLevel,
            ConsoleLogPreferences.shouldLog(category: category)
        else {
            return
        }

        let categoryConsoleTitle = category.consoleTitle
        let osLogType = logLevel.osLogType
        let formatString: StaticString = isSecured ? "%{private}@" : "%{public}@"
        os_log(formatString, log: OSLog(subsystem: osLogSubsystem, category: categoryConsoleTitle), type: osLogType, items.toString())
    }

    static func consoleMarked(_ items: [Any?], category: LogCategory = .general) {
        console([ConsoleLogPreferences.mark] + items, category: category, logLevel: .maximum, isSecured: false)
    }

    static func consoleSecured(_ items: [Any?], category: LogCategory = .general) {
        console(items, category: category, logLevel: .debug, isSecured: true)
    }

    static func debug(_ items: [Any?], params: LogParameters = [:], category: LogCategory = .general) {
        wrapToLogMessageAndLog(
            items,
            params: params,
            category: category,
            logLevel: .debug,
            logToConsole: true,
            logToServer: true,
            secureLogToConsole: false
        )
    }

    static func info(_ items: [Any?], params: LogParameters = [:], category: LogCategory = .general) {
        wrapToLogMessageAndLog(
            items,
            params: params,
            category: category,
            logLevel: .info,
            logToConsole: true,
            logToServer: true,
            secureLogToConsole: false
        )
    }

    static func log(_ items: [Any?], params: LogParameters = [:], category: LogCategory = .general) {
        wrapToLogMessageAndLog(
            items,
            params: params,
            category: category,
            logLevel: .default,
            logToConsole: true,
            logToServer: true,
            secureLogToConsole: false
        )
    }

    static func warning(_ items: [Any?], params: LogParameters = [:], category: LogCategory = .general) {
        wrapToLogMessageAndLog(
            items,
            params: params,
            category: category,
            logLevel: .warning,
            logToConsole: true,
            logToServer: true,
            secureLogToConsole: false
        )
    }

    static func error(_ items: [Any?], params: LogParameters = [:], category: LogCategory = .general) {
        wrapToLogMessageAndLog(
            items,
            params: params,
            category: category,
            logLevel: .error,
            logToConsole: true,
            logToServer: true,
            secureLogToConsole: false
        )
    }

    static func error(_ error: Error, params: LogParameters = [:], category: LogCategory = .general) {
        let title = "\(error.localizedDescription) <\(error)>"
        let message = LogMessageImpl(title: title, parameters: params, category: category, level: .error)
        self.message(message, logToConsole: true, logToServer: true, secureLogToConsole: false)
    }

    static func wrapToLogMessageAndLog(
        _ items: [Any?],
        params: LogParameters,
        category: LogCategory,
        logLevel: LogLevel,
        logToConsole: Bool,
        logToServer: Bool,
        secureLogToConsole: Bool)
    {
        let message = LogMessageImpl(title: items.toString(), parameters: params, category: category, level: logLevel)
        self.message(message, logToConsole: logToConsole, logToServer: logToServer, secureLogToConsole: secureLogToConsole)
    }

    static func message(
        _ message: LogMessage,
        logToConsole: Bool = true,
        logToServer: Bool = true,
        secureLogToConsole: Bool = false)
    {
        if logToConsole {
            console([message.consoleText], category: message.category, logLevel: message.level, isSecured: secureLogToConsole)
        }
        if logToServer {
            send(logMessage: message)
        }
    }

    static func send(logMessage: LogMessage) {
        guard isSendingEnabled else { return }

        console("Sending log to server not implemented", category: .logger, logLevel: .error, isSecured: false)
    }
    
    // MARK: - Public
    nonisolated(unsafe) public static var isSendingEnabled = false

}

private extension Array where Element == Any? {

    func toString() -> String {
        let str = (map { "\($0.map { $0 } ?? "nil")" }).joined(separator: " ")
        return str
    }

}
