import Foundation

/// Maximum bipartite matching implementation
///
/// Returns the size of the maximum matching set of the
/// bipartite graph represented by the adjacency matrix
/// `edges` with `mCount` rows and `nCount` columns.
/// `seen` and `matches` are implementation-specific data structures
/// that are expected to be correctly sized by the caller to reduce
/// runtime allocations.
/// Implementation based on the "Alternate Approach" from
/// http://olympiad.cs.uct.ac.za/presentations/camp2_2017/bipartitematching-robin.pdf
/// Bipartite matching algorithm implementation
///
/// Resources:
/// - https://www.youtube.com/watch?v=HZLKDC9OSaQ
/// - https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-042j-mathematics-for-computer-science-fall-2010/readings/MIT6_042JF10_chap05.pdf
/// - https://en.wikipedia.org/wiki/Ford%E2%80%93Fulkerson_algorithm
/// - https://en.wikipedia.org/wiki/Hopcroft%E2%80%93Karp_algorithm
/// - https://en.wikipedia.org/wiki/Edmonds%E2%80%93Karp_algorithm
/// - http://olympiad.cs.uct.ac.za/presentations/camp2_2017/bipartitematching-robin.pdf
public class Bipartite {
    /// Finds the maximum bipartite matching
    /// - Parameters:
    ///   - edges: Adjacency matrix
    ///   - pipCount: Number of pips (rows)
    ///   - landCount: Number of lands (columns)
    ///   - seen: Array tracking visited nodes
    ///   - matches: Array tracking matched nodes
    /// - Returns: Number of nodes in the maximum matching
    public static func maximumBipartiteMatching(
        edges: inout [UInt8],
        pipCount: Int,
        landCount: Int,
        seen: inout [Bool],
        matches: inout [Int]
    ) -> Int {
        // Reset matches array
        for i in 0..<landCount {
            matches[i] = -1
        }
        
        var matchCount = 0
        
        for u in 0..<pipCount {
            // Reset seen array
            for i in 0..<landCount {
                seen[i] = false
            }
            
            if bipartiteDFS(u: u, edges: &edges, pipCount: pipCount, landCount: landCount, seen: &seen, matches: &matches) {
                matchCount += 1
            }
        }
        
        return matchCount
    }
    
    /// Depth-first search for augmenting paths
    private static func bipartiteDFS(
        u: Int,
        edges: inout [UInt8],
        pipCount: Int,
        landCount: Int,
        seen: inout [Bool],
        matches: inout [Int]
    ) -> Bool {
        // Try all lands (right side vertices)
        for v in 0..<landCount {
            // If pip u connects to land v and v hasn't been seen yet
            if edges[u * landCount + v] > 0 && !seen[v] {
                seen[v] = true
                
                // If land v is not matched or we have an augmenting path
                if matches[v] == -1 || bipartiteDFS(
                    u: matches[v],
                    edges: &edges,
                    pipCount: pipCount,
                    landCount: landCount,
                    seen: &seen,
                    matches: &matches
                ) {
                    matches[v] = u
                    return true
                }
            }
        }
        
        return false
    }
}
