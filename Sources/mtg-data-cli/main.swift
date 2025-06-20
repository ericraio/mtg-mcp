import Foundation
import ArgumentParser
import Database

struct MTGDataCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mtg",
        abstract: "Unified tool for processing MTG card data and rules",
        version: "1.0.0",
        subcommands: [CardsCommand.self, RulesCommand.self, CompressRulesCommand.self, TestRulesCommand.self, AllCommand.self, VerifyCommand.self],
        defaultSubcommand: AllCommand.self
    )
}

struct CardsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "cards",
        abstract: "Download and process MTG card data from Scryfall"
    )
    
    @Option(name: .shortAndLong, help: "Output directory for processed data")
    var outputDir: String?
    
    @Flag(help: "Force refresh even if data is recent")
    var force: Bool = false
    
    func run() throws {
        print("🃏 Processing MTG card data...")
        
        let task = Task {
            let processor = CardDataProcessor()
            try await processor.process(outputDir: outputDir, force: force)
        }
        
        do {
        let _: Void = try runLoopUntilComplete(task: task)
        } catch {
            throw error
        }
    }
}

struct RulesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "rules",
        abstract: "Download and process MTG comprehensive rules"
    )
    
    @Option(help: "URL for the comprehensive rules document")
    var url: String?
    
    @Option(name: .shortAndLong, help: "Output directory for processed rules")
    var outputDir: String?
    
    @Flag(help: "Force refresh even if data is recent")
    var force: Bool = false
    
    func run() throws {
        print("📖 Processing MTG rules data...")
        
        let task = Task {
            let processor = RulesProcessor()
            try await processor.process(url: url, outputDir: outputDir, force: force)
        }
        
        do {
        let _: Void = try runLoopUntilComplete(task: task)
        } catch {
            throw error
        }
    }
}

struct CompressRulesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "compress-rules",
        abstract: "Generate compressed all_rules.mtgdata from existing markdown files"
    )
    
    @Option(name: .shortAndLong, help: "Input directory containing markdown rule files")
    var inputDir: String?
    
    @Option(name: .shortAndLong, help: "Output path for compressed rules file")
    var outputPath: String?
    
    func run() throws {
        print("🗜️ Compressing MTG rules...")
        
        let task = Task {
            let processor = RulesProcessor()
            try await processor.generateCompressedRules(inputDir: inputDir, outputPath: outputPath)
        }
        
        do {
            let _: Void = try runLoopUntilComplete(task: task)
        } catch {
            throw error
        }
    }
}

struct TestRulesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "test-rules",
        abstract: "Test loading compressed rules data"
    )
    
    func run() throws {
        print("🧪 Testing compressed rules loading...")
        
        let task = Task {
            let rulesData = RulesData.newRulesData()
            
            do {
                try await rulesData.load()
                
                if let rules = rulesData.rules {
                    print("✅ Compressed rules loaded successfully!")
                    print("📊 Total rules: \(rules.totalRules)")
                    print("📅 Last updated: \(rules.lastUpdated)")
                    
                    // Test finding a specific rule
                    if let rule100 = rulesData.findRule(by: "100") {
                        print("✅ Found rule 100: \(rule100.title)")
                        print("📝 Content preview: \(String(rule100.content.prefix(100)))...")
                    } else {
                        print("❌ Could not find rule 100")
                    }
                    
                    // Test searching rules
                    let combatRules = rulesData.searchRules(containing: ["combat"])
                    print("🔍 Found \(combatRules.count) rules containing 'combat'")
                    
                    // Test section lookup
                    let section100Rules = rulesData.findRules(inSection: "100")
                    print("📚 Found \(section100Rules.count) rules in section 100")
                    
                } else {
                    print("❌ Rules data not loaded")
                }
                
            } catch {
                print("❌ Error loading compressed rules: \(error)")
                throw error
            }
            
            print("🏁 Test completed successfully")
        }
        
        do {
            let _: Void = try runLoopUntilComplete(task: task)
        } catch {
            throw error
        }
    }
}

struct AllCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "all",
        abstract: "Download and process both MTG card data and rules"
    )
    
    @Option(help: "URL for the comprehensive rules document")
    var rulesUrl: String?
    
    @Option(name: .shortAndLong, help: "Output directory for all processed data")
    var outputDir: String?
    
    @Flag(help: "Force refresh even if data is recent")
    var force: Bool = false
    
    func run() throws {
        print("🚀 Processing all MTG data (cards + rules)...")
        
        let task = Task {
            let processor = UnifiedDataProcessor()
            try await processor.processAll(rulesUrl: rulesUrl, outputDir: outputDir, force: force)
        }
        
        do {
        let _: Void = try runLoopUntilComplete(task: task)
        } catch {
            throw error
        }
    }
}

struct VerifyCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "verify",
        abstract: "Verify integrity of processed MTG data"
    )
    
    @Option(name: .shortAndLong, help: "Data directory to verify")
    var dataDir: String?
    
    func run() throws {
        print("🔍 Verifying MTG data integrity...")
        
        let task = Task {
            let verifier = DataVerifier()
            try await verifier.verify(dataDir: dataDir)
        }
        
        do {
        let _: Void = try runLoopUntilComplete(task: task)
        } catch {
            throw error
        }
    }
}

// Helper function to run async task synchronously
func runLoopUntilComplete<T>(task: Task<T, Error>) throws -> T {
    var result: Result<T, Error>? = nil
    let group = DispatchGroup()
    
    group.enter()
    Task {
        defer { group.leave() }
        do {
            let value = try await task.value
            result = .success(value)
        } catch {
            result = .failure(error)
        }
    }
    
    group.wait()
    return try result!.get()
}

MTGDataCLI.main()