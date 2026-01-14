//
//  GraphExportTests.swift
//
//
//  Created by Larry Zeng on 1/14/26.
//

@testable import KaleidoscopeMacroSupport
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed))
struct GraphExportTests {
    private func buildGraph(regexes: [String]) throws -> Graph {
        var graph = Graph()
        for (index, regex) in regexes.enumerated() {
            let hir = try HIR(regex: regex)
            try graph.push(input: .init(
                token: "Token\(index)",
                tokenType: .standalone,
                hir: hir,
            ))
        }
        _ = try graph.makeRoot()
        _ = try graph.shake()
        return graph
    }

    @Test(arguments: [GraphExportFormat.dot, GraphExportFormat.mermaid])
    func fork(format: GraphExportFormat) throws {
        let graph = try buildGraph(regexes: ["[a-y]", "z"])
        let output = graph.export(to: format)
        assertSnapshot(of: output, as: .lines, named: "\(format)")
    }

    @Test(arguments: [GraphExportFormat.dot, GraphExportFormat.mermaid])
    func rope(format: GraphExportFormat) throws {
        let graph = try buildGraph(regexes: ["rope"])
        let output = graph.export(to: format)
        assertSnapshot(of: output, as: .lines, named: "\(format)")
    }

    @Test(arguments: [GraphExportFormat.dot, GraphExportFormat.mermaid])
    func ropeWithMissFirst(format: GraphExportFormat) throws {
        let graph = try buildGraph(regexes: ["f(ee)?"])
        let output = graph.export(to: format)
        assertSnapshot(of: output, as: .lines, named: "\(format)")
    }

    @Test(arguments: [GraphExportFormat.dot, GraphExportFormat.mermaid])
    func ropeWithMissAny(format: GraphExportFormat) throws {
        let graph = try buildGraph(regexes: ["fe{0,2}"])
        let output = graph.export(to: format)
        assertSnapshot(of: output, as: .lines, named: "\(format)")
    }

    @Test(arguments: [GraphExportFormat.dot, GraphExportFormat.mermaid])
    func multiplePatternFork(format: GraphExportFormat) throws {
        let graph = try buildGraph(regexes: ["ab", "abcd"])
        let output = graph.export(to: format)
        assertSnapshot(of: output, as: .lines, named: "\(format)")
    }

    @Test(arguments: [GraphExportFormat.dot, GraphExportFormat.mermaid])
    func multiplePatternsInterFork(format: GraphExportFormat) throws {
        let graph = try buildGraph(regexes: ["ab", "bcd", "de", "cda", "a?"])
        let output = graph.export(to: format)
        assertSnapshot(of: output, as: .lines, named: "\(format)")
    }
}
