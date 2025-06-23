import ArgumentParser
import Database
import Foundation

struct VerifyCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "verify",
        abstract: "Verify integrity of processed MTG data"
    )

    @Option(name: .shortAndLong, help: "Data directory to verify")
    var dataDir: String?

    func run() throws {
        print("🔍 Verifying MTG data integrity...")

        let task = Task {
            let verifier = DataVerifier()
            try await verifier.verify(dataDir: dataDir)
        }

        do {
            let _: Void = try runLoopUntilComplete(task: task)
        } catch {
            throw error
        }
    }
}
