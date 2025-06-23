import ArgumentParser
import Database
import Foundation

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
