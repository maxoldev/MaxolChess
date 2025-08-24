public protocol LogMessage {
    
    var category: LogCategory { get }
    var level: LogLevel { get }
    var title: String { get }
    var parameters: [String: Any?] { get }
    
}

public struct LogMessageImpl: LogMessage {

    public let category: LogCategory
    public let level: LogLevel
    public let title: String
    public let parameters: [String: Any?]

    public init(
        title: String,
        parameters: [String: Any?]? = nil,
        category: LogCategory = .general,
        level: LogLevel = .info)
{
        self.title = title
        self.parameters = parameters ?? [:]
        self.category = category
        self.level = level
    }

}
