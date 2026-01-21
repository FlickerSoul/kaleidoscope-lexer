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
private func matches(_ dfa: borrowing DFA, input: String) -> Bool {
    var state = dfa.start
    for byte in input.utf8 {
        state = dfa.nextState(state, byte: byte)
        if state == .dead {
            return false
        }
    }
    return dfa.isMatch(state)
}

/// Simulate DFA execution and get matching patterns
private func matchingPatterns(_ dfa: borrowing DFA, input: String) -> [PatternID] {
    var state = dfa.start
    for byte in input.utf8 {
        state = dfa.nextState(state, byte: byte)
        if state == .dead {
            return []
        }
    }
    return dfa.isMatch(state) ? dfa.matchingPatterns(state) : []
}

private struct MatchInput {
    let input: String
    let shouldMatch: Bool
    let sourceLocation: SourceLocation

    private init(
        input: String,
        shouldMatch: Bool,
        sourceLocation: SourceLocation,
    ) {
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
        _ input: String,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column,
    ) -> MatchInput {
        .init(
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
        #expect(
            matches(dfa, input: input.input) == input.shouldMatch,
            "\(input.input) does not match \(input.shouldMatch)",
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
    func `empty pattern`() throws {
        let nfa = try NFA.build(from: .empty)
        let dfa = try Determinizer.buildDFA(from: nfa)

        // Empty pattern only matches empty string, rejects all input
        assertMatches(
            .match(""),
            .noMatch("a"),
            .noMatch("abc"),
            on: dfa,
        )
    }

    @Test
    func `UTF-8 multi-byte character`() throws {
        // 'é' (U+00E9) = 0xC3 0xA9 in UTF-8
        let nfa = try NFA.build(from: .literal(["é"]))
        let dfa = try Determinizer.buildDFA(from: nfa)

        assertMatches(
            .match("é"),
            .noMatch("e"),
            .noMatch(""),
            .noMatch("éé"),
            .noMatch("aé"),
            on: dfa,
        )
    }

    // MARK: Complex Patterns

    @Test
    func `pattern with alternation and concatenation`() throws {
        let nfa = try NFA.build(from: .concat([
            .alternation([.literal(["a"]), .literal(["b"])]),
            .literal(["c"]),
        ]))
        let dfa = try Determinizer.buildDFA(from: nfa)

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
        let nfa = try NFA.build(from: .concat([
            .quantification(.init(
                min: 1,
                max: nil,
                isEager: true,
                child: .literal(["a"]),
            )),
            .literal(["b"]),
        ]))
        let dfa = try Determinizer.buildDFA(from: nfa)

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

    // MARK: Match State Tracking

    @Test
    func `match states are correctly marked`() throws {
        let nfa = try NFA.build(from: .literal(["a"]))
        let dfa = try Determinizer.buildDFA(from: nfa)

        // Simulate matching "a"
        var state = dfa.start
        state = dfa.nextState(state, byte: 0x61) // 'a'

        // The resulting state should be a match state
        #expect(dfa.isMatch(state))
    }

    @Test
    func `match patterns are preserved`() throws {
        let nfa = try NFA.build(from: .literal(["a"]))
        let dfa = try Determinizer.buildDFA(from: nfa)

        // Get patterns at match state
        var state = dfa.start
        state = dfa.nextState(state, byte: 0x61) // 'a'

        let patterns = dfa.matchingPatterns(state)
        #expect(patterns == [0])
    }

    // MARK: Byte Transitions

    @Test
    func `all 256 bytes have transitions`() throws {
        let nfa = try NFA.build(from: .class([Character.minValue ... Character.maxValue]))
        let dfa = try Determinizer.buildDFA(from: nfa)

        let startState = dfa.state(dfa.start)

        // Every byte should have a transition (possibly to dead)
        for byte: UInt8 in 0 ... 255 {
            _ = startState.transition(for: byte)
            // Just verify it doesn't crash
        }
    }
}
