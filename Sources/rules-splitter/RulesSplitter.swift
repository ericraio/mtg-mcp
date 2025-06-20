import Foundation
import SwiftGzip
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class RulesSplitter {
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
        RuleSection(number: "905", title: "Conspiracy Draft"),
    ]

    private func getSectionTitle(for number: String) -> String? {
        return sections.first(where: { $0.number == number })?.title
    }

    private func getChapterTitle(for number: String) -> String? {
        let firstDigit = String(number.prefix(1))
        switch firstDigit {
        case "1": return "Game Concepts"
        case "2": return "Parts of a Card"
        case "3": return "Card Types"
        case "4": return "Zones"
        case "5": return "Turn Structure"
        case "6": return "Spells, Abilities, and Effects"
        case "7": return "Additional Rules"
        case "8": return "Multiplayer Rules"
        case "9": return "Casual Variants"
        default: return nil
        }
    }

    private func sanitizeFilename(_ title: String) -> String {
        return title.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
    }

    func downloadRules(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return nil
        }

        print("Downloading rules from: \(urlString)")

        let semaphore = DispatchSemaphore(value: 0)
        var downloadedContent: String?
        var downloadError: Error?

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }

            if let error = error {
                downloadError = error
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                downloadError = NSError(
                    domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP request failed"])
                return
            }

            guard let data = data,
                let content = String(data: data, encoding: .utf8)
            else {
                downloadError = NSError(
                    domain: "DataError", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Could not decode response data"])
                return
            }

            downloadedContent = content
        }

        task.resume()
        semaphore.wait()

        if let error = downloadError {
            print("Error downloading rules: \(error.localizedDescription)")
            return nil
        }

        print("Successfully downloaded rules (\(downloadedContent?.count ?? 0) characters)")
        return downloadedContent
    }

    func splitRules(from urlString: String? = nil) {
        let rulesContent: String

        if let urlString = urlString {
            // Download from URL
            if let downloadedContent = downloadRules(from: urlString) {
                rulesContent = downloadedContent
            } else {
                print("Failed to download rules from URL. Trying local file...")
                guard let localContent = try? String(contentsOfFile: "rules.txt", encoding: .utf8)
                else {
                    print("Error: Could not read rules.txt file either")
                    return
                }
                rulesContent = localContent
            }
        } else {
            // Use local file
            guard let localContent = try? String(contentsOfFile: "rules.txt", encoding: .utf8)
            else {
                print("Error: Could not read rules.txt file")
                return
            }
            rulesContent = localContent
        }

        let lines = rulesContent.components(separatedBy: .newlines)
        var currentSection = ""
        var currentContent: [String] = []
        let fileManager = FileManager.default

        // Create rules directory if it doesn't exist
        let rulesDir = "rules"
        if !fileManager.fileExists(atPath: rulesDir) {
            try? fileManager.createDirectory(
                atPath: rulesDir, withIntermediateDirectories: false, attributes: nil)
        }

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // Check if this line starts a new numbered section (e.g., "100. General")
            if trimmedLine.range(of: #"^(\d{3})\.\s+(.+)$"#, options: .regularExpression) != nil {
                // Save previous section if we have content
                if !currentSection.isEmpty && !currentContent.isEmpty {
                    saveSection(currentSection, content: currentContent)
                }

                // Extract section number and title
                let sectionNumber = String(
                    trimmedLine[
                        trimmedLine
                            .startIndex..<trimmedLine.index(trimmedLine.startIndex, offsetBy: 3)])
                currentSection = sectionNumber
                currentContent = [line]  // Start with the section header
            } else if trimmedLine.range(of: #"^(\d)\.\s+(.+)$"#, options: .regularExpression) != nil
            {
                // Check if this is a major chapter header (e.g., "5. Turn Structure")
                // Save previous section if we have content, but don't start a new section for chapter headers
                if !currentSection.isEmpty && !currentContent.isEmpty {
                    saveSection(currentSection, content: currentContent)
                    currentSection = ""
                    currentContent = []
                }
                // Don't include chapter headers in any section - they're just separators
            } else if !currentSection.isEmpty {
                // Add line to current section
                currentContent.append(line)
            }
        }

        // Save the last section
        if !currentSection.isEmpty && !currentContent.isEmpty {
            saveSection(currentSection, content: currentContent)
        }

        print("Rules have been split into individual section files in the 'rules/' directory")
    }

    private func saveSection(_ sectionNumber: String, content: [String]) {
        guard let sectionTitle = getSectionTitle(for: sectionNumber),
            let chapterTitle = getChapterTitle(for: sectionNumber)
        else {
            print("Warning: Could not find title for section \(sectionNumber)")
            return
        }

        let filename = "\(sectionNumber)_\(sanitizeFilename(sectionTitle)).md"
        let filepath = "rules/\(filename)"

        var fileContent = "# \(sectionNumber). \(sectionTitle)\n\n"
        fileContent += "*Chapter: \(chapterTitle)*\n\n"
        fileContent += "---\n\n"
        fileContent += content.joined(separator: "\n")

        do {
            try fileContent.write(toFile: filepath, atomically: true, encoding: .utf8)
            print("Created: \(filepath)")
        } catch {
            print("Error writing file \(filepath): \(error)")
        }
    }
}
