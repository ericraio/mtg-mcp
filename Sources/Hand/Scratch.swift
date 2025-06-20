/// Scratch space for the bipartite matching algorithm
/// Used to reduce allocations at runtime.
public class Scratch {
    var lands: [SimCard?]
    var edges: [UInt8]
    var seen: [Bool]
    var matches: [Int]
    
    /// Returns a new Scratch object based on the number of land cards in a deck
    /// and the maximum pip count of any one card. It's OK if you guess wrong for
    /// these numbers, there will simply be one additional allocation to make up
    /// the difference.
    public static func new(maxLandCount: Int, maxPipCount: Int) -> Scratch {
        return Scratch(maxLandCount: maxLandCount, maxPipCount: maxPipCount)
    }
    
    public init(maxLandCount: Int, maxPipCount: Int) {
        let edgeCount = maxLandCount * maxPipCount
        
        // Initialize edges with zeros
        var edgesArray = [UInt8]()
        for _ in 0..<edgeCount {
            edgesArray.append(0)
        }
        
        // Initialize reference arrays
        var seenArray = [Bool]()
        var matchesArray = [Int]()
        for _ in 0..<maxLandCount {
            seenArray.append(false)
            matchesArray.append(-1)
        }
        
        self.lands = Array(repeating: nil, count: maxLandCount)
        self.edges = edgesArray
        self.seen = seenArray
        self.matches = matchesArray
    }
    
    /// Clears the lands array
    public func clearLands() {
        lands.removeAll()
    }
    
    /// Resizes the edges array to the specified amount with the given value
    public func resizeEdges(amount: Int, value: Int) {
        var edges = [UInt8]()
        for _ in 0..<amount {
            edges.append(UInt8(value))
        }
        self.edges = edges
    }
    
    /// Resizes the seen array to the specified amount with the given value
    public func resizeSeen(amount: Int, value: Bool) {
        var seen = [Bool]()
        for _ in 0..<amount {
            seen.append(value)
        }
        self.seen = seen
    }
    
    /// Resizes the matches array to the specified amount with the given value
    public func resizeMatches(amount: Int, value: Int) {
        var matches = [Int]()
        for _ in 0..<amount {
            matches.append(value)
        }
        self.matches = matches
    }
}
