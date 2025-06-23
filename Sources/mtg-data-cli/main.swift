import ArgumentParser
import Database
import Foundation

struct MTGDataCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mtg",
        abstract: "Unified tool for processing MTG card data and rules",
        version: "1.0.0",
        subcommands: [
            CardsCommand.self, RulesCommand.self, CompressRulesCommand.self, TestRulesCommand.self,
            AllCommand.self, VerifyCommand.self,
        ],
        defaultSubcommand: AllCommand.self
    )
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
