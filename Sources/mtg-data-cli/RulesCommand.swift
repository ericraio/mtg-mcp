import ArgumentParser
import Database
import Foundation

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
