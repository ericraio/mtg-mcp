import Foundation

/// Unified processor that handles both card data and rules processing
public struct UnifiedDataProcessor {
    public init() {}
    
    /// Process both card data and rules concurrently
    public func processAll(rulesUrl: String? = nil, outputDir: String? = nil, force: Bool = false) async throws {
        let baseOutputDir = outputDir ?? "Sources/Database/Resources"
        
        print("🚀 Starting unified MTG data processing...")
        print("📁 Output directory: \(baseOutputDir)")
        
        // Create concurrent tasks for card and rules processing
        async let cardTask: Void = {
            print("🃏 [Cards] Starting card data processing...")
            let cardProcessor = CardDataProcessor()
            do {
                try await cardProcessor.process(outputDir: baseOutputDir, force: force)
                print("✅ [Cards] Card data processing completed")
            } catch {
                print("❌ [Cards] Card data processing failed: \(error.localizedDescription)")
                throw error
            }
        }()
        
        async let rulesTask: Void = {
            print("📖 [Rules] Starting rules processing...")
            let rulesProcessor = RulesProcessor()
            do {
                let rulesOutputDir = "\(baseOutputDir)/rules"
                try await rulesProcessor.process(url: rulesUrl, outputDir: rulesOutputDir, force: force)
                print("✅ [Rules] Rules processing completed")
            } catch {
                print("❌ [Rules] Rules processing failed: \(error.localizedDescription)")
                throw error
            }
        }()
        
        // Wait for both tasks to complete
        do {
            try await cardTask
            try await rulesTask
            
            print("🎉 All MTG data processing completed successfully!")
            print("📊 Verifying processed data...")
            
            // Verify the processed data
            let verifier = DataVerifier()
            try await verifier.verify(dataDir: baseOutputDir)
            
        } catch {
            print("❌ Unified processing failed: \(error.localizedDescription)")
            throw UnifiedProcessorError.processingFailed(error.localizedDescription)
        }
    }
}

/// Data integrity verifier
public struct DataVerifier {
    public init() {}
    
    /// Verify the integrity of processed MTG data
    public func verify(dataDir: String? = nil) async throws {
        let targetDir = dataDir ?? "Sources/Database/Resources"
        let fileManager = FileManager.default
        
        print("🔍 Verifying data integrity in: \(targetDir)")
        
        var issues: [String] = []
        
        // Check card data file
        let cardDataPath = "\(targetDir)/all_cards.mtgdata"
        if fileManager.fileExists(atPath: cardDataPath) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: cardDataPath)
                let size = attributes[.size] as? Int64 ?? 0
                let modDate = attributes[.modificationDate] as? Date
                
                print("✅ Card data file found: \(size) bytes")
                if let modDate = modDate {
                    let age = abs(modDate.timeIntervalSinceNow) / 3600
                    print("   📅 Last updated: \(String(format: "%.1f", age)) hours ago")
                }
                
                // Basic size check - should be at least 1MB for valid card data
                if size < 1_000_000 {
                    issues.append("Card data file is suspiciously small (\(size) bytes)")
                }
                
            } catch {
                issues.append("Cannot read card data file attributes: \(error.localizedDescription)")
            }
        } else {
            issues.append("Card data file not found at: \(cardDataPath)")
        }
        
        // Check compressed rules file (preferred)
        let compressedRulesPath = "\(targetDir)/all_rules.mtgdata"
        if fileManager.fileExists(atPath: compressedRulesPath) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: compressedRulesPath)
                let size = attributes[.size] as? Int64 ?? 0
                let modDate = attributes[.modificationDate] as? Date
                
                print("✅ Compressed rules file found: \(size) bytes")
                if let modDate = modDate {
                    let age = abs(modDate.timeIntervalSinceNow) / 3600
                    print("   📅 Last updated: \(String(format: "%.1f", age)) hours ago")
                }
                
                // Basic size check - compressed rules should be reasonable size
                if size < 50_000 {
                    issues.append("Compressed rules file is suspiciously small (\(size) bytes)")
                } else if size > 5_000_000 {
                    issues.append("Compressed rules file is suspiciously large (\(size) bytes)")
                }
                
            } catch {
                issues.append("Cannot read compressed rules file attributes: \(error.localizedDescription)")
            }
        } else {
            print("⚠️  Compressed rules file not found, checking individual files...")
        }
        
        // Check rules directory (fallback or legacy)
        let rulesDir = "\(targetDir)/rules"
        if fileManager.fileExists(atPath: rulesDir) {
            do {
                let ruleFiles = try fileManager.contentsOfDirectory(atPath: rulesDir)
                let mdFiles = ruleFiles.filter { $0.hasSuffix(".md") }
                
                print("✅ Rules directory found: \(mdFiles.count) rule files")
                
                // We expect around 100+ rule files
                if mdFiles.count < 50 {
                    issues.append("Too few rule files found (\(mdFiles.count), expected 50+)")
                }
                
                // Check some essential rules exist
                let essentialRules = ["100_general.md", "601_casting_spells.md", "903_commander.md"]
                for essential in essentialRules {
                    if !mdFiles.contains(essential) {
                        issues.append("Essential rule file missing: \(essential)")
                    }
                }
                
                // Check file sizes - rule files should not be empty
                var emptyFiles = 0
                for file in mdFiles.prefix(10) { // Check first 10 files
                    let filePath = "\(rulesDir)/\(file)"
                    let attributes = try fileManager.attributesOfItem(atPath: filePath)
                    let size = attributes[.size] as? Int64 ?? 0
                    if size < 10 { // Less than 10 bytes is likely empty
                        emptyFiles += 1
                    }
                }
                
                if emptyFiles > 0 {
                    issues.append("\(emptyFiles) rule files appear to be empty or too small")
                }
                
            } catch {
                issues.append("Cannot read rules directory: \(error.localizedDescription)")
            }
        } else {
            // Only require individual rules if compressed rules don't exist
            let compressedRulesPath = "\(targetDir)/all_rules.mtgdata"
            if !fileManager.fileExists(atPath: compressedRulesPath) {
                issues.append("Neither compressed rules file nor rules directory found")
            }
        }
        
        // Report results
        if issues.isEmpty {
            print("✅ Data verification passed - all checks successful!")
            print("🎯 MTG data is ready for use by the Database module")
        } else {
            print("⚠️ Data verification found \(issues.count) issue(s):")
            for issue in issues {
                print("   ❌ \(issue)")
            }
            throw DataVerifierError.verificationFailed("Data verification failed with \(issues.count) issues")
        }
    }
}

/// Errors that can occur during unified processing
public enum UnifiedProcessorError: Error, LocalizedError {
    case processingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .processingFailed(let message):
            return "Unified processing failed: \(message)"
        }
    }
}

/// Errors that can occur during data verification
public enum DataVerifierError: Error, LocalizedError {
    case verificationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .verificationFailed(let message):
            return "Data verification failed: \(message)"
        }
    }
}