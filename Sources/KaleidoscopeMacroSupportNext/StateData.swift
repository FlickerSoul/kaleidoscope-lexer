public struct StateType: Hashable, Sendable {
    /// match extends from the start offset up to (but not including) the most recently read byte.
    var acceptBefore: LeafID?
    /// and the match extends from the start offset through the most recently read byte.
    var acceptCurrent: LeafID?

    init(acceptBefore: LeafID? = nil, acceptCurrent: LeafID? = nil) {
        self.acceptBefore = acceptBefore
        self.acceptCurrent = acceptCurrent
    }

    var currentOrBefore: LeafID? {
        acceptCurrent ?? acceptBefore
    }
}

public struct StateData: Hashable, Sendable {
    public struct Normal: Hashable, Sendable {
        public let byteClass: ByteClass
        public let state: State
    }

    public var type: StateType
    public var normal: [Normal]
    public var backEdges: [State]

    init(type: StateType = .init(), normal: [Normal] = [], backEdges: [State] = []) {
        self.type = type
        self.normal = normal
        self.backEdges = backEdges
    }

    mutating func setNormalEdges(_ edges: [State: ByteClass]) {
        normal = edges.map { state, byteClass in
            Normal(byteClass: byteClass, state: state)
        }
        normal.sort { lhs, rhs in
            lhs.state < rhs.state
        }
    }

    /// Add back edge while maintaining sorted order
    mutating func addBackEdge(to state: State) {
        let insertIndex = backEdges.firstIndex { $0 >= state }
        backEdges.insert(state, at: insertIndex ?? backEdges.count)
    }

    /// Determine if there exists a byte that doesn't have a next state
    func canError() -> Bool {
        let coverRanges = normal.flatMap(\.byteClass.ranges)
        let byteClass = ByteClass(ranges: coverRanges)

        guard !byteClass.isEmpty else {
            return true
        }

        guard byteClass.ranges.count == 1 else {
            return true
        }
        let range = byteClass.ranges[0]
        return range.lowerBound != UInt.min || range.upperBound != UInt.max
    }
}
