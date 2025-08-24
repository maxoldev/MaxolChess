import Foundation

public extension LogCategory {

    @objc nonisolated(unsafe) static let general = LogCategory(name: "General", prefix: "")
    @objc nonisolated(unsafe) static let mock = LogCategory(name: "Mock", prefix: "🕳")
    @objc nonisolated(unsafe) static let analytics = LogCategory(name: "Analytics", prefix: "📈")
    @objc nonisolated(unsafe) static let network = LogCategory(name: "Network", prefix: "📡")
    @objc nonisolated(unsafe) static let location = LogCategory(name: "Location", prefix: "🌐")
    @objc nonisolated(unsafe) static let ui = LogCategory(name: "UI", prefix: "📱")
    @objc nonisolated(unsafe) static let credential = LogCategory(name: "Credential", prefix: "👮‍♀️")
    @objc nonisolated(unsafe) static let leak = LogCategory(name: "Leak", prefix: "🚰")

    @objc nonisolated(unsafe) static let logger = LogCategory(name: "Logger", prefix: "🪵")

}
