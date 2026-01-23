import OrderedCollections
import RegexSupport

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

    // Add back edge while maintaining sorted order
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

public struct State: Hashable, Sendable, Comparable, Strideable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public let id: Int

    init(_ id: Int) {
        self.id = id
    }

    public init(integerLiteral value: Int) {
        id = value
    }

    public static func < (lhs: State, rhs: State) -> Bool {
        lhs.id < rhs.id
    }

    public func distance(to other: State) -> Int {
        other.id - id
    }

    public func advanced(by n: Int) -> State {
        State(id + n)
    }
}

public enum GraphError: Error, Hashable, Sendable {
    case multipleLeavesWithSamePriority([Leaf], priority: UInt)
}

public struct Graph: Hashable, Sendable {
    public let leaves: [Leaf]
    public let dfa: DFA
    public internal(set) var statesData: [StateData]
    public internal(set) var root: State
    public internal(set) var errors: [GraphError]

    init(leaves: [Leaf], dfa: DFA, statesData: [StateData], root: State, errors: [GraphError]) {
        self.leaves = leaves
        self.dfa = dfa
        self.statesData = statesData
        self.root = root
        self.errors = errors
    }

    init(leaves: [Leaf], dfa: DFA) {
        self.leaves = leaves
        self.dfa = dfa
        statesData = []
        root = .init(0)
        errors = []
    }

    func states() -> Range<State> {
        0 ..< State(statesData.count)
    }

    func getStateData(_ state: State) -> StateData {
        statesData[state.id]
    }
}

extension Graph {
    static func build(from leaves: [Leaf]) throws -> Graph {
        let hirs = leaves.map(\.pattern.hir)

        let nfa = try NFA.build(from: hirs)
        let dfa = try DFA.build(from: nfa)

        var graph = Graph(leaves: leaves, dfa: dfa)

        let dfaStartId = dfa.start
        let dfaLookup = OrderedDictionary(
            uniqueKeysWithValues: getStates(from: dfa, root: dfa.start)
                .enumerated()
                .map { index, stateID in
                    (stateID, State(index))
                },
        )

        graph.root = dfaLookup[dfaStartId]! // start is guaranteed to be present
        graph.statesData = .init(repeating: .init(), count: dfaLookup.count)

        graph.constructEdgeAndLeaf(from: dfaLookup)

        graph.resolveEarlyMatch()

        graph.pruneUnreachable()

        return graph
    }

    private mutating func constructEdgeAndLeaf(
        from dfaLookup: consuming OrderedDictionary<DFAStateID, State>,
    ) {
        for (dfaStateID, state) in dfaLookup {
            let stateType = Result { () throws(GraphError) in
                try getStateType(
                    on: dfa,
                    stateID: dfaStateID,
                    leaves: leaves,
                )
            }
            switch stateType {
            case let .success(type):
                statesData[state.id].type = type
            case let .failure(error):
                errors.append(error)
            }

            var result: [State: ByteClass] = [:]
            for byte in 0 ... UInt8.max {
                let nextStateID = dfa.nextState(dfaStateID, byte: byte)
                guard nextStateID != .dead else {
                    continue
                }

                if let nextState = dfaLookup[nextStateID] {
                    // Add transition from `state` to `nextState` on `byte`
                    // (Implementation of transitions is not shown in this snippet)
                    result[nextState, default: ByteClass()].addSingle(byte)
                }
            }

            statesData[state.id].setNormalEdges(result)

            for child in statesData[state.id].normal.map(\.state) {
                statesData[child.id].addBackEdge(to: state)
            }
        }
    }

    private mutating func resolveEarlyMatch() {
        // Find early accept state
        for state: State in states() {
            let data = getStateData(state)

            if !data.canError() {
                let childrenAcceptStates = Set(
                    data.normal
                        .map(\.state)
                        .map { state in
                            self.getStateData(state).type.accept
                        },
                )

                if childrenAcceptStates.count == 1,
                   case let .some(earlyAccept) = childrenAcceptStates.first {
                    statesData[state.id].type.early = earlyAccept
                }
            }
        }

        // Remove late matches when all incoming edges contain an early match
        for state: State in states() {
            let data = getStateData(state)

            if let acceptLeaf = data.type.accept {
                if data.backEdges.all({ state in
                    self.getStateData(state).type.early == acceptLeaf
                }) {
                    statesData[state.id].type.accept = nil
                }
            }
        }
    }

    private mutating func pruneUnreachable() {
        // prune unreachable states
        var visitStack = states().filter { state in
            self.getStateData(state).type.earlyOrAccept != nil
        }
        visitStack.append(root)

        var reachAccept = Set<State>(visitStack)

        while let state = visitStack.popLast() {
            let data = getStateData(state)

            for backward in data.backEdges {
                if reachAccept.insert(backward).inserted {
                    visitStack.append(backward)
                }
            }
        }

        for state in states() {
            statesData[state.id].normal =
                statesData[state.id].normal.filter { normal in
                    reachAccept.contains(normal.state)
                }
            statesData[state.id].backEdges.removeAll()
        }

        retainStates(reachAccept, keep: true)

        // deduplicate states

        while true {
            let graphSize = statesData.count
            var stateIndexes = OrderedDictionary<StateData, State>()
            var stateLookup = [State: State]()

            for state in states() {
                let data = getStateData(state)

                if let existing = stateIndexes[data] {
                    stateLookup[state] = existing
                } else {
                    stateIndexes[data] = state
                }
            }

            rewriteStates(stateLookup)
            retainStates(.init(stateLookup.keys), keep: false)

            if statesData.count == graphSize {
                break
            }
        }
    }

    private mutating func retainStates(_ statesToRetain: borrowing Set<State>, keep: Bool) {
        let rewriteMap = Dictionary(
            uniqueKeysWithValues: states()
                .filter { state in
                    statesToRetain.contains(state) == keep
                }
                .enumerated()
                .map { newIndex, oldIndex in
                    (oldIndex, State(newIndex))
                },
        )

        var index = 0
        statesData = statesData.filter { _ in
            let retain = statesToRetain.contains(State(index)) == keep
            index += 1
            return retain
        }

        rewriteStates(rewriteMap)
    }

    private mutating func rewriteStates(_ rewriteMap: borrowing [State: State]) {
        for state in states() {
            let data = statesData[state.id]

            var edgeDedup = [State: ByteClass]()

            for normal in data.normal {
                let nextState = rewriteMap[normal.state] ?? normal.state
                if edgeDedup[nextState] != nil {
                    edgeDedup[nextState]?.union(normal.byteClass)
                } else {
                    edgeDedup[nextState] = normal.byteClass
                }
            }

            statesData[state.id].setNormalEdges(edgeDedup)
        }

        if let newRoot = rewriteMap[root] {
            root = newRoot
        }
    }
}

public typealias ByteClass = RangeSet<UInt8>

func getStates(from dfa: borrowing DFA, root: DFAStateID) -> [DFAStateID] {
    var states = Set<DFAStateID>()
    states.insert(root)

    var exploreStack = [DFAStateID]()
    exploreStack.append(root)

    while let next = exploreStack.popLast() {
        let children = childrenStates(on: dfa, from: next)
        for child in children {
            if states.insert(child).inserted {
                exploreStack.append(child)
            }
        }
    }

    return states.sorted()
}

func childrenStates(on dfa: borrowing DFA, from currentState: DFAStateID) -> [DFAStateID] {
    (0 ... UInt8.max)
        .map { byte in
            dfa.nextState(currentState, byte: byte)
        }
    // TODO: integrate EOI when we have look
}

public struct LeafId: Hashable, Sendable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public let id: IntegerLiteralType

    public init(integerLiteral value: IntegerLiteralType) {
        id = value
    }

    init(_ id: IntegerLiteralType) {
        self.id = id
    }
}

public struct StateType: Hashable, Sendable {
    var accept: LeafId?
    var early: LeafId?

    init(accept: LeafId? = nil, early: LeafId? = nil) {
        self.accept = accept
        self.early = early
    }

    var earlyOrAccept: LeafId? {
        early ?? accept
    }
}

extension PatternID {
    var asIndex: Int {
        Int(id)
    }

    var asLeafId: LeafId {
        LeafId(.init(id))
    }
}

func getStateType(
    on dfa: borrowing DFA,
    stateID: DFAStateID,
    leaves: borrowing [Leaf],
) throws(GraphError) -> StateType {
    let leaves: [(leafId: LeafId, leaf: Leaf)] = dfa.matchingPatterns(stateID).map { patternId in
        (patternId.asLeafId, leaves[patternId.asIndex])
    }

    guard let maxPriorityLeaf = leaves.max(by: { $0.leaf.priority < $1.leaf.priority }) else {
        return StateType()
    }

    let maxPriorityLeaves = leaves.filter { $0.leaf.priority == maxPriorityLeaf.leaf.priority }
    if maxPriorityLeaves.count > 1 {
        throw GraphError.multipleLeavesWithSamePriority(
            maxPriorityLeaves.map(\.leaf), priority: maxPriorityLeaf.leaf.priority,
        )
    }

    return .init(accept: maxPriorityLeaf.leafId, early: nil)
}
