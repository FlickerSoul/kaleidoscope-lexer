//
//  DFATests.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/20/26.
//

import Foundation
import Testing

@testable import RegexSupport

// MARK: - DFA Test Helpers

/// Simulate DFA execution on input
private func matches(_ dfa: borrowing DFA, input: any Sequence<UInt8>) -> Bool {
    var state = dfa.start
    for byte in input {
        state = dfa.nextState(state, byte: byte)
        if state == .dead {
            return false
        }
    }
    return dfa.isMatch(state)
}

/// Simulate DFA execution and get matching patterns
private func matchingPatterns(_ dfa: borrowing DFA, input: any Sequence<UInt8>) -> [PatternID] {
    var state = dfa.start
    for byte in input {
        state = dfa.nextState(state, byte: byte)
        if state == .dead {
            return []
        }
    }
    return dfa.isMatch(state) ? dfa.matchingPatterns(state) : []
}

private struct MatchInput {
    let representation: String
    let input: any Sequence<UInt8>
    let shouldMatch: Bool
    let sourceLocation: SourceLocation

    private init(
        representation: String,
        input: any Sequence<UInt8>,
        shouldMatch: Bool,
        sourceLocation: SourceLocation,
    ) {
        self.representation = representation
        self.input = input
        self.shouldMatch = shouldMatch
        self.sourceLocation = sourceLocation
    }

    static func match(
        _ input: String,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column,
    ) -> MatchInput {
        .init(
            representation: input,
            input: input.utf8,
            shouldMatch: true,
            sourceLocation: .init(
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column,
            ),
        )
    }

    static func noMatch(
        _ input: String,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column,
    ) -> MatchInput {
        .init(
            representation: input,
            input: input.utf8,
            shouldMatch: false,
            sourceLocation: .init(
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column,
            ),
        )
    }

    static func match(
        _ input: [UInt8],
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column,
    ) -> MatchInput {
        .init(
            representation: input.hexString(),
            input: input,
            shouldMatch: true,
            sourceLocation: .init(
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column,
            ),
        )
    }

    static func noMatch(
        _ input: [UInt8],
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column,
    ) -> MatchInput {
        .init(
            representation: input.hexString(),
            input: input,
            shouldMatch: false,
            sourceLocation: .init(
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column,
            ),
        )
    }
}

private func assertMatches(_ inputs: MatchInput..., on dfa: borrowing DFA) {
    for input in inputs {
        print("Matching \(input.representation)")

        let inputMatch = matches(dfa, input: input.input)
        #expect(
            inputMatch == input.shouldMatch,
            "\(input.representation) should \(input.shouldMatch ? "" : "not ")match, but did \(inputMatch ? "" : "not ")",
            sourceLocation: input.sourceLocation,
        )
    }
}

private func dfa(from hir: HIRKind) throws -> DFA {
    let nfa = try NFA.build(from: hir)
    return try Determinizer.buildDFA(from: nfa)
}

// MARK: - DFA Construction Tests

@Suite("DFA Determinization Tests")
struct DFATests {
    // MARK: Basic Construction

    @Test
    func `single character literal`() throws {
        let hir: HIRKind = .literal("a")
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []),
                    .init(deadExcept: [0x61: 2], matchPatternIDs: []),
                    .init(deadExcept: [:], matchPatternIDs: [0]),
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("a"),
            .noMatch("b"),
            .noMatch(""),
            .noMatch("aa"),
            on: dfa,
        )
    }

    @Test
    func `multiple character literal`() throws {
        let hir: HIRKind = .literal("a string".map(\.self))
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2], matchPatternIDs: []), // state 1 - start, 'a'
                    .init(deadExcept: [0x20: 3], matchPatternIDs: []), // state 2 - space
                    .init(deadExcept: [0x73: 4], matchPatternIDs: []), // state 3 - 's'
                    .init(deadExcept: [0x74: 5], matchPatternIDs: []), // state 4 - 't'
                    .init(deadExcept: [0x72: 6], matchPatternIDs: []), // state 5 - 'r'
                    .init(deadExcept: [0x69: 7], matchPatternIDs: []), // state 6 - 'i'
                    .init(deadExcept: [0x6E: 8], matchPatternIDs: []), // state 7 - 'n'
                    .init(deadExcept: [0x67: 9], matchPatternIDs: []), // state 8 - 'g'
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 9 - match
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("a string"),
            .noMatch("a"),
            .noMatch("string"),
            .noMatch("a strings"),
            on: dfa,
        )
    }

    @Test
    func `concat of literals`() throws {
        let hir: HIRKind = .concat("a string".map { char in .literal(char) })
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2], matchPatternIDs: []), // state 1 - start, 'a'
                    .init(deadExcept: [0x20: 3], matchPatternIDs: []), // state 2 - space
                    .init(deadExcept: [0x73: 4], matchPatternIDs: []), // state 3 - 's'
                    .init(deadExcept: [0x74: 5], matchPatternIDs: []), // state 4 - 't'
                    .init(deadExcept: [0x72: 6], matchPatternIDs: []), // state 5 - 'r'
                    .init(deadExcept: [0x69: 7], matchPatternIDs: []), // state 6 - 'i'
                    .init(deadExcept: [0x6E: 8], matchPatternIDs: []), // state 7 - 'n'
                    .init(deadExcept: [0x67: 9], matchPatternIDs: []), // state 8 - 'g'
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 9 - match
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("a string"),
            .noMatch("a"),
            .noMatch("string"),
            .noMatch("a strings"),
            on: dfa,
        )
    }

    @Test
    func `alternation of literals`() throws {
        let hir: HIRKind = .alternation([
            .literal("a"),
            .literal("b"),
            .literal("c"),

        ])
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2, 0x62: 2, 0x63: 2], matchPatternIDs: []), // state 1 - start
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 2 - match
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("a"),
            .match("b"),
            .match("c"),
            .noMatch("d"),
            .noMatch("ab"),
            .noMatch(""),
            on: dfa,
        )
    }

    @Test
    func `concat of alternation`() throws {
        let hir: HIRKind = .concat(
            [
                .alternation([
                    .literal("a"),
                    .literal("b"),
                ]),
                .alternation([
                    .literal("c"),
                    .literal("d"),
                ]),
            ],
        )
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2, 0x62: 2], matchPatternIDs: []), // state 1 - start
                    .init(deadExcept: [0x63: 3, 0x64: 3], matchPatternIDs: []), // state 2 - after (a|b)
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 3 - match
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("ac"),
            .match("ad"),
            .match("bc"),
            .match("bd"),
            .noMatch("a"),
            .noMatch("b"),
            .noMatch("c"),
            .noMatch("d"),
            .noMatch("abcd"),
            .noMatch(""),
            on: dfa,
        )
    }

    @Test(arguments: [true, false])
    func `optional qualification a?`(isEager: Bool) throws {
        let hir: HIRKind = .quantification(
            .init(
                min: 0,
                max: 1,
                isEager: isEager,
                child: .literal("a"),
            ),
        )
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2], matchPatternIDs: [0]), // state 1 - start + accept
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 2 - accept
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match(""),
            .match("a"),
            .noMatch("aa"),
            .noMatch("b"),
            on: dfa,
        )
    }

    @Test(arguments: [true, false])
    func `one or more repetition a+`(isEager: Bool) throws {
        let hir: HIRKind = .quantification(
            .init(
                min: 1,
                max: nil,
                isEager: isEager,
                child: .literal("a"),
            ),
        )

        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2], matchPatternIDs: []), // state 1 - start
                    .init(deadExcept: [0x61: 2], matchPatternIDs: [0]), // state 2 - accept + loop
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .noMatch(""),
            .match("a"),
            .match("aa"),
            .match(String(repeating: "a", count: 100)),
            .noMatch("b"),
            on: dfa,
        )
    }

    @Test(arguments: [true, false])
    func `kleene star * repetition`(isEager: Bool) throws {
        let hir: HIRKind = .quantification(
            .init(
                min: 0,
                max: nil,
                isEager: isEager,
                child: .literal("a"),
            ),
        )

        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2], matchPatternIDs: [0]), // state 1 - start + accept
                    .init(deadExcept: [0x61: 2], matchPatternIDs: [0]), // state 2 - accept + loop
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match(""),
            .match("a"),
            .match("aa"),
            .match(String(repeating: "a", count: 100)),
            .noMatch("b"),
            on: dfa,
        )
    }

    @Test(arguments: [true, false])
    func `exact repetition`(isEager: Bool) throws {
        let hir: HIRKind = .quantification(
            .init(
                min: 5,
                max: 5,
                isEager: isEager,
                child: .literal("a"),
            ),
        )

        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2], matchPatternIDs: []), // state 1 - start
                    .init(deadExcept: [0x61: 3], matchPatternIDs: []), // state 2 - after 1
                    .init(deadExcept: [0x61: 4], matchPatternIDs: []), // state 3 - after 2
                    .init(deadExcept: [0x61: 5], matchPatternIDs: []), // state 4 - after 3
                    .init(deadExcept: [0x61: 6], matchPatternIDs: []), // state 5 - after 4
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 6 - after 5 (accept)
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .noMatch(""),
            .noMatch("a"),
            .noMatch("aa"),
            .noMatch("aaa"),
            .noMatch("aaaa"),
            .match("aaaaa"),
            .noMatch(String(repeating: "a", count: 100)),
            .noMatch("b"),
            on: dfa,
        )
    }

    @Test(arguments: [true, false])
    func `ranged repetition`(isEager: Bool) throws {
        let hir: HIRKind = .quantification(
            .init(
                min: 3,
                max: 5,
                isEager: isEager,
                child: .literal("a"),
            ),
        )

        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2], matchPatternIDs: []), // state 1 - start
                    .init(deadExcept: [0x61: 3], matchPatternIDs: []), // state 2 - after 1
                    .init(deadExcept: [0x61: 4], matchPatternIDs: []), // state 3 - after 2
                    .init(deadExcept: [0x61: 5], matchPatternIDs: [0]), // state 4 - after 3 (accept)
                    .init(deadExcept: [0x61: 6], matchPatternIDs: [0]), // state 5 - after 4 (accept)
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 6 - after 5 (accept)
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .noMatch(""),
            .noMatch("a"),
            .noMatch("aa"),
            .match("aaa"),
            .match("aaaa"),
            .match("aaaaa"),
            .noMatch(String(repeating: "a", count: 100)),
            .noMatch("b"),
            on: dfa,
        )
    }

    @Test
    func `character class - three disjoint ranges`() throws {
        let hir: HIRKind = .class(
            .init(ranges: [
                "a" ... "c",
                "f" ... "h",
                "x" ... "z",
            ]),
        )
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []),
                    .init(
                        deadExcept: [
                            0x61: 2, 0x62: 2, 0x63: 2, 0x66: 2, 0x67: 2, 0x68: 2, 0x78: 2, 0x79: 2,
                            0x7A: 2,
                        ],
                        matchPatternIDs: [],
                    ),
                    .init(deadExcept: [:], matchPatternIDs: [0]),
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("a"),
            .noMatch("d"),
            .match("g"),
            .noMatch("i"),
            .match("z"),
            on: dfa,
        )
    }

    @Test
    func `character class - unicode spanning different byte count`() throws {
        let hir: HIRKind = .class(.init(ranges: ["a" ... "é"]))
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []),
                    .init(
                        deadExcept: [
                            0x61: 2,
                            0x62: 2,
                            0x63: 2,
                            0x64: 2,
                            0x65: 2,
                            0x66: 2,
                            0x67: 2,
                            0x68: 2,
                            0x69: 2,
                            0x6A: 2,
                            0x6B: 2,
                            0x6C: 2,
                            0x6D: 2,
                            0x6E: 2,
                            0x6F: 2,
                            0x70: 2,
                            0x71: 2,
                            0x72: 2,
                            0x73: 2,
                            0x74: 2,
                            0x75: 2,
                            0x76: 2,
                            0x77: 2,
                            0x78: 2,
                            0x79: 2,
                            0x7A: 2,
                            0x7B: 2,
                            0x7C: 2,
                            0x7D: 2,
                            0x7E: 2,
                            0x7F: 2,
                            0xC2: 3,
                            0xC3: 4,
                        ],
                        matchPatternIDs: [],
                    ),
                    .init(deadExcept: [:], matchPatternIDs: [0]),
                    .init(
                        deadExcept: [
                            0x80: 2,
                            0x81: 2,
                            0x82: 2,
                            0x83: 2,
                            0x84: 2,
                            0x85: 2,
                            0x86: 2,
                            0x87: 2,
                            0x88: 2,
                            0x89: 2,
                            0x8A: 2,
                            0x8B: 2,
                            0x8C: 2,
                            0x8D: 2,
                            0x8E: 2,
                            0x8F: 2,
                            0x90: 2,
                            0x91: 2,
                            0x92: 2,
                            0x93: 2,
                            0x94: 2,
                            0x95: 2,
                            0x96: 2,
                            0x97: 2,
                            0x98: 2,
                            0x99: 2,
                            0x9A: 2,
                            0x9B: 2,
                            0x9C: 2,
                            0x9D: 2,
                            0x9E: 2,
                            0x9F: 2,
                            0xA0: 2,
                            0xA1: 2,
                            0xA2: 2,
                            0xA3: 2,
                            0xA4: 2,
                            0xA5: 2,
                            0xA6: 2,
                            0xA7: 2,
                            0xA8: 2,
                            0xA9: 2,
                            0xAA: 2,
                            0xAB: 2,
                            0xAC: 2,
                            0xAD: 2,
                            0xAE: 2,
                            0xAF: 2,
                            0xB0: 2,
                            0xB1: 2,
                            0xB2: 2,
                            0xB3: 2,
                            0xB4: 2,
                            0xB5: 2,
                            0xB6: 2,
                            0xB7: 2,
                            0xB8: 2,
                            0xB9: 2,
                            0xBA: 2,
                            0xBB: 2,
                            0xBC: 2,
                            0xBD: 2,
                            0xBE: 2,
                            0xBF: 2,
                        ],
                        matchPatternIDs: [],
                    ),
                    .init(
                        deadExcept: [
                            0x80: 2,
                            0x81: 2,
                            0x82: 2,
                            0x83: 2,
                            0x84: 2,
                            0x85: 2,
                            0x86: 2,
                            0x87: 2,
                            0x88: 2,
                            0x89: 2,
                            0x8A: 2,
                            0x8B: 2,
                            0x8C: 2,
                            0x8D: 2,
                            0x8E: 2,
                            0x8F: 2,
                            0x90: 2,
                            0x91: 2,
                            0x92: 2,
                            0x93: 2,
                            0x94: 2,
                            0x95: 2,
                            0x96: 2,
                            0x97: 2,
                            0x98: 2,
                            0x99: 2,
                            0x9A: 2,
                            0x9B: 2,
                            0x9C: 2,
                            0x9D: 2,
                            0x9E: 2,
                            0x9F: 2,
                            0xA0: 2,
                            0xA1: 2,
                            0xA2: 2,
                            0xA3: 2,
                            0xA4: 2,
                            0xA5: 2,
                            0xA6: 2,
                            0xA7: 2,
                            0xA8: 2,
                            0xA9: 2,
                        ],
                        matchPatternIDs: [],
                    ),
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .noMatch("`"),
            .match("a"),
            .match("d"),
            .match("g"),
            .match("i"),
            .match("z"),
            .noMatch("@"),
            .noMatch("1"),
            .match("¶"),
            .match("Á"),
            .match("é"),
            .noMatch("ê"),
            on: dfa,
        )
    }

    @Test
    func `character class - long but same byte count`() throws {
        let hir: HIRKind = .class(.init(ranges: ["🤔" ... "🤣"]))
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []),
                    .init(deadExcept: [0xF0: 2], matchPatternIDs: []),
                    .init(deadExcept: [0x9F: 3], matchPatternIDs: []),
                    .init(deadExcept: [0xA4: 4], matchPatternIDs: []),
                    .init(
                        deadExcept: [
                            0x94: 5,
                            0x95: 5,
                            0x96: 5,
                            0x97: 5,
                            0x98: 5,
                            0x99: 5,
                            0x9A: 5,
                            0x9B: 5,
                            0x9C: 5,
                            0x9D: 5,
                            0x9E: 5,
                            0x9F: 5,
                            0xA0: 5,
                            0xA1: 5,
                            0xA2: 5,
                            0xA3: 5,
                        ],
                        matchPatternIDs: [],
                    ),
                    .init(deadExcept: [:], matchPatternIDs: [0]),
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .noMatch("🤓"),
            .match("🤔"),
            .match("🤕"),
            .match("🤣"),
            .match("🤡"),
            .match("🤢"),
            .noMatch("🤤"),
            on: dfa,
        )
    }

    @Test
    func `empty pattern`() throws {
        let dfa = try dfa(from: .empty)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(),
                    .init(deadExcept: [:], matchPatternIDs: [0]),
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match(""),
            .noMatch("a"),
            .noMatch("abc"),
            on: dfa,
        )
    }

    @Test
    func `UTF-8 multi-byte character`() throws {
        let dfa = try dfa(from: .literal(["é"]))

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0xC3: 2], matchPatternIDs: []), // state 1 - start, first byte of é
                    .init(deadExcept: [0xA9: 3], matchPatternIDs: []), // state 2 - second byte of é
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 3 - match
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("é"),
            .noMatch("e"),
            .noMatch(""),
            .noMatch("éé"),
            .noMatch("aé"),
            .noMatch("\u{0065}\u{0301}"),
            on: dfa,
        )
    }

    // MARK: Complex Patterns

    @Test
    func `pattern with alternation and concatenation`() throws {
        let hir: HIRKind = .concat([
            .alternation([.literal(["a"]), .literal(["b"])]),
            .literal(["c"]),
        ])
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2, 0x62: 2], matchPatternIDs: []), // state 1 - start
                    .init(deadExcept: [0x63: 3], matchPatternIDs: []), // state 2 - after (a|b)
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 3 - match
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("ac"),
            .match("bc"),
            .noMatch("a"),
            .noMatch("c"),
            .noMatch("abc"),
            .noMatch(""),
            on: dfa,
        )
    }

    @Test
    func `pattern with quantifier and concatenation`() throws {
        let hir: HIRKind = .concat([
            .quantification(
                .init(
                    min: 1,
                    max: nil,
                    isEager: true,
                    child: .literal(["a"]),
                )),
            .literal(["b"]),
        ])
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(deadExcept: [0x61: 2], matchPatternIDs: []), // state 1 - start
                    .init(deadExcept: [0x61: 2, 0x62: 3], matchPatternIDs: []), // state 2 - after a+ (accept)
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 3 - match
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("ab"),
            .match("aab"),
            .match("aaab"),
            .noMatch("b"),
            .noMatch("a"),
            .noMatch(""),
            on: dfa,
        )
    }

    @Test
    func `all character classes`() throws {
        let hir: HIRKind = .class([Character.minValue ... Character.maxValue])
        let dfa = try dfa(from: hir)

        equals(
            actual: dfa,
            expected: .init(
                states: [
                    .init(deadExcept: [:], matchPatternIDs: []), // state 0 - dead
                    .init(
                        deadExcept: [ // state 1 - start
                            0x00: 2, 0x01: 2, 0x02: 2, 0x03: 2, 0x04: 2, 0x05: 2, 0x06: 2, 0x07: 2,
                            0x08: 2, 0x09: 2, 0x0A: 2, 0x0B: 2, 0x0C: 2, 0x0D: 2, 0x0E: 2, 0x0F: 2,
                            0x10: 2, 0x11: 2, 0x12: 2, 0x13: 2, 0x14: 2, 0x15: 2, 0x16: 2, 0x17: 2,
                            0x18: 2, 0x19: 2, 0x1A: 2, 0x1B: 2, 0x1C: 2, 0x1D: 2, 0x1E: 2, 0x1F: 2,
                            0x20: 2, 0x21: 2, 0x22: 2, 0x23: 2, 0x24: 2, 0x25: 2, 0x26: 2, 0x27: 2,
                            0x28: 2, 0x29: 2, 0x2A: 2, 0x2B: 2, 0x2C: 2, 0x2D: 2, 0x2E: 2, 0x2F: 2,
                            0x30: 2, 0x31: 2, 0x32: 2, 0x33: 2, 0x34: 2, 0x35: 2, 0x36: 2, 0x37: 2,
                            0x38: 2, 0x39: 2, 0x3A: 2, 0x3B: 2, 0x3C: 2, 0x3D: 2, 0x3E: 2, 0x3F: 2,
                            0x40: 2, 0x41: 2, 0x42: 2, 0x43: 2, 0x44: 2, 0x45: 2, 0x46: 2, 0x47: 2,
                            0x48: 2, 0x49: 2, 0x4A: 2, 0x4B: 2, 0x4C: 2, 0x4D: 2, 0x4E: 2, 0x4F: 2,
                            0x50: 2, 0x51: 2, 0x52: 2, 0x53: 2, 0x54: 2, 0x55: 2, 0x56: 2, 0x57: 2,
                            0x58: 2, 0x59: 2, 0x5A: 2, 0x5B: 2, 0x5C: 2, 0x5D: 2, 0x5E: 2, 0x5F: 2,
                            0x60: 2, 0x61: 2, 0x62: 2, 0x63: 2, 0x64: 2, 0x65: 2, 0x66: 2, 0x67: 2,
                            0x68: 2, 0x69: 2, 0x6A: 2, 0x6B: 2, 0x6C: 2, 0x6D: 2, 0x6E: 2, 0x6F: 2,
                            0x70: 2, 0x71: 2, 0x72: 2, 0x73: 2, 0x74: 2, 0x75: 2, 0x76: 2, 0x77: 2,
                            0x78: 2, 0x79: 2, 0x7A: 2, 0x7B: 2, 0x7C: 2, 0x7D: 2, 0x7E: 2, 0x7F: 2,
                            0xC2: 3, 0xC3: 3, 0xC4: 3, 0xC5: 3, 0xC6: 3, 0xC7: 3, 0xC8: 3, 0xC9: 3,
                            0xCA: 3, 0xCB: 3, 0xCC: 3, 0xCD: 3, 0xCE: 3, 0xCF: 3, 0xD0: 3, 0xD1: 3,
                            0xD2: 3, 0xD3: 3, 0xD4: 3, 0xD5: 3, 0xD6: 3, 0xD7: 3, 0xD8: 3, 0xD9: 3,
                            0xDA: 3, 0xDB: 3, 0xDC: 3, 0xDD: 3, 0xDE: 3, 0xDF: 3,
                            0xE0: 4, 0xE1: 5, 0xE2: 5, 0xE3: 5, 0xE4: 5, 0xE5: 5, 0xE6: 5, 0xE7: 5,
                            0xE8: 5, 0xE9: 5, 0xEA: 5, 0xEB: 5, 0xEC: 5, 0xED: 6, 0xEE: 5, 0xEF: 5,
                            0xF0: 7, 0xF1: 8, 0xF2: 8, 0xF3: 8, 0xF4: 9,
                        ], matchPatternIDs: [],
                    ),
                    .init(deadExcept: [:], matchPatternIDs: [0]), // state 2 - match
                    .init(
                        deadExcept: [ // state 3 - 2-byte UTF-8 continuation
                            0x80: 2, 0x81: 2, 0x82: 2, 0x83: 2, 0x84: 2, 0x85: 2, 0x86: 2, 0x87: 2,
                            0x88: 2, 0x89: 2, 0x8A: 2, 0x8B: 2, 0x8C: 2, 0x8D: 2, 0x8E: 2, 0x8F: 2,
                            0x90: 2, 0x91: 2, 0x92: 2, 0x93: 2, 0x94: 2, 0x95: 2, 0x96: 2, 0x97: 2,
                            0x98: 2, 0x99: 2, 0x9A: 2, 0x9B: 2, 0x9C: 2, 0x9D: 2, 0x9E: 2, 0x9F: 2,
                            0xA0: 2, 0xA1: 2, 0xA2: 2, 0xA3: 2, 0xA4: 2, 0xA5: 2, 0xA6: 2, 0xA7: 2,
                            0xA8: 2, 0xA9: 2, 0xAA: 2, 0xAB: 2, 0xAC: 2, 0xAD: 2, 0xAE: 2, 0xAF: 2,
                            0xB0: 2, 0xB1: 2, 0xB2: 2, 0xB3: 2, 0xB4: 2, 0xB5: 2, 0xB6: 2, 0xB7: 2,
                            0xB8: 2, 0xB9: 2, 0xBA: 2, 0xBB: 2, 0xBC: 2, 0xBD: 2, 0xBE: 2, 0xBF: 2,
                        ], matchPatternIDs: [],
                    ),
                    .init(
                        deadExcept: [ // state 4 - 3-byte UTF-8 first continuation
                            0xA0: 3, 0xA1: 3, 0xA2: 3, 0xA3: 3, 0xA4: 3, 0xA5: 3, 0xA6: 3, 0xA7: 3,
                            0xA8: 3, 0xA9: 3, 0xAA: 3, 0xAB: 3, 0xAC: 3, 0xAD: 3, 0xAE: 3, 0xAF: 3,
                            0xB0: 3, 0xB1: 3, 0xB2: 3, 0xB3: 3, 0xB4: 3, 0xB5: 3, 0xB6: 3, 0xB7: 3,
                            0xB8: 3, 0xB9: 3, 0xBA: 3, 0xBB: 3, 0xBC: 3, 0xBD: 3, 0xBE: 3, 0xBF: 3,
                        ], matchPatternIDs: [],
                    ),
                    .init(
                        deadExcept: [ // state 5 - 3-byte UTF-8 second continuation
                            0x80: 3, 0x81: 3, 0x82: 3, 0x83: 3, 0x84: 3, 0x85: 3, 0x86: 3, 0x87: 3,
                            0x88: 3, 0x89: 3, 0x8A: 3, 0x8B: 3, 0x8C: 3, 0x8D: 3, 0x8E: 3, 0x8F: 3,
                            0x90: 3, 0x91: 3, 0x92: 3, 0x93: 3, 0x94: 3, 0x95: 3, 0x96: 3, 0x97: 3,
                            0x98: 3, 0x99: 3, 0x9A: 3, 0x9B: 3, 0x9C: 3, 0x9D: 3, 0x9E: 3, 0x9F: 3,
                            0xA0: 3, 0xA1: 3, 0xA2: 3, 0xA3: 3, 0xA4: 3, 0xA5: 3, 0xA6: 3, 0xA7: 3,
                            0xA8: 3, 0xA9: 3, 0xAA: 3, 0xAB: 3, 0xAC: 3, 0xAD: 3, 0xAE: 3, 0xAF: 3,
                            0xB0: 3, 0xB1: 3, 0xB2: 3, 0xB3: 3, 0xB4: 3, 0xB5: 3, 0xB6: 3, 0xB7: 3,
                            0xB8: 3, 0xB9: 3, 0xBA: 3, 0xBB: 3, 0xBC: 3, 0xBD: 3, 0xBE: 3, 0xBF: 3,
                        ], matchPatternIDs: [],
                    ),
                    .init(
                        deadExcept: [ // state 6 - 3-byte UTF-8 for ED
                            0x80: 3, 0x81: 3, 0x82: 3, 0x83: 3, 0x84: 3, 0x85: 3, 0x86: 3, 0x87: 3,
                            0x88: 3, 0x89: 3, 0x8A: 3, 0x8B: 3, 0x8C: 3, 0x8D: 3, 0x8E: 3, 0x8F: 3,
                            0x90: 3, 0x91: 3, 0x92: 3, 0x93: 3, 0x94: 3, 0x95: 3, 0x96: 3, 0x97: 3,
                            0x98: 3, 0x99: 3, 0x9A: 3, 0x9B: 3, 0x9C: 3, 0x9D: 3, 0x9E: 3, 0x9F: 3,
                        ], matchPatternIDs: [],
                    ),
                    .init(
                        deadExcept: [ // state 7 - 4-byte UTF-8 first continuation
                            0x90: 5, 0x91: 5, 0x92: 5, 0x93: 5, 0x94: 5, 0x95: 5, 0x96: 5, 0x97: 5,
                            0x98: 5, 0x99: 5, 0x9A: 5, 0x9B: 5, 0x9C: 5, 0x9D: 5, 0x9E: 5, 0x9F: 5,
                            0xA0: 5, 0xA1: 5, 0xA2: 5, 0xA3: 5, 0xA4: 5, 0xA5: 5, 0xA6: 5, 0xA7: 5,
                            0xA8: 5, 0xA9: 5, 0xAA: 5, 0xAB: 5, 0xAC: 5, 0xAD: 5, 0xAE: 5, 0xAF: 5,
                            0xB0: 5, 0xB1: 5, 0xB2: 5, 0xB3: 5, 0xB4: 5, 0xB5: 5, 0xB6: 5, 0xB7: 5,
                            0xB8: 5, 0xB9: 5, 0xBA: 5, 0xBB: 5, 0xBC: 5, 0xBD: 5, 0xBE: 5, 0xBF: 5,
                        ], matchPatternIDs: [],
                    ),
                    .init(
                        deadExcept: [ // state 8 - 4-byte UTF-8 second/third continuation
                            0x80: 5, 0x81: 5, 0x82: 5, 0x83: 5, 0x84: 5, 0x85: 5, 0x86: 5, 0x87: 5,
                            0x88: 5, 0x89: 5, 0x8A: 5, 0x8B: 5, 0x8C: 5, 0x8D: 5, 0x8E: 5, 0x8F: 5,
                            0x90: 5, 0x91: 5, 0x92: 5, 0x93: 5, 0x94: 5, 0x95: 5, 0x96: 5, 0x97: 5,
                            0x98: 5, 0x99: 5, 0x9A: 5, 0x9B: 5, 0x9C: 5, 0x9D: 5, 0x9E: 5, 0x9F: 5,
                            0xA0: 5, 0xA1: 5, 0xA2: 5, 0xA3: 5, 0xA4: 5, 0xA5: 5, 0xA6: 5, 0xA7: 5,
                            0xA8: 5, 0xA9: 5, 0xAA: 5, 0xAB: 5, 0xAC: 5, 0xAD: 5, 0xAE: 5, 0xAF: 5,
                            0xB0: 5, 0xB1: 5, 0xB2: 5, 0xB3: 5, 0xB4: 5, 0xB5: 5, 0xB6: 5, 0xB7: 5,
                            0xB8: 5, 0xB9: 5, 0xBA: 5, 0xBB: 5, 0xBC: 5, 0xBD: 5, 0xBE: 5, 0xBF: 5,
                        ], matchPatternIDs: [],
                    ),
                    .init(
                        deadExcept: [ // state 9 - 4-byte UTF-8 for F4
                            0x80: 5, 0x81: 5, 0x82: 5, 0x83: 5, 0x84: 5, 0x85: 5, 0x86: 5, 0x87: 5,
                            0x88: 5, 0x89: 5, 0x8A: 5, 0x8B: 5, 0x8C: 5, 0x8D: 5, 0x8E: 5, 0x8F: 5,
                        ], matchPatternIDs: [],
                    ),
                ],
                start: 1,
                patternIDs: [0],
            ),
        )

        assertMatches(
            .match("\u{10000}"), // first character 4 bytes
            .match("\u{10FFFF}"), // last character 4 bytes
            .match("\u{0800}"), // first character 3 bytes
            .match("\u{FFFF}"), // last character 3 bytes
            .match("\u{0080}"), // first character 2 bytes
            .match("\u{07FF}"), // last character 2 bytes
            .match("\u{0000}"), // first character 1 byte
            .match("\u{007F}"), // last character 1 byte
            .noMatch([0x80]), // continuation byte alone
            .noMatch([0xC0, 0x80]), // overlong encoding of U+0000
            .noMatch([0xED, 0xA0, 0x80]), // surrogate half \U+D800
            .noMatch([0xF4, 0x90, 0x80, 0x80]), // greater than max valid codepoint \U+10FFFF
            on: dfa,
        )
    }
}
