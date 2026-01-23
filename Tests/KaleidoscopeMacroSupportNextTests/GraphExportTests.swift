import _RegexParser
import SnapshotTesting
import SwiftSyntax
import Testing
import TestUtils

@testable import KaleidoscopeMacroSupportNext
@testable import RegexSupport

extension SwiftSyntax.SourceLocation {
    static let dummy = SourceLocation(line: 0, column: 0, offset: 0, file: "file")
}

@Suite
struct `Graph Export Tests` {
    // MARK: - Helper Functions

    /// Parses a regex pattern string and converts it to HIRKind
    private func parseToHIR(_ pattern: String) throws -> RegexSupport.HIRKind {
        let ast = try _RegexParser.parse(pattern, .traditional)
        return try RegexSupport.HIRKind(ast)
    }

    /// Creates a Pattern from a regex string
    private func createPattern(from regexString: String) throws -> Pattern {
        let hir = try parseToHIR(regexString)
        return Pattern(
            source: .regex(regexString),
            sourceLocation: .dummy,
            hir: hir,
        )
    }

    /// Creates a Graph from an array of regex patterns
    private func exportGraphs(
        patterns: [String],
    ) throws -> (graph: Graph, dot: String, mermaid: String) {
        let leaves = try patterns.map { pattern in
            try Leaf(pattern: createPattern(from: pattern), priority: 0, kind: .skip, callback: nil)
        }
        let graph = try Graph.build(from: leaves)

        let dot = graph.exportDot()
        let mermaid = graph.exportMermaid()

        return (graph: graph, dot: dot, mermaid: mermaid)
    }

    // MARK: - Fork Tests

    @Test
    func `fork graph test`() throws {
        let patterns = ["[a-y]", "z"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        pattern: .init(
                            source: .regex("[a-y]"),
                            sourceLocation: .dummy,
                            hir: .class(.init(ranges: ["a" ... "y"])),
                        ),
                        priority: 0,
                        kind: .skip,
                        callback: nil,
                    ),
                    .init(
                        pattern: .init(
                            source: .regex("z"),
                            sourceLocation: .dummy,
                            hir: .literal(["z"]),
                        ),
                        priority: 0,
                        kind: .skip,
                        callback: nil,
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [
                                0 ..< 97: .dead,
                                97 ..< 122: 2,
                                122 ..< 123: 3,
                                123 ..< 256: .dead,
                            ],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [1]),
                    ],
                    start: 1,
                    patternIDs: [0, 1],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 121]), state: 1),
                            .init(byteClass: .init(ranges: [122 ... 122]), state: 2),
                        ],
                    ),
                    .init(type: .init(accept: 0)),
                    .init(type: .init(accept: 1)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    // MARK: - Rope Tests

    @Test
    func `rope graph test`() throws {
        let patterns = ["rope"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [],
                dfa: graph.dfa,
                statesData: [],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `rope with miss first test`() throws {
        let patterns = ["f(ee)?"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [],
                dfa: graph.dfa,
                statesData: [],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `rope with miss any test`() throws {
        let patterns = ["fe{0,2}"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [],
                dfa: graph.dfa,
                statesData: [],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }
}
