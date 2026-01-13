//
//  NodeLeaf.swift
//
//
//  Created by Larry Zeng on 12/22/23.
//

public extension Node {
    struct LeafContent: Hashable, Copy, IntoNode {
        public var endId: EndsId

        public static func == (lhs: Node.LeafContent, rhs: Node.LeafContent) -> Bool {
            lhs.endId == rhs.endId
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(endId)
        }

        public func copy() -> Self {
            .init(endId: endId)
        }

        public func into() -> Node {
            .leaf(self)
        }
    }
}

extension Node.LeafContent: CustomStringConvertible {
    public var description: String {
        "@\(endId)"
    }
}
