import Foundation
import SwiftGzip

/// Manages loading and accessing compressed MTG rules data
public class RulesData {
    // Singleton instance
    public nonisolated(unsafe) static let shared = RulesData()
    
    // Cache of loaded rules
    private nonisolated(unsafe) static var DATA: ComprehensiveRules?
    
    // Rules in this instance
    public var rules: ComprehensiveRules?
    
    // Private initializer for singleton
    private init() {}
    
    // Create a new instance (for compatibility)
    public static func newRulesData() -> RulesData {
        return RulesData()
    }
    
    // Find a rule by number (e.g., "100", "601.2a")
    public func findRule(by ruleNumber: String) -> RuleEntry? {
        guard let rules = rules else {
            print("⚠️ Rules not loaded, call load() first")
            return nil
        }
        return rules.findRule(by: ruleNumber)
    }
    
    // Find all rules in a section (e.g., "100" for all 100-series rules)
    public func findRules(inSection section: String) -> [RuleEntry] {
        guard let rules = rules else {
            print("⚠️ Rules not loaded, call load() first")
            return []
        }
        return rules.findRules(inSection: section)
    }
    
    // Search rules by keywords
    public func searchRules(containing keywords: [String]) -> [RuleEntry] {
        guard let rules = rules else {
            print("⚠️ Rules not loaded, call load() first")
            return []
        }
        return rules.searchRules(containing: keywords)
    }
    
    // Load rules data from compressed file
    public func load() async throws {
        // If already loaded, return
        if rules != nil {
            print("Rules data already loaded in this instance")
            return
        }
        
        // If data is cached, use it
        if let cachedData = RulesData.DATA {
            print("Using cached rules data")
            rules = cachedData
            return
        }
        
        print("Starting to load rules database...")
        
        // Try to load from main bundle
        guard let fileURL = Bundle.module.url(forResource: "all_rules", withExtension: "mtgdata") else {
            print("❌ Rules database file not found, trying fallback...")
            throw RulesDataError.fileNotFound
        }
        
        print("Rules database file found, reading data...")
        
        // Read the compressed data
        let compressedData: Data
        do {
            compressedData = try Data(contentsOf: fileURL)
            print("Read \(compressedData.count) bytes of compressed rules data")
        } catch {
            print("❌ Failed to read rules database file: \(error.localizedDescription)")
            throw error
        }
        
        print("Decompressing rules database...")
        
        // Decompress the data
        let decompressedData: Data
        do {
            guard let data = try? await decompress(data: compressedData) else {
                print("❌ Failed to decompress rules database")
                throw RulesDataError.decompressionFailed
            }
            decompressedData = data
            print("Decompressed to \(decompressedData.count) bytes")
        } catch {
            print("❌ Error during decompression: \(error.localizedDescription)")
            throw error
        }
        
        print("Decoding rules database...")
        
        // Decode the data
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let startTime = Date()
            let comprehensiveRules = try decoder.decode(ComprehensiveRules.self, from: decompressedData)
            let elapsed = Date().timeIntervalSince(startTime)
            rules = comprehensiveRules
            RulesData.DATA = comprehensiveRules
            print("✅ Total rules loaded: \(comprehensiveRules.totalRules) in \(String(format: "%.2f", elapsed)) seconds")
        } catch {
            print("❌ Failed to decode rules database: \(error.localizedDescription)")
            throw RulesDataError.decodingFailed(error)
        }
    }
    
    // Helper function to decompress data using SwiftGzip
    private func decompress(data: Data) async throws -> Data? {
        let decompressor = GzipDecompressor()
        return try await decompressor.unzip(data: data)
    }
}

// MARK: - Error Types

public enum RulesDataError: Error, LocalizedError {
    case fileNotFound
    case decompressionFailed
    case decodingFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Rules database file (all_rules.mtgdata) not found"
        case .decompressionFailed:
            return "Failed to decompress rules database"
        case .decodingFailed(let error):
            return "Failed to decode rules database: \(error.localizedDescription)"
        }
    }
}