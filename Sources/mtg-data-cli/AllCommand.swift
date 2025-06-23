import ArgumentParser
import Database
import Foundation

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
