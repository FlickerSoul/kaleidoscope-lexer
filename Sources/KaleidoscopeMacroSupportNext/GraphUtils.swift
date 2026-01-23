import RegexSupport

func getSpanningStates(from dfa: borrowing DFA, root: DFAStateID) -> [DFAStateID] {
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

extension PatternID {
    var asIndex: Int {
        Int(id)
    }

    var asLeafId: LeafID {
        LeafID(.init(id))
    }
}

func getStateType(
    on dfa: borrowing DFA,
    stateID: DFAStateID,
    leaves: borrowing [Leaf],
) throws(GraphError) -> StateType {
    // LeafID are the same as PatternID, since they are inserted in the same order
    let leaves: [(leafID: LeafID, leafPriority: UInt)] = dfa.matchingPatterns(stateID).map {
        patternId in
        (patternId.asLeafId, leaves[patternId.asIndex].priority)
    }

    guard let maxPriorityLeaf = leaves.max(by: { $0.leafPriority < $1.leafPriority }) else {
        return StateType()
    }

    let maxPriorityLeaves = leaves.filter { $0.leafPriority == maxPriorityLeaf.leafPriority }
    if maxPriorityLeaves.count > 1 {
        throw GraphError.multipleLeavesWithSamePriority(
            Set(maxPriorityLeaves.map(\.leafID)), priority: maxPriorityLeaf.leafPriority,
        )
    }

    return .init(accept: maxPriorityLeaf.leafID, early: nil)
}
