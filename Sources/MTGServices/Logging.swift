import Foundation
import os.log

/// Protocol for logging functionality
public protocol Logger: Sendable {
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
}

/// OS Log-based logger implementation
public final class OSLogger: Logger, Sendable {
    private let logger: os.Logger
    
    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    public func debug(_ message: String) {
        logger.debug("\(message)")
    }
    
    public func info(_ message: String) {
        logger.info("\(message)")
    }
    
    public func warning(_ message: String) {
        logger.warning("\(message)")
    }
    
    public func error(_ message: String) {
        logger.error("\(message)")
    }
}

/// Console logger for development/testing
public final class ConsoleLogger: Logger, Sendable {
    public init() {}
    
    public func debug(_ message: String) {
        print("[DEBUG] \(message)")
    }
    
    public func info(_ message: String) {
        print("[INFO] \(message)")
    }
    
    public func warning(_ message: String) {
        print("[WARNING] \(message)")
    }
    
    public func error(_ message: String) {
        print("[ERROR] \(message)")
    }
}

/// Null logger that discards all messages
public final class NullLogger: Logger, Sendable {
    public init() {}
    
    public func debug(_ message: String) {}
    public func info(_ message: String) {}
    public func warning(_ message: String) {}
    public func error(_ message: String) {}
}

/// Global logger factory
public enum LoggerFactory {
    public static func createLogger(for component: String, subsystem: String = "com.mtg-mcp") -> Logger {
        // Always use OSLogger for MCP servers so logs are captured by the MCP client
        return OSLogger(subsystem: subsystem, category: component)
    }
}