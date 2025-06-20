import Testing
@testable import Bipartite

/// Test with an empty graph
@Test func testEmptyGraph() {
    let edges: [[UInt8]] = []
    let result = maximumMatching(edges: edges, mCount: 0, nCount: 0)
    #expect(result == 0, "Empty graph should return 0 matches")
}

/// Test with a simple 1x1 graph with a connection
@Test func testSingleConnection() {
    let edges: [[UInt8]] = [[1]]
    let result = maximumMatching(edges: edges, mCount: 1, nCount: 1)
    #expect(result == 1, "Single connection graph should return 1 match")
}

/// Test with a simple 1x1 graph without a connection
@Test func testSingleNoConnection() {
    let edges: [[UInt8]] = [[0]]
    let result = maximumMatching(edges: edges, mCount: 1, nCount: 1)
    #expect(result == 0, "Graph with no connections should return 0 matches")
}

/// Test with a small rectangular graph
@Test func testSmallRectangularGraph() {
    let edges: [[UInt8]] = [
        [1, 1, 0],
        [0, 1, 1],
    ]
    let result = maximumMatching(edges: edges, mCount: 2, nCount: 3)
    #expect(result == 2, "This graph should have 2 maximum matches")
}

/// Test a complete bipartite graph Km,n where m = n
@Test func testCompleteGraph() {
    let edges: [[UInt8]] = Array(repeating: Array(repeating: UInt8(1), count: 4), count: 4)
    let result = maximumMatching(edges: edges, mCount: 4, nCount: 4)
    #expect(result == 4, "Complete graph K4,4 should have 4 maximum matches")
}

/// Test for a graph with more left nodes than right nodes
@Test func testMoreLeftNodes() {
    let edges: [[UInt8]] = [
        [1, 0],
        [1, 0],
        [0, 1],
    ]
    let result = maximumMatching(edges: edges, mCount: 3, nCount: 2)
    #expect(result == 2, "Graph with 3 left nodes and 2 right nodes should have max 2 matches")
}

/// Test for a graph with more right nodes than left nodes
@Test func testMoreRightNodes() {
    let edges: [[UInt8]] = [
        [1, 0, 1],
        [0, 1, 0],
    ]
    let result = maximumMatching(edges: edges, mCount: 2, nCount: 3)
    #expect(result == 2, "Graph with 2 left nodes and 3 right nodes should have max 2 matches")
}

/// Test a complex bipartite graph case
@Test func testComplexCase() {
    let edges: [[UInt8]] = [
        [0, 1, 1, 0, 0],
        [1, 0, 0, 1, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 1, 0],
        [0, 0, 0, 0, 1],
    ]
    let result = maximumMatching(edges: edges, mCount: 5, nCount: 5)
    #expect(result == 5, "This complex graph should have 5 matches")
}

/// Test case to verify recursive path finding
@Test func testRecursivePathFinding() {
    let edges: [[UInt8]] = [
        [0, 1, 0, 0],
        [1, 0, 1, 0],
        [0, 0, 1, 1],
        [0, 0, 0, 1],
    ]
    let result = maximumMatching(edges: edges, mCount: 4, nCount: 4)
    #expect(result == 4, "This graph requires recursive reassignment and should have 4 matches")
}

/// Test a known pathological case that requires multiple augmentation paths
@Test func testPathologicalCase() {
    let edges: [[UInt8]] = [
        [1, 1, 0, 0],
        [1, 0, 1, 0],
        [0, 1, 0, 1],
        [0, 0, 1, 1],
    ]
    let result = maximumMatching(edges: edges, mCount: 4, nCount: 4)
    #expect(result == 4, "This pathological case should find 4 matches")
}

/// Test with non-binary weights (any non-zero is considered an edge)
@Test func testNonBinaryWeights() {
    let edges: [[UInt8]] = [
        [0, 2, 3],
        [4, 0, 5],
        [6, 7, 0],
    ]
    let result = maximumMatching(edges: edges, mCount: 3, nCount: 3)
    #expect(result == 3, "Graph with non-binary weights should still find 3 matches")
}

func maximumMatching(edges: [[UInt8]], mCount: Int, nCount: Int) -> Int {
    let flat = edges.flatMap { $0 }
    var mutableEdges = flat
    var seen = [Bool](repeating: false, count: nCount)
    var matches = [Int](repeating: -1, count: nCount)
    return Bipartite.maximumBipartiteMatching(
        edges: &mutableEdges,
        pipCount: mCount,
        landCount: nCount,
        seen: &seen,
        matches: &matches
    )
}

