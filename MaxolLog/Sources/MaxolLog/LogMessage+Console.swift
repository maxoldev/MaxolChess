import os

extension LogMessage {
    
    var consoleText: String {
        switch level {
        case .info:
            return parameters.isEmpty ? "ℹ️ \(title)" : "ℹ️ \(title) \(parameters)"

        case .warning:
            return parameters.isEmpty ? "⚠️ \(title)" : "⚠️ \(title) \(parameters)"

        case .error:
            return parameters.isEmpty ? "❌ \(title)" : "❌ \(title) \(parameters)"

        default:
            return parameters.isEmpty ? title : "\(title) \(parameters)"
        }
    }
    
}

extension LogLevel {
    
    var osLogType: OSLogType {
        switch self {
        case .debug:
            return .debug

        case .info:
            return .info

        case .warning:
            // There is no `warning` type in OSLog, so we use `error` instead
            return .error

        case .error:
            return .error

        default:
            return .default
        }
    }
    
}
