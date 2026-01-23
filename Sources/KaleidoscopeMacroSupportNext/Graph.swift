import OrderedCollections
import RegexSupport

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
            uniqueKeysWithValues: getSpanningStates(from: dfa, root: dfa.start)
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
                // note: ignoring starting states (backEdges.isEmpty) who also are accepting states
                // since they have no back edges
                if !data.backEdges.isEmpty,
                   data.backEdges.all({ state in
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

            for backward in data.backEdges where reachAccept.insert(backward).inserted {
                visitStack.append(backward)
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
