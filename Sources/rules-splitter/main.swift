import Foundation

// Main execution
let splitter = RulesSplitter()

// Check for command line arguments
if CommandLine.arguments.count > 1 {
    let urlString = CommandLine.arguments[1]
    splitter.splitRules(from: urlString)
} else {
    // Use default URL
    let defaultURL = "https://media.wizards.com/2025/downloads/MagicCompRules%2020250606.txt"
    splitter.splitRules(from: defaultURL)
}

