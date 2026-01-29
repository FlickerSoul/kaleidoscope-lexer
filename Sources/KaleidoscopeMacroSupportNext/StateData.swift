public struct StateType: Hashable, Sendable {
    var accept: LeafID?
    var early: LeafID?

    init(accept: LeafID? = nil, early: LeafID? = nil) {
        self.accept = accept
        self.early = early
    }

    var earlyOrAccept: LeafID? {
        early ?? accept
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
