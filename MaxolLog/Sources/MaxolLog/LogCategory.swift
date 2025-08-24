import Foundation

public final class LogCategory: NSObject {

    /// Please use unique name when add a new category
    public let name: String
    /// Prefix for printing in console
    public let prefix: String

    /// Hash to perform checks if the category is included in some lists
    public private(set) lazy var lowercasedNameHash = name.lowercased().hashValue
    
    public init(name: String, prefix: String = "") {
        self.name = name
        self.prefix = prefix
    }

    public override var description: String {
        consoleTitle
    }

}

extension LogCategory {
    
    var consoleTitle: String {
        prefix + name
    }
    
}
