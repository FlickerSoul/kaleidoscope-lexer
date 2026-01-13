//
//  Generator.swift
//
//
//  Created by Larry Zeng on 12/4/23.
//

import KaleidoscopeMacroSupport
import SwiftSyntax
import SwiftSyntaxBuilder

// MARK: - Generator

enum GeneratorError: Error {
    case buildingEmptyNode
}

/// Generates the lexer code
struct Generator {
    let graph: Graph
    let enumIdent: String

    @CodeBlockItemListBuilder
    mutating func buildFunctions() throws -> CodeBlockItemListSyntax {
        for (nodeId, node) in graph.nodes.enumerated() {
            let ident = generateFuncIdent(nodeId: nodeId)

            try FunctionDeclSyntax("func \(raw: ident)(_ lexer: inout LexerMachine<Self>) throws") {
                switch node {
                case let .leaf(content):
                    buildLeaf(node: content)
                case let .branch(content):
                    try buildBranch(node: content)
                case let .seq(content):
                    try buildSeq(node: content)
                case nil:
                    throw GeneratorError.buildingEmptyNode
                }
            }
        }
    }

    /// Generate leaf lexer handles, based on the token type
    /// - Parameters:
    ///     - node: the leaf graph node
    func buildLeaf(node: Node.LeafContent) -> CodeBlockItemListSyntax {
        let end = graph.inputs[node.endId]
        return CodeBlockItemListSyntax {
            switch end.tokenType {
            case .skip:
                "try lexer.skip()"
            case .standalone:
                "try lexer.setToken(\(raw: enumIdent).\(raw: end.token))"
            case let .fillCallback(callbackDetail):
                switch callbackDetail {
                case let .named(ident):
                    "try lexer.setToken(\(raw: enumIdent).\(raw: end.token)(\(raw: ident)(&lexer)))"
                case let .lambda(lambda):
                    "try lexer.setToken(\(raw: enumIdent).\(raw: end.token)(\(raw: lambda)(&lexer)))"
                }
            case let .createCallback(callbackDetail):
                switch callbackDetail {
                case let .named(ident):
                    "try lexer.setToken(\(raw: ident)(&lexer))"
                case let .lambda(lambda):
                    "try lexer.setToken(\(raw: lambda)(&lexer))"
                }
            }
        }
    }

    /// Generate branch lexer handles, where each branch corresponds to a swift case.
    /// Cases in the swift are grouped to reduce file length and complexity.
    /// - Parameters:
    ///     - node: the branch graph node
    func buildBranch(node: Node.BranchContent) throws -> CodeBlockItemListSyntax {
        var mergeCaes: [NodeId: [Node.BranchHit]] = [:]
        for (hit, nodeId) in node.branches {
            if mergeCaes[nodeId] == nil {
                mergeCaes[nodeId] = []
            }

            mergeCaes[nodeId]!.append(hit)
        }

        let miss: ExprSyntax = if let missId = node.miss {
            "try \(raw: generateFuncIdent(nodeId: missId))(&lexer)"
        } else {
            "try lexer.error()"
        }

        return try CodeBlockItemListSyntax {
            try GuardStmtSyntax("guard let scalar = lexer.peak() else {") {
                miss
                "return"
            }

            try SwitchExprSyntax("switch scalar") {
                for (nodeId, cases) in mergeCaes {
                    let caseString = cases.map { $0.toCode() }.joined(separator: ", ")
                    """
                    case \(raw: caseString):
                        try lexer.bump()
                        try \(raw: generateFuncIdent(nodeId: nodeId))(&lexer)
                    """
                }

                """
                case _:
                    \(miss)
                """
            }
        }
    }

    func buildSeq(node: Node.SeqContent) throws -> CodeBlockItemListSyntax {
        let miss: ExprSyntax = if let missId = node.miss?.miss {
            "try \(raw: generateFuncIdent(nodeId: missId))(&lexer)"
        } else {
            "try lexer.error()"
        }

        return try CodeBlockItemListSyntax {
            """
            guard let scalars = lexer.peak(for: \(raw: node.seq.count)) else {
                \(miss)
                return
            }
            """

            try IfExprSyntax("if \(raw: node.seq.toCode()) == scalars") {
                """
                try lexer.bump(by: \(raw: node.seq.count))
                try \(raw: generateFuncIdent(nodeId: node.then))(&lexer)
                """
            } else: {
                miss
            }
        }
    }

    /// Generate function identifier based for a graph node.
    /// - Parameters:
    ///   - nodeId: the ID of the node in the graph
    func generateFuncIdent(nodeId: UInt) -> String {
        generateFuncIdent(nodeId: Int(nodeId))
    }

    /// Generate function identifier given an integer, usually the node ID
    func generateFuncIdent(nodeId: Int) -> String {
        "jumpTo_\(nodeId)"
    }
}
