//
//  Node+Hashable.swift
//
//
//  Created by Larry Zeng on 12/22/23.
//

extension Node: Hashable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        switch (lhs, rhs) {
        case let (.leaf(lhsLeaf), .leaf(rhsLeaf)):
            lhsLeaf == rhsLeaf
        case let (.branch(lhsBranch), .branch(rhsBranch)):
            lhsBranch == rhsBranch
        case let (.seq(lhsSeq), .seq(rhsSeq)):
            lhsSeq == rhsSeq
        case _:
            false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .leaf(leaf):
            leaf.hash(into: &hasher)
        case let .branch(branch):
            branch.hash(into: &hasher)
        case let .seq(seq):
            seq.hash(into: &hasher)
        }
    }
}
