struct RuleSection {
    let number: String
    let title: String
    let subsections: [String]

    init(number: String, title: String, subsections: [String] = []) {
        self.number = number
        self.title = title
        self.subsections = subsections
    }
}
