import _RegexParser
@testable import KaleidoscopeMacroSupportNext
@testable import RegexSupport
import SnapshotTesting
import SwiftSyntax
import Testing
import TestUtils

extension Syntax {
    static let dummy = Syntax(ExprSyntax(""))
}

extension Leaf {
    init(
        source: PatternKind,
        hir: Pattern.HIR,
        priority: Int = 0,
    ) {
        self.init(
            pattern: .init(
                kind: source,
                hir: hir,
                source: .dummy,
            ),
            priority: priority,
            kind: .skip,
            callback: nil,
        )
    }
}

@Suite(.snapshots(record: .failed))
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
            kind: .regex(regexString),
            hir: hir,
            source: .dummy,
        )
    }

    /// Creates a Graph from an array of regex patterns
    private func exportGraphs(
        patterns: [String],
    ) throws -> (graph: Graph, dot: String, mermaid: String) {
        let leaves = try patterns.map { pattern in
            try Leaf(source: .regex(pattern), hir: parseToHIR(pattern))
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
                        source: .regex("[a-y]"),
                        hir: .class(.init(ranges: ["a" ... "y"])),
                    ),
                    .init(
                        source: .regex("z"),
                        hir: .literal(["z"]),
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
                    .init(type: .init(acceptCurrent: 0)),
                    .init(type: .init(acceptCurrent: 1)),
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
                leaves: [
                    .init(
                        source: .regex("rope"),
                        hir: .concat([
                            .literal(["r"]), .literal(["o"]), .literal(["p"]), .literal(["e"]),
                        ]),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 114: .dead, 114 ..< 115: 2, 115 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 111: .dead, 111 ..< 112: 3, 112 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 112: .dead, 112 ..< 113: 4, 113 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 101: .dead, 101 ..< 102: 5, 102 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [114 ... 114]), state: 1),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [111 ... 111]), state: 2),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [112 ... 112]), state: 3),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [101 ... 101]), state: 4),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
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
                leaves: [
                    .init(
                        source: .regex("f(ee)?"),
                        hir: .concat([
                            .literal(["f"]),
                            .quantification(
                                .init(
                                    min: 0, max: 1, isEager: true,
                                    child: .group(
                                        .init(
                                            child: .concat([.literal(["e"]), .literal(["e"])]),
                                        ),
                                    ),
                                ),
                            ),
                        ]),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 102: .dead, 102 ..< 103: 2, 103 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 101: .dead, 101 ..< 102: 3, 102 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                        DFAState(
                            transitions: [0 ..< 101: .dead, 101 ..< 102: 4, 102 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [102 ... 102]), state: 1),
                        ],
                    ),
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [101 ... 101]), state: 2),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [101 ... 101]), state: 3),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
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
                leaves: [
                    .init(
                        source: .regex("fe{0,2}"),
                        hir: .concat([
                            .literal(["f"]),
                            .quantification(
                                .init(
                                    min: 0, max: 2, isEager: true,
                                    child: .literal(["e"]),
                                ),
                            ),
                        ]),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 102: .dead, 102 ..< 103: 2, 103 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 101: .dead, 101 ..< 102: 3, 102 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                        DFAState(
                            transitions: [0 ..< 101: .dead, 101 ..< 102: 4, 102 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [102 ... 102]), state: 1),
                        ],
                    ),
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [101 ... 101]), state: 2),
                        ],
                    ),
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [101 ... 101]), state: 3),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    // MARK: - Additional Test Cases for Edge Cases and Combinations

    @Test
    func `single character test`() throws {
        let patterns = ["x"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("x"),
                        hir: .literal(["x"]),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 120: .dead, 120 ..< 121: 2, 121 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [120 ... 120]), state: 1),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `two disjoint characters test`() throws {
        let patterns = ["x", "y"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("x"),
                        hir: .literal(["x"]),
                    ),
                    .init(
                        source: .regex("y"),
                        hir: .literal(["y"]),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [
                                0 ..< 120: .dead,
                                120 ..< 121: 2,
                                121 ..< 122: 3,
                                122 ..< 256: .dead,
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
                            .init(byteClass: .init(ranges: [120 ... 120]), state: 1),
                            .init(byteClass: .init(ranges: [121 ... 121]), state: 2),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                    .init(type: .init(acceptCurrent: 1)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `alternation in pattern test`() throws {
        let patterns = ["(a|b)"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("(a|b)"),
                        hir: .group(
                            .init(child: .alternation([.literal(["a"]), .literal(["b"])])),
                        ),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 99: 2, 99 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 98]), state: 1),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `optional character test`() throws {
        let patterns = ["a?"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("a?"),
                        hir: .quantification(
                            .init(min: 0, max: 1, isEager: true, child: .literal(["a"])),
                        ),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 2, 98 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 1),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `character class range test`() throws {
        let patterns = ["[a-c]"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("[a-c]"),
                        hir: .class(.init(ranges: ["a" ... "c"])),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 100: 2, 100 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 99]), state: 1),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `three character fork test`() throws {
        let patterns = ["a", "b", "c"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("a"),
                        hir: .literal(["a"]),
                    ),
                    .init(
                        source: .regex("b"),
                        hir: .literal(["b"]),
                    ),
                    .init(
                        source: .regex("c"),
                        hir: .literal(["c"]),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [
                                0 ..< 97: .dead,
                                97 ..< 98: 2,
                                98 ..< 99: 3,
                                99 ..< 100: 4,
                                100 ..< 256: .dead,
                            ],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [1]),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [2]),
                    ],
                    start: 1,
                    patternIDs: [0, 1, 2],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 1),
                            .init(byteClass: .init(ranges: [98 ... 98]), state: 2),
                            .init(byteClass: .init(ranges: [99 ... 99]), state: 3),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                    .init(type: .init(acceptCurrent: 1)),
                    .init(type: .init(acceptCurrent: 2)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `two words with common prefix test`() throws {
        let patterns = ["hello", "help"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("hello"),
                        hir: .concat([
                            .literal(["h"]), .literal(["e"]), .literal(["l"]), .literal(["l"]),
                            .literal(["o"]),
                        ]),
                    ),
                    .init(
                        source: .regex("help"),
                        hir: .concat([
                            .literal(["h"]), .literal(["e"]), .literal(["l"]), .literal(["p"]),
                        ]),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 104: .dead, 104 ..< 105: 2, 105 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 101: .dead, 101 ..< 102: 3, 102 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 108: .dead, 108 ..< 109: 4, 109 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [
                                0 ..< 108: .dead,
                                108 ..< 109: 5,
                                109 ..< 112: .dead,
                                112 ..< 113: 6,
                                113 ..< 256: .dead,
                            ],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 111: .dead, 111 ..< 112: 7, 112 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [1]),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0, 1],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [104 ... 104]), state: 1),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [101 ... 101]), state: 2),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [108 ... 108]), state: 3),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [108 ... 108]), state: 4),
                            .init(byteClass: .init(ranges: [112 ... 112]), state: 5),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [111 ... 111]), state: 6),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 1)),
                    .init(type: .init(acceptCurrent: 0)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `plus quantifier test`() throws {
        let patterns = ["a+"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("a+"),
                        hir: .quantification(
                            .init(min: 1, max: nil, isEager: true, child: .literal(["a"])),
                        ),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 2, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 2, 98 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 1),
                        ],
                    ),
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 1),
                        ],
                    ),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `kleene star test`() throws {
        let patterns = ["a*"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("a*"),
                        hir: .quantification(
                            .init(min: 0, max: nil, isEager: true, child: .literal(["a"])),
                        ),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 2, 98 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 2, 98 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 0),
                        ],
                    ),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `exact repetition test`() throws {
        let patterns = ["a{3}"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("a{3}"),
                        hir: .quantification(
                            .init(min: 3, max: 3, isEager: true, child: .literal(["a"])),
                        ),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 2, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 3, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 4, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 1),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 2),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 3),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `ranged repetition test`() throws {
        let patterns = ["a{3,5}"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("a{3,5}"),
                        hir: .quantification(
                            .init(min: 3, max: 5, isEager: true, child: .literal(["a"])),
                        ),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 2, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 3, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 4, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 5, 98 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 6, 98 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 1),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 2),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 3),
                        ],
                    ),
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 4),
                        ],
                    ),
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 5),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `at least n repetition test`() throws {
        let patterns = ["a{4,}"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("a{4,}"),
                        hir: .quantification(
                            .init(min: 4, max: nil, isEager: true, child: .literal(["a"])),
                        ),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 2, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 3, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 4, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 5, 98 ..< 256: .dead],
                            matchPatternIDs: [],
                        ),
                        DFAState(
                            transitions: [0 ..< 97: .dead, 97 ..< 98: 5, 98 ..< 256: .dead],
                            matchPatternIDs: [0],
                        ),
                    ],
                    start: 1,
                    patternIDs: [0],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 1),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 2),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 3),
                        ],
                    ),
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 4),
                        ],
                    ),
                    .init(
                        type: .init(acceptCurrent: 0),
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 97]), state: 4),
                        ],
                    ),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `two disjoint character classes test`() throws {
        let patterns = ["[a-c]", "[x-z]"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("[a-c]"),
                        hir: .class(.init(ranges: ["a" ... "c"])),
                    ),
                    .init(
                        source: .regex("[x-z]"),
                        hir: .class(.init(ranges: ["x" ... "z"])),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [
                                0 ..< 97: .dead,
                                97 ..< 100: 2,
                                100 ..< 120: .dead,
                                120 ..< 123: 3,
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
                            .init(byteClass: .init(ranges: [97 ... 99]), state: 1),
                            .init(byteClass: .init(ranges: [120 ... 122]), state: 2),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                    .init(type: .init(acceptCurrent: 1)),
                ],
                root: 0,
                errors: [],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }

    @Test
    func `overlapping character classes`() throws {
        let patterns = ["[a-l]", "[f-z]"]
        let (graph, dot, mermaid) = try exportGraphs(patterns: patterns)

        equals(
            actual: graph,
            expected: .init(
                leaves: [
                    .init(
                        source: .regex("[a-l]"),
                        hir: .class(.init(ranges: ["a" ... "l"])),
                    ),
                    .init(
                        source: .regex("[f-z]"),
                        hir: .class(.init(ranges: ["f" ... "z"])),
                    ),
                ],
                dfa: .init(
                    states: [
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: []),
                        DFAState(
                            transitions: [
                                0 ..< 97: .dead,
                                97 ..< 102: 2,
                                102 ..< 109: 3,
                                109 ..< 123: 4,
                                123 ..< 256: .dead,
                            ],
                            matchPatternIDs: [],
                        ),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [0]),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [1, 0]),
                        DFAState(transitions: [0 ..< 256: .dead], matchPatternIDs: [1]),
                    ],
                    start: 1,
                    patternIDs: [0, 1],
                ),
                statesData: [
                    .init(
                        normal: [
                            .init(byteClass: .init(ranges: [97 ... 101]), state: 1),
                            // overlapped range (102 ... 108) throws error
                            .init(byteClass: .init(ranges: [109 ... 122]), state: 2),
                        ],
                    ),
                    .init(type: .init(acceptCurrent: 0)),
                    .init(type: .init(acceptCurrent: 1)),
                ],
                root: 0,
                errors: [
                    .multipleLeavesWithSamePriority([0, 1], priority: 0),
                ],
            ),
        )

        assertSnapshot(of: dot, as: .lines, named: "dot")
        assertSnapshot(of: mermaid, as: .lines, named: "mermaid")
    }
}
