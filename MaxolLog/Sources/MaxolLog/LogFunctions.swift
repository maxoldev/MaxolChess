/// Print text to console only
/// - Parameters:
///     - text: Text to print
///     - category: Category of the message
///     - logLevel: Log level of the message
///     - isSecured: If `true` in release build text in Console will be replaced with placeholder when Xcode isn't connected
public func logConsole(
    _ items: Any...,
    category: LogCategory = .general,
    logLevel: LogLevel = .debug,
    isSecured: Bool = false)
{
    Log.console(items, category: category, logLevel: logLevel, isSecured: isSecured)
}

/// Print text to console marked with your custom prefix set in build scheme environment variable `MAXOL_CONSOLE_MARK`.
/// Useful for temporary debugging
public func logConsoleMarked(_ items: Any?..., category: LogCategory = .general) {
    Log.consoleMarked(items, category: category)
}

/// Print text to console. In release build text in Console will be replaced with placeholder when Xcode isn't connected.
/// Same as `logConsole(isSecured: true)`
/// Useful for printing some auth tokens, etc.
public func logConsoleSecured(_ items: Any?..., category: LogCategory = .general) {
    Log.consoleSecured(items, category: category)
}

/// Log with level: `.debug`
public func logDebug(_ items: Any?..., params: LogParameters = [:], category: LogCategory = .general) {
    Log.debug(items, params: params, category: category)
}

/// Log with level: `.info`
public func logInfo(_ items: Any?..., params: LogParameters = [:], category: LogCategory = .general) {
    Log.info(items, params: params, category: category)
}

/// Log with level: `.default`
public func log(_ items: Any?..., params: LogParameters = [:], category: LogCategory = .general) {
    Log.log(items, params: params, category: category)
}

/// Log with level: `.warning`
public func logWarning(_ items: Any?..., params: LogParameters = [:], category: LogCategory = .general) {
    Log.warning(items, params: params, category: category)
}

/// Log with level: `.error`
public func logError(_ items: Any?..., params: LogParameters = [:], category: LogCategory = .general) {
    Log.error(items, params: params, category: category)
}

/// Log with level: `.error`
public func logError(_ error: Error, params: LogParameters = [:], category: LogCategory = .general) {
    Log.error(error, params: params, category: category)
}

/// Log LogMessage
public func logMessage(_ message: LogMessage, logToConsole: Bool = true, logToServer: Bool = true, secureLogToConsole: Bool = false) {
    Log.message(message, logToConsole: logToConsole, logToServer: logToServer, secureLogToConsole: secureLogToConsole)
}

/// Log items with parameter dictionary
/// - Parameters:
///     - items: Items to log
///     - params: Dictionary with additional parameters
///     - category: Category of the message
///     - logLevel: Log level of the message
///     - logToConsole: Print to console
///     - logToServer: Send to server
///     - secureLogToConsole: If `true` in AppStore builds text in Console will be replaced with placeholder when Xcode isn't connected
public func logCustom(
    _ items: Any?...,
    params: LogParameters,
    category: LogCategory,
    logLevel: LogLevel,
    logToConsole: Bool,
    logToServer: Bool,
    secureLogToConsole: Bool)
{
    Log.wrapToLogMessageAndLog(
        items,
        params: params,
        category: category,
        logLevel: logLevel,
        logToConsole: logToConsole,
        logToServer: logToServer,
        secureLogToConsole: secureLogToConsole
    )
}
