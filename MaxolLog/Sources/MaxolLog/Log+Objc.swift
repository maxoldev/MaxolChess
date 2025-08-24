import Foundation

/// Class methods to use from ObjC code.
/// Use primary global functions (`log`, `logDebug`, `logError`, etc.) from your Swift code
extension Log {

    @objc
    public static func console(_ text: String, category: LogCategory?, logLevel: LogLevel, isSecured: Bool) {
        console([text], category: category ?? .general, logLevel: logLevel, isSecured: isSecured)
    }

    @objc
    public static func consoleMarked(_ text: String, category: LogCategory?) {
        consoleMarked([text], category: category ?? .general)
    }

    @objc
    public static func consoleSecured(_ text: String, category: LogCategory?) {
        consoleSecured([text], category: category ?? .general)
    }

    @objc
    public static func console(_ text: String, category: LogCategory?) {
        console([text], category: category ?? .general, isSecured: false)
    }

    @objc
    public static func debug(_ text: String, params: [String: Any], category: LogCategory?) {
        debug([text], params: params, category: category ?? .general)
    }

    @objc
    public static func debug(_ text: String, category: LogCategory?) {
        debug([text], params: [:], category: category ?? .general)
    }

    @objc
    public static func info(_ text: String, params: [String: Any], category: LogCategory?) {
        info([text], params: params, category: category ?? .general)
    }

    @objc
    public static func info(_ text: String, category: LogCategory?) {
        info([text], params: [:], category: category ?? .general)
    }

    @objc
    public static func log(_ text: String, params: [String: Any], category: LogCategory?) {
        log([text], params: params, category: category ?? .general)
    }

    @objc
    public static func log(_ text: String, category: LogCategory?) {
        log([text], params: [:], category: category ?? .general)
    }

    @objc
    public static func warning(_ text: String, params: [String: Any], category: LogCategory?) {
        warning([text], params: params, category: category ?? .general)
    }

    @objc
    public static func warning(_ text: String, category: LogCategory?) {
        warning([text], params: [:], category: category ?? .general)
    }

    @objc
    public static func error(_ text: String, params: [String: Any], category: LogCategory?) {
        error([text], params: params, category: category ?? .general)
    }

    @objc
    public static func error(_ text: String, category: LogCategory?) {
        error([text], params: [:], category: category ?? .general)
    }

    @objc(errorInstance:category:)
    public static func error(_ error: Error, category: LogCategory?) {
        self.error(error, params: [:], category: category ?? .general)
    }

}
