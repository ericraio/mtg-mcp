import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SwiftGzip
import Database

/// Processor for downloading and splitting MTG comprehensive rules
public struct RulesProcessor {
    private let defaultOutputDir = "Sources/Database/Resources/rules"
    private let defaultRulesURL = "https://media.wizards.com/2025/downloads/MagicCompRules%2020250606.txt"
    
    // All MTG rule sections
    private let sections: [RuleSection] = [
        // 1. Game Concepts
        RuleSection(number: "100", title: "General"),
        RuleSection(number: "101", title: "The Magic Golden Rules"),
        RuleSection(number: "102", title: "Players"),
        RuleSection(number: "103", title: "Starting the Game"),
        RuleSection(number: "104", title: "Ending the Game"),
        RuleSection(number: "105", title: "Colors"),
        RuleSection(number: "106", title: "Mana"),
        RuleSection(number: "107", title: "Numbers and Symbols"),
        RuleSection(number: "108", title: "Cards"),
        RuleSection(number: "109", title: "Objects"),
        RuleSection(number: "110", title: "Permanents"),
        RuleSection(number: "111", title: "Tokens"),
        RuleSection(number: "112", title: "Spells"),
        RuleSection(number: "113", title: "Abilities"),
        RuleSection(number: "114", title: "Emblems"),
        RuleSection(number: "115", title: "Targets"),
        RuleSection(number: "116", title: "Special Actions"),
        RuleSection(number: "117", title: "Timing and Priority"),
        RuleSection(number: "118", title: "Costs"),
        RuleSection(number: "119", title: "Life"),
        RuleSection(number: "120", title: "Damage"),
        RuleSection(number: "121", title: "Drawing a Card"),
        RuleSection(number: "122", title: "Counters"),
        RuleSection(number: "123", title: "Stickers"),

        // 2. Parts of a Card
        RuleSection(number: "200", title: "General"),
        RuleSection(number: "201", title: "Name"),
        RuleSection(number: "202", title: "Mana Cost and Color"),
        RuleSection(number: "203", title: "Illustration"),
        RuleSection(number: "204", title: "Color Indicator"),
        RuleSection(number: "205", title: "Type Line"),
        RuleSection(number: "206", title: "Expansion Symbol"),
        RuleSection(number: "207", title: "Text Box"),
        RuleSection(number: "208", title: "Power/Toughness"),
        RuleSection(number: "209", title: "Loyalty"),
        RuleSection(number: "210", title: "Defense"),
        RuleSection(number: "211", title: "Hand Modifier"),
        RuleSection(number: "212", title: "Life Modifier"),
        RuleSection(number: "213", title: "Information Below the Text Box"),

        // 3. Card Types
        RuleSection(number: "300", title: "General"),
        RuleSection(number: "301", title: "Artifacts"),
        RuleSection(number: "302", title: "Creatures"),
        RuleSection(number: "303", title: "Enchantments"),
        RuleSection(number: "304", title: "Instants"),
        RuleSection(number: "305", title: "Lands"),
        RuleSection(number: "306", title: "Planeswalkers"),
        RuleSection(number: "307", title: "Sorceries"),
        RuleSection(number: "308", title: "Kindreds"),
        RuleSection(number: "309", title: "Dungeons"),
        RuleSection(number: "310", title: "Battles"),
        RuleSection(number: "311", title: "Planes"),
        RuleSection(number: "312", title: "Phenomena"),
        RuleSection(number: "313", title: "Vanguards"),
        RuleSection(number: "314", title: "Schemes"),
        RuleSection(number: "315", title: "Conspiracies"),

        // 4. Zones
        RuleSection(number: "400", title: "General"),
        RuleSection(number: "401", title: "Library"),
        RuleSection(number: "402", title: "Hand"),
        RuleSection(number: "403", title: "Battlefield"),
        RuleSection(number: "404", title: "Graveyard"),
        RuleSection(number: "405", title: "Stack"),
        RuleSection(number: "406", title: "Exile"),
        RuleSection(number: "407", title: "Ante"),
        RuleSection(number: "408", title: "Command"),

        // 5. Turn Structure
        RuleSection(number: "500", title: "General"),
        RuleSection(number: "501", title: "Beginning Phase"),
        RuleSection(number: "502", title: "Untap Step"),
        RuleSection(number: "503", title: "Upkeep Step"),
        RuleSection(number: "504", title: "Draw Step"),
        RuleSection(number: "505", title: "Main Phase"),
        RuleSection(number: "506", title: "Combat Phase"),
        RuleSection(number: "507", title: "Beginning of Combat Step"),
        RuleSection(number: "508", title: "Declare Attackers Step"),
        RuleSection(number: "509", title: "Declare Blockers Step"),
        RuleSection(number: "510", title: "Combat Damage Step"),
        RuleSection(number: "511", title: "End of Combat Step"),
        RuleSection(number: "512", title: "Ending Phase"),
        RuleSection(number: "513", title: "End Step"),
        RuleSection(number: "514", title: "Cleanup Step"),

        // 6. Spells, Abilities, and Effects
        RuleSection(number: "600", title: "General"),
        RuleSection(number: "601", title: "Casting Spells"),
        RuleSection(number: "602", title: "Activating Activated Abilities"),
        RuleSection(number: "603", title: "Handling Triggered Abilities"),
        RuleSection(number: "604", title: "Handling Static Abilities"),
        RuleSection(number: "605", title: "Mana Abilities"),
        RuleSection(number: "606", title: "Loyalty Abilities"),
        RuleSection(number: "607", title: "Linked Abilities"),
        RuleSection(number: "608", title: "Resolving Spells and Abilities"),
        RuleSection(number: "609", title: "Effects"),
        RuleSection(number: "610", title: "One-Shot Effects"),
        RuleSection(number: "611", title: "Continuous Effects"),
        RuleSection(number: "612", title: "Text-Changing Effects"),
        RuleSection(number: "613", title: "Interaction of Continuous Effects"),
        RuleSection(number: "614", title: "Replacement Effects"),
        RuleSection(number: "615", title: "Prevention Effects"),
        RuleSection(number: "616", title: "Interaction of Replacement and/or Prevention Effects"),

        // 7. Additional Rules
        RuleSection(number: "700", title: "General"),
        RuleSection(number: "701", title: "Keyword Actions"),
        RuleSection(number: "702", title: "Keyword Abilities"),
        RuleSection(number: "703", title: "Turn-Based Actions"),
        RuleSection(number: "704", title: "State-Based Actions"),
        RuleSection(number: "705", title: "Flipping a Coin"),
        RuleSection(number: "706", title: "Rolling a Die"),
        RuleSection(number: "707", title: "Copying Objects"),
        RuleSection(number: "708", title: "Face-Down Spells and Permanents"),
        RuleSection(number: "709", title: "Split Cards"),
        RuleSection(number: "710", title: "Flip Cards"),
        RuleSection(number: "711", title: "Leveler Cards"),
        RuleSection(number: "712", title: "Double-Faced Cards"),
        RuleSection(number: "713", title: "Substitute Cards"),
        RuleSection(number: "714", title: "Saga Cards"),
        RuleSection(number: "715", title: "Adventurer Cards"),
        RuleSection(number: "716", title: "Class Cards"),
        RuleSection(number: "717", title: "Attraction Cards"),
        RuleSection(number: "718", title: "Prototype Cards"),
        RuleSection(number: "719", title: "Case Cards"),
        RuleSection(number: "720", title: "Omen Cards"),
        RuleSection(number: "721", title: "Controlling Another Player"),
        RuleSection(number: "722", title: "Ending Turns and Phases"),
        RuleSection(number: "723", title: "The Monarch"),
        RuleSection(number: "724", title: "The Initiative"),
        RuleSection(number: "725", title: "Restarting the Game"),
        RuleSection(number: "726", title: "Rad Counters"),
        RuleSection(number: "727", title: "Subgames"),
        RuleSection(number: "728", title: "Merging with Permanents"),
        RuleSection(number: "729", title: "Day and Night"),
        RuleSection(number: "730", title: "Taking Shortcuts"),
        RuleSection(number: "731", title: "Handling Illegal Actions"),

        // 8. Multiplayer Rules
        RuleSection(number: "800", title: "General"),
        RuleSection(number: "801", title: "Limited Range of Influence Option"),
        RuleSection(number: "802", title: "Attack Multiple Players Option"),
        RuleSection(number: "803", title: "Attack Left and Attack Right Options"),
        RuleSection(number: "804", title: "Deploy Creatures Option"),
        RuleSection(number: "805", title: "Shared Team Turns Option"),
        RuleSection(number: "806", title: "Free-for-All Variant"),
        RuleSection(number: "807", title: "Grand Melee Variant"),
        RuleSection(number: "808", title: "Team vs. Team Variant"),
        RuleSection(number: "809", title: "Emperor Variant"),
        RuleSection(number: "810", title: "Two-Headed Giant Variant"),
        RuleSection(number: "811", title: "Alternating Teams Variant"),

        // 9. Casual Variants
        RuleSection(number: "900", title: "General"),
        RuleSection(number: "901", title: "Planechase"),
        RuleSection(number: "902", title: "Vanguard"),
        RuleSection(number: "903", title: "Commander"),
        RuleSection(number: "904", title: "Archenemy"),
        RuleSection(number: "905", title: "Conspiracy Draft")
    ]
    
    public init() {}
    
    /// Process rules data from Wizards
    public func process(url: String? = nil, outputDir: String? = nil, force: Bool = false) async throws {
        let targetDir = outputDir ?? defaultOutputDir
        let rulesURL = url ?? defaultRulesURL
        
        // Check if we need to refresh the data
        if !force && shouldSkipUpdate(in: targetDir) {
            print("📋 Rules data is recent, skipping update (use --force to override)")
            return
        }
        
        print("📡 Downloading comprehensive rules from Wizards...")
        guard let rulesContent = await downloadRules(from: rulesURL) else {
            throw RulesProcessorError.downloadFailed("Failed to download rules from \(rulesURL)")
        }
        
        print("✅ Downloaded \(rulesContent.count) characters of rules text")
        print("🔧 Splitting rules into sections...")
        
        try await splitRules(content: rulesContent, outputDir: targetDir)
        
        print("🎉 Rules processing completed successfully!")
    }
    
    /// Download rules content from URL
    private func downloadRules(from urlString: String) async -> String? {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return nil
        }

        print("📡 Downloading from: \(urlString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ HTTP request failed with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return nil
            }
            
            guard let content = String(data: data, encoding: .utf8) else {
                print("❌ Could not decode response data as UTF-8")
                return nil
            }
            
            print("✅ Successfully downloaded \(content.count) characters")
            return content
            
        } catch {
            print("❌ Download error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Split rules content into individual section files
    private func splitRules(content: String, outputDir: String) async throws {
        let lines = content.components(separatedBy: .newlines)
        var currentSection = ""
        var currentContent: [String] = []
        let fileManager = FileManager.default
        
        // Create rules directory if it doesn't exist
        try fileManager.createDirectory(
            atPath: outputDir, 
            withIntermediateDirectories: true, 
            attributes: nil
        )
        
        var processedFiles = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if this line starts a new numbered section (e.g., "100. General")
            if trimmedLine.range(of: #"^(\d{3})\.\s+(.+)$"#, options: .regularExpression) != nil {
                // Save previous section if we have content
                if !currentSection.isEmpty && !currentContent.isEmpty {
                    try saveSection(currentSection, content: currentContent, outputDir: outputDir)
                    processedFiles += 1
                }
                
                // Extract section number from the regex match
                let sectionNumber = String(trimmedLine[trimmedLine.startIndex..<trimmedLine.firstIndex(of: ".")!])
                currentSection = sectionNumber
                currentContent = [line] // Start with the header line
            } else if !currentSection.isEmpty {
                // Add content to current section
                currentContent.append(line)
            }
        }
        
        // Save the last section
        if !currentSection.isEmpty && !currentContent.isEmpty {
            try saveSection(currentSection, content: currentContent, outputDir: outputDir)
            processedFiles += 1
        }
        
        print("✅ Processed \(processedFiles) rule sections")
    }
    
    /// Save a section to a markdown file
    private func saveSection(_ sectionNumber: String, content: [String], outputDir: String) throws {
        guard let section = sections.first(where: { $0.number == sectionNumber }) else {
            print("⚠️ Unknown section: \(sectionNumber)")
            return
        }
        
        let filename = "\(sectionNumber)_\(sanitizeFilename(section.title)).md"
        let filepath = "\(outputDir)/\(filename)"
        
        let contentString = content.joined(separator: "\n")
        
        do {
            try contentString.write(toFile: filepath, atomically: true, encoding: .utf8)
            print("📝 Saved: \(filename)")
        } catch {
            print("❌ Failed to save \(filename): \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Sanitize filename by replacing problematic characters
    private func sanitizeFilename(_ title: String) -> String {
        return title.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
    }
    
    /// Check if we should skip updating based on file age
    private func shouldSkipUpdate(in directory: String) -> Bool {
        let fileManager = FileManager.default
        
        // Check if rules directory exists and has recent files
        guard fileManager.fileExists(atPath: directory) else {
            return false
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directory)
            let ruleFiles = files.filter { $0.hasSuffix(".md") && $0.contains("_") }
            
            // If we don't have many rule files, we should update
            guard ruleFiles.count > 50 else { // We expect ~100+ rule files
                return false
            }
            
            // Check the age of the newest file
            var newestDate: Date?
            for file in ruleFiles.prefix(5) { // Check a few files
                let filePath = "\(directory)/\(file)"
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                if let modDate = attributes[.modificationDate] as? Date {
                    if newestDate == nil || modDate > newestDate! {
                        newestDate = modDate
                    }
                }
            }
            
            if let newestDate = newestDate {
                let hoursSinceUpdate = abs(newestDate.timeIntervalSinceNow) / 3600
                // Skip if files are less than 24 hours old (rules change less frequently)
                return hoursSinceUpdate < 24
            }
            
        } catch {
            print("⚠️ Could not check rules directory age: \(error.localizedDescription)")
        }
        
        return false
    }
    
    /// Generate compressed all_rules.mtgdata file from existing markdown files
    public func generateCompressedRules(inputDir: String? = nil, outputPath: String? = nil) async throws {
        let sourceDir = inputDir ?? defaultOutputDir
        let targetPath = outputPath ?? "Sources/Database/Resources/all_rules.mtgdata"
        
        print("🗜️ Generating compressed rules file...")
        print("📁 Reading from: \(sourceDir)")
        print("📄 Output file: \(targetPath)")
        
        let fileManager = FileManager.default
        
        // Check if source directory exists
        guard fileManager.fileExists(atPath: sourceDir) else {
            throw RulesProcessorError.fileSystemError("Source rules directory not found: \(sourceDir)")
        }
        
        // Get all markdown files
        let files = try fileManager.contentsOfDirectory(atPath: sourceDir)
        let ruleFiles = files.filter { $0.hasSuffix(".md") }.sorted()
        
        print("📚 Found \(ruleFiles.count) rule files to process")
        
        var ruleEntries: [RuleEntry] = []
        
        // Process each markdown file
        for filename in ruleFiles {
            let filePath = "\(sourceDir)/\(filename)"
            
            do {
                let content = try String(contentsOfFile: filePath, encoding: .utf8)
                let lines = content.components(separatedBy: .newlines)
                
                // Extract rule number from filename (e.g., "100_general.md" -> "100")
                let ruleNumber = extractRuleNumber(from: filename)
                
                // Extract title from first header line
                let title = extractTitle(from: lines)
                
                // Create rule entry
                let ruleEntry = RuleEntry(
                    ruleNumber: ruleNumber,
                    title: title,
                    content: content,
                    filename: filename
                )
                
                ruleEntries.append(ruleEntry)
                
            } catch {
                print("⚠️ Failed to read \(filename): \(error.localizedDescription)")
                continue
            }
        }
        
        print("✅ Processed \(ruleEntries.count) rule entries")
        
        // Create comprehensive rules container
        let comprehensiveRules = ComprehensiveRules(rules: ruleEntries)
        
        // Encode to JSON
        print("📝 Encoding to JSON...")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys] // For consistent output
        
        let jsonData = try encoder.encode(comprehensiveRules)
        print("📦 JSON size: \(jsonData.count) bytes")
        
        // Compress the data
        print("🗜️ Compressing data...")
        let compressor = GzipCompressor()
        let compressedData = try await compressor.zip(data: jsonData)
        print("✅ Compressed to \(compressedData.count) bytes (\(Int((1.0 - Double(compressedData.count)/Double(jsonData.count)) * 100))% reduction)")
        
        // Create output directory if needed
        let outputURL = URL(fileURLWithPath: targetPath)
        let outputDir = outputURL.deletingLastPathComponent().path
        try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
        
        // Write compressed data
        print("💾 Writing compressed rules file...")
        try compressedData.write(to: outputURL)
        
        print("🎉 Successfully generated compressed rules file!")
        print("📊 Statistics:")
        print("   - Total rules: \(comprehensiveRules.totalRules)")
        print("   - JSON size: \(jsonData.count) bytes")
        print("   - Compressed size: \(compressedData.count) bytes")
        print("   - Compression ratio: \(Int((1.0 - Double(compressedData.count)/Double(jsonData.count)) * 100))%")
    }
    
    /// Extract rule number from filename
    private func extractRuleNumber(from filename: String) -> String {
        let components = filename.components(separatedBy: "_")
        return components.first ?? filename.replacingOccurrences(of: ".md", with: "")
    }
    
    /// Extract title from markdown content
    private func extractTitle(from lines: [String]) -> String {
        for line in lines {
            if line.hasPrefix("# ") {
                return String(line.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return "Untitled"
    }
}

/// Errors that can occur during rules processing
public enum RulesProcessorError: Error, LocalizedError {
    case downloadFailed(String)
    case processingFailed(String)
    case fileSystemError(String)
    
    public var errorDescription: String? {
        switch self {
        case .downloadFailed(let message):
            return "Rules download failed: \(message)"
        case .processingFailed(let message):
            return "Rules processing failed: \(message)"
        case .fileSystemError(let message):
            return "File system error: \(message)"
        }
    }
}