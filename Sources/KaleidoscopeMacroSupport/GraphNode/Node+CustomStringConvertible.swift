//
//  Node+CustomStringConvertible.swift
//
//
//  Created by Larry Zeng on 12/22/23.
//

extension Node: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .leaf(content):
            content.description
        case let .branch(content):
            content.description
        case let .seq(content):
            content.description
        }
    }
}
