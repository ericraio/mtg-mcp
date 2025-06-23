import ArgumentParser
import Database
import Foundation

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
