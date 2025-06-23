import ArgumentParser
import Database
import Foundation

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
