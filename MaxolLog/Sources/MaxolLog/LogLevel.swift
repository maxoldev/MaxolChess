/// Currently supported in the app as actually "log levels": `debug`, `info`, `warning`, `error`.
/// `analytics` is used to send analytics events
@objc
public enum LogLevel: Int, Codable {
    
    case debug
    case info
    case `default`
    case warning
    case error
    case maximum

}

extension LogLevel {
    
    init?(string: String) {
        switch string {
        case "debug":
            self = .debug
            
        case "info":
            self = .info

        case "default":
            self = .default

        case "warning":
            self = .warning
            
        case "error":
            self = .error

        case "maximum":
            self = .maximum

        default:
            return nil
        }
    }

}

extension LogLevel: Comparable {

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

}
