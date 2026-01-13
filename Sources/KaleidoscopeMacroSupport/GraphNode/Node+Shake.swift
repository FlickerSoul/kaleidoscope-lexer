//
//  Node+Shake.swift
//
//
//  Created by Larry Zeng on 12/22/23.
//

func shakeId(
    marks: inout [Bool],
    oldId: NodeId,
    indexMapping: inout [Int?],
    newNodes: inout [Node?],
    graph: inout Graph,
) throws -> NodeId {
    let oldIndex = Int(oldId)
    guard let newIndex = indexMapping[oldIndex] else {
        throw GraphError.shakingError("Cannot Find Shaked Index Of Node \(oldIndex)")
    }
    let newId = NodeId(newIndex)

    if marks[oldIndex] {
        try graph.get(node: oldId)?.shake(
            marks: &marks,
            indexMapping: &indexMapping,
            newNodes: &newNodes,
            oldIndex: oldIndex,
            newIndex: newIndex,
            graph: &graph,
        )
    }

    return newId
}

extension Node {
    /// Mark used node in order to shake out unused ones.
    func shake(marks: inout [Bool], index: Int, graph: inout Graph) throws {
        marks[index] = true

        switch self {
        case .leaf:
            break
        case let .branch(branchContent):
            for branchId in branchContent.branches.values {
                let nodeIndex = Int(branchId)
                if !marks[nodeIndex] {
                    guard let node = graph.get(node: branchId) else {
                        throw GraphError.shakingError("Node \(branchId) is nil")
                    }

                    try node.shake(marks: &marks, index: nodeIndex, graph: &graph)
                }
            }

            if let missId = branchContent.miss {
                let nodeIndex = Int(missId)
                if !marks[nodeIndex] {
                    guard let node = graph.get(node: missId) else {
                        throw GraphError.shakingError("Node \(missId) is nil")
                    }

                    try node.shake(marks: &marks, index: nodeIndex, graph: &graph)
                }
            }
        case let .seq(seqContent):
            let thenIndex = Int(seqContent.then)
            if !marks[thenIndex] {
                guard let thenNode = graph.get(node: seqContent.then) else {
                    throw GraphError.shakingError("Node \(seqContent.then) is nil")
                }
                try thenNode.shake(marks: &marks, index: thenIndex, graph: &graph)
            }

            if let missId = seqContent.miss?.miss {
                let missIndex = Int(missId)
                if !marks[missIndex] {
                    guard let missNode = graph.get(node: missId) else {
                        throw GraphError.shakingError("Node \(missId) is nil")
                    }

                    try missNode.shake(marks: &marks, index: missIndex, graph: &graph)
                }
            }
        }
    }

    /// Shake the nodes into the right places.
    func shake( // swiftlint:disable:this function_parameter_count
        marks: inout [Bool],
        indexMapping: inout [Int?],
        newNodes: inout [Node?],
        oldIndex: Int,
        newIndex: Int,
        graph: inout Graph,
    ) throws {
        marks[oldIndex] = false

        switch self {
        case .leaf:
            newNodes[newIndex] = self
        case let .branch(branchContent):
            var newBranches: [BranchHit: NodeId] = [:]

            for (char, branchId) in branchContent.branches {
                newBranches[char] = try shakeId(
                    marks: &marks,
                    oldId: branchId,
                    indexMapping: &indexMapping,
                    newNodes: &newNodes,
                    graph: &graph,
                )
            }

            var newMiss: NodeId?
            if let missId = branchContent.miss {
                newMiss = try shakeId(
                    marks: &marks,
                    oldId: missId,
                    indexMapping: &indexMapping,
                    newNodes: &newNodes,
                    graph: &graph,
                )
            }

            newNodes[newIndex] = Node.branch(.init(branches: newBranches, miss: newMiss))
        case let .seq(seqContent):
            let newThenId = try shakeId(
                marks: &marks,
                oldId: seqContent.then,
                indexMapping: &indexMapping,
                newNodes: &newNodes,
                graph: &graph,
            )

            var miss: Node.SeqMiss?
            if let seqMiss = seqContent.miss {
                switch seqMiss {
                case let .anytime(id):
                    miss = try .anytime(shakeId(
                        marks: &marks,
                        oldId: id,
                        indexMapping: &indexMapping,
                        newNodes: &newNodes,
                        graph: &graph,
                    ))
                case let .first(id):
                    miss = try .first(shakeId(
                        marks: &marks,
                        oldId: id,
                        indexMapping: &indexMapping,
                        newNodes: &newNodes,
                        graph: &graph,
                    ))
                }
            }

            newNodes[newIndex] = Node.seq(.init(seq: seqContent.seq, then: NodeId(newThenId), miss: miss))
        }
    }
}
