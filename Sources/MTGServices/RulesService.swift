import Foundation

/// Service for managing and searching MTG rules
public final class RulesService: Sendable {
    private let rulesDirectory: String
    private let logger: Logger
    
    public init(rulesDirectory: String? = nil, logger: Logger? = nil) {
        self.logger = logger ?? LoggerFactory.createLogger(for: "RulesService")
        
        if let customDirectory = rulesDirectory {
            self.rulesDirectory = customDirectory
            self.logger.info("Using custom rules directory: \(customDirectory)")
        } else {
            // Use Database module bundle resources (new location)
            // For now, use development fallback since bundle access is complex
            self.rulesDirectory = "Sources/Database/Resources/rules"
            self.logger.info("Using Database rules directory: \(self.rulesDirectory)")
        }
        
        // Verify rules directory exists
        if FileManager.default.fileExists(atPath: self.rulesDirectory) {
            self.logger.info("Rules directory found and accessible")
        } else {
            self.logger.error("Rules directory not found: \(self.rulesDirectory)")
        }
    }
    
    /// Look up a specific rule by number (e.g., "100", "601.2a")
    public func lookupRule(_ ruleNumber: String) -> RuleResult? {
        logger.debug("Looking up rule: \(ruleNumber)")
        
        // Handle both main rules (e.g., "100") and sub-rules (e.g., "601.2a")
        let mainRuleNumber: String
        if ruleNumber.contains(".") {
            mainRuleNumber = String(ruleNumber.prefix(3))
        } else {
            mainRuleNumber = ruleNumber.padding(toLength: 3, withPad: "0", startingAt: 0)
        }
        
        // Find the matching rule file
        guard let ruleFile = findRuleFile(for: mainRuleNumber) else {
            logger.warning("Rule file not found for rule: \(ruleNumber)")
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: "\(rulesDirectory)/\(ruleFile)", encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            if ruleNumber.contains(".") {
                // Look for specific sub-rule
                let result = findSpecificRule(ruleNumber, in: lines, file: ruleFile)
                if result != nil {
                    logger.info("Found specific rule: \(ruleNumber)")
                } else {
                    logger.warning("Specific rule not found: \(ruleNumber)")
                }
                return result
            } else {
                // Return the entire section
                logger.info("Retrieved rule section: \(mainRuleNumber)")
                return RuleResult(
                    ruleNumber: mainRuleNumber,
                    title: extractTitle(from: lines),
                    content: content,
                    file: ruleFile
                )
            }
        } catch {
            logger.error("Error reading rule file \(ruleFile): \(error)")
            return nil
        }
    }
    
    /// Search for rules containing specific keywords
    public func searchRules(_ keywords: [String]) -> [RuleSearchResult] {
        logger.debug("Searching rules for keywords: \(keywords.joined(separator: ", "))")
        var results: [RuleSearchResult] = []
        
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: rulesDirectory) else {
            logger.error("Failed to read rules directory: \(rulesDirectory)")
            return results
        }
        
        let ruleFiles = files.filter { $0.hasSuffix(".md") }
        logger.debug("Found \(ruleFiles.count) rule files to search")
        
        for file in ruleFiles {
            do {
                let content = try String(contentsOfFile: "\(rulesDirectory)/\(file)", encoding: .utf8)
                let lines = content.components(separatedBy: .newlines)
                
                // Search for keywords in content
                let matchingLines = findMatchingLines(keywords: keywords, in: lines)
                
                if !matchingLines.isEmpty {
                    let ruleNumber = extractRuleNumber(from: file)
                    let title = extractTitle(from: lines)
                    
                    results.append(RuleSearchResult(
                        ruleNumber: ruleNumber,
                        title: title,
                        file: file,
                        matchingLines: matchingLines
                    ))
                }
            } catch {
                logger.warning("Error reading rule file \(file): \(error)")
                continue
            }
        }
        
        logger.info("Found \(results.count) matching rules for search")
        return results.sorted { $0.ruleNumber < $1.ruleNumber }
    }
    
    /// Get rules related to a specific game concept
    public func getRulesForConcept(_ concept: String) -> [RuleResult] {
        let keywords = conceptKeywords(for: concept.lowercased())
        let searchResults = searchRules(keywords)
        
        return searchResults.compactMap { searchResult in
            lookupRule(searchResult.ruleNumber)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func findRuleFile(for ruleNumber: String) -> String? {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: rulesDirectory) else {
            return nil
        }
        
        return files.first { $0.hasPrefix("\(ruleNumber)_") && $0.hasSuffix(".md") }
    }
    
    private func findSpecificRule(_ ruleNumber: String, in lines: [String], file: String) -> RuleResult? {
        for (index, line) in lines.enumerated() {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("\(ruleNumber).") {
                // Found the specific rule, collect its content
                var ruleContent = [line]
                var nextIndex = index + 1
                
                // Collect subsequent lines until we hit another rule number or end
                while nextIndex < lines.count {
                    let nextLine = lines[nextIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Stop if we hit another rule number at the same level
                    if nextLine.range(of: #"^\d{3}\.\d+[a-z]*\."#, options: .regularExpression) != nil {
                        break
                    }
                    
                    ruleContent.append(lines[nextIndex])
                    nextIndex += 1
                    
                    // Stop at next major rule or empty line followed by rule
                    if nextLine.isEmpty && nextIndex < lines.count {
                        let followingLine = lines[nextIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                        if followingLine.range(of: #"^\d{3}\."#, options: .regularExpression) != nil {
                            break
                        }
                    }
                }
                
                return RuleResult(
                    ruleNumber: ruleNumber,
                    title: extractSpecificRuleTitle(from: line),
                    content: ruleContent.joined(separator: "\n"),
                    file: file
                )
            }
        }
        
        return nil
    }
    
    private func extractTitle(from lines: [String]) -> String {
        for line in lines {
            if line.hasPrefix("# ") {
                return String(line.dropFirst(2))
            }
        }
        return ""
    }
    
    private func extractSpecificRuleTitle(from line: String) -> String {
        // Extract rule title from lines like "100.1. These Magic rules apply..."
        if let range = line.range(of: #"^\d{3}\.\d+[a-z]*\.\s*"#, options: .regularExpression) {
            return String(line[range.upperBound...])
        }
        return line
    }
    
    private func extractRuleNumber(from filename: String) -> String {
        let components = filename.components(separatedBy: "_")
        return components.first ?? ""
    }
    
    private func findMatchingLines(keywords: [String], in lines: [String]) -> [String] {
        var matchingLines: [String] = []
        
        for line in lines {
            let lowercaseLine = line.lowercased()
            let hasAllKeywords = keywords.allSatisfy { keyword in
                lowercaseLine.contains(keyword.lowercased())
            }
            
            if hasAllKeywords && !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchingLines.append(line)
            }
        }
        
        return matchingLines
    }
    
    private func conceptKeywords(for concept: String) -> [String] {
        switch concept {
        case "casting", "cast", "spell":
            return ["cast", "spell"]
        case "combat", "attack", "block":
            return ["combat", "attack", "damage"]
        case "mana", "tap", "untap":
            return ["mana", "tap"]
        case "draw", "drawing":
            return ["draw", "card"]
        case "mulligan":
            return ["mulligan", "hand"]
        case "priority":
            return ["priority", "stack"]
        case "triggered", "trigger":
            return ["trigger", "ability"]
        case "activated":
            return ["activated", "ability"]
        case "static":
            return ["static", "ability"]
        case "counter", "counters":
            return ["counter"]
        case "permanent", "permanents":
            return ["permanent", "battlefield"]
        case "graveyard", "grave":
            return ["graveyard"]
        case "exile", "exiled":
            return ["exile"]
        case "library", "deck":
            return ["library"]
        case "hand":
            return ["hand"]
        case "stack":
            return ["stack"]
        case "command":
            return ["command", "zone"]
        default:
            return [concept]
        }
    }
}

// MARK: - Result Types

public struct RuleResult {
    public let ruleNumber: String
    public let title: String
    public let content: String
    public let file: String
    
    public init(ruleNumber: String, title: String, content: String, file: String) {
        self.ruleNumber = ruleNumber
        self.title = title
        self.content = content
        self.file = file
    }
}

public struct RuleSearchResult {
    public let ruleNumber: String
    public let title: String
    public let file: String
    public let matchingLines: [String]
    
    public init(ruleNumber: String, title: String, file: String, matchingLines: [String]) {
        self.ruleNumber = ruleNumber
        self.title = title
        self.file = file
        self.matchingLines = matchingLines
    }
}