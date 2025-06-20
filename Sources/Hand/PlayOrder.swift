public enum PlayOrder: Int, CustomStringConvertible {
    case first = 0
    case second = 1

    public var description: String {
        let order = ["First", "Second"]
        guard self.rawValue < order.count else {
            return ""
        }

        return order[self.rawValue]
    }
}
