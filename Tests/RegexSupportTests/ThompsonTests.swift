//
//  ThompsonTests.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//
import Testing
import TestUtils

@testable import RegexSupport

// MARK: - State Assertion Helpers

/// Helper to create expected byteRange state
func s_byte(_ byte: UInt8, _ next: NFAStateID) -> NFAState {
    .byteRange(.init(byte: byte, next: next))
}

/// Helper to create expected range state
func s_range(_ start: UInt8, _ end: UInt8, _ next: NFAStateID) -> NFAState {
    .byteRange(.init(start: start, end: end, next: next))
}

/// Helper to create expected sparse state
func s_sparse(_ ranges: (start: UInt8, end: UInt8, next: NFAStateID)...)
    -> NFAState {
    .sparse(ranges.map { .init(start: $0.start, end: $0.end, next: $0.next) })
}

/// Helper to create expected binary union state
func s_bin_union(_ first: NFAStateID, _ second: NFAStateID) -> NFAState {
    .binaryUnion(first, second)
}

/// Helper to create expected union state
func s_union(_ alts: NFAStateID...) -> NFAState {
    .union(alts)
}

/// Helper to create expected match state
func s_match(_ patternId: PatternID = 0) -> NFAState {
    .match(patternId)
}

/// Helper to create expected fail state
func s_fail() -> NFAState {
    .fail
}

// MARK: - Basic Construct Tests

@Suite("Thompson Tests")
struct ThompsonTests { // swiftlint:disable:this type_body_length
    @Test
    func `empty produces epsilon to match`() throws {
        let nfa = try NFA.build(from: .empty)

        equals(
            actual: nfa,
            expected: .init(states: [s_match()], start: 0),
        )
    }

    @Test
    func `single ASCII character literal`() throws {
        let nfa = try NFA.build(from: .literal(["a"]))

        // Single ASCII char: byteRange(0x61) -> match
        equals(
            actual: nfa,
            expected: .init(states: [s_byte(0x61, 1), s_match()], start: 0),
        )
    }

    @Test
    func `multi-byte UTF8 character`() throws {
        // 'é' (U+00E9) encodes to UTF-8 as 0xC3 0xA9
        let nfa = try NFA.build(from: .literal(["é"]))

        // Should create: byteRange(0xC3) -> byteRange(0xA9) -> match
        equals(
            actual: nfa,
            expected: .init(
                states: [s_byte(0xC3, 1), s_byte(0xA9, 2), s_match()],
                start: 0,
            ),
        )
    }

    @Test
    func `multi-character ASCII literal`() throws {
        let nfa = try NFA.build(from: .literal(["a", "b", "c"]))

        // 3 ASCII chars: byteRange -> byteRange -> byteRange -> match
        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1), s_byte(0x62, 2), s_byte(0x63, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `empty literal produces epsilon`() throws {
        let nfa = try NFA.build(from: .literal([]))

        equals(
            actual: nfa,
            expected: .init(states: [s_match()], start: 0),
        )
    }

    @Test
    func `ASCII character class creates byteRange`() throws {
        let charClass = CharacterClass(ranges: ["a" ... "z"])
        let nfa = try NFA.build(from: .class(charClass))

        // ASCII class: single byteRange(0x61-0x7A) -> match
        equals(
            actual: nfa,
            expected: .init(
                states: [s_range(0x61, 0x7A, 1), s_match()],
                start: 0,
            ),
        )
    }

    @Test
    func `multiple range character class creates sparse`() throws {
        // [a-z0-9] creates sparse with two ranges
        let charClass = CharacterClass(ranges: ["a" ... "z", "0" ... "9"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_sparse(
                        (start: 0x30, end: 0x39, next: 1),
                        (start: 0x61, end: 0x7A, next: 1),
                    ),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Concatenation Tests

    @Test
    func `empty concatenation`() throws {
        let nfa = try NFA.build(from: .concat([]))

        equals(
            actual: nfa,
            expected: .init(states: [s_match()], start: 0),
        )
    }

    @Test
    func `single element concatenation`() throws {
        let nfa = try NFA.build(from: .concat([.literal(["a"])]))

        equals(
            actual: nfa,
            expected: .init(states: [s_byte(0x61, 1), s_match()], start: 0),
        )
    }

    @Test
    func `two element concatenation`() throws {
        let nfa = try NFA.build(
            from: .concat([.literal(["a"]), .literal(["b"])]),
        )

        // a -> b -> match
        equals(
            actual: nfa,
            expected: .init(
                states: [s_byte(0x61, 1), s_byte(0x62, 2), s_match()],
                start: 0,
            ),
        )
    }

    @Test
    func `three element concatenation`() throws {
        let nfa = try NFA.build(
            from: .concat([
                .literal(["a"]),
                .literal(["b"]),
                .literal(["c"]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1), s_byte(0x62, 2), s_byte(0x63, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Alternation Tests

    @Test
    func `empty alternation`() throws {
        let nfa = try NFA.build(from: .alternation([]))

        equals(
            actual: nfa,
            expected: .init(states: [s_fail(), s_match()], start: 0),
        )
    }

    @Test
    func `single element alternation`() throws {
        let nfa = try NFA.build(from: .alternation([.literal(["a"])]))

        // Single element alternation is just the element itself
        equals(
            actual: nfa,
            expected: .init(states: [s_byte(0x61, 1), s_match()], start: 0),
        )
    }

    @Test
    func `two element alternation`() throws {
        let nfa = try NFA.build(
            from: .alternation([
                .literal(["a"]),
                .literal(["b"]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 3),
                    s_byte(0x62, 3),
                    s_bin_union(0, 1),
                    s_match(),
                ],
                start: 2,
            ),
        )
    }

    @Test
    func `three element alternation`() throws {
        let nfa = try NFA.build(
            from: .alternation([
                .literal(["a"]),
                .literal(["b"]),
                .literal(["c"]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 4),
                    s_byte(0x62, 4),
                    s_byte(0x63, 4),
                    s_union(0, 1, 2),
                    s_match(),
                ],
                start: 3,
            ),
        )
    }

    // MARK: - Quantifier Tests

    @Test
    func `eager optional creates union`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: 1,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_bin_union(1, 2),
                    s_byte(0x61, 2),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `reluctant optional creates reversed union`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: 1,
                    isEager: false,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_bin_union(2, 1),
                    s_byte(0x61, 2),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `eager kleene star creates loop`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: nil,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        // TODO: optimize
        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_bin_union(0, 3),
                    s_bin_union(0, 3),
                    s_match(),
                ],
                start: 2,
            ),
        )
    }

    @Test
    func `reluctant kleene star creates loop`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: nil,
                    isEager: false,
                    child: .literal(["a"]),
                ),
            ),
        )

        // TODO: optimize
        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_bin_union(3, 0),
                    s_bin_union(3, 0),
                    s_match(),
                ],
                start: 2,
            ),
        )
    }

    @Test
    func `eager kleene plus requires one match`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: nil,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_bin_union(0, 2),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `reluctant kleene plus requires one match`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: nil,
                    isEager: false,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_bin_union(2, 0),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `exact eager repetition creates chain`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 3,
                    max: 3,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x61, 2),
                    s_byte(0x61, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `exact reluctant repetition creates chain`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 3,
                    max: 3,
                    isEager: false,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x61, 2),
                    s_byte(0x61, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `ranged eager repetition`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 2,
                    max: 4,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x61, 2),
                    s_bin_union(3, 6),
                    s_byte(0x61, 4),
                    s_bin_union(5, 6),
                    s_byte(0x61, 6),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `ranged reluctant repetition`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 2,
                    max: 4,
                    isEager: false,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x61, 2),
                    s_bin_union(6, 3),
                    s_byte(0x61, 4),
                    s_bin_union(6, 5),
                    s_byte(0x61, 6),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `at least n eager repetition`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 2,
                    max: nil,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x61, 2),
                    s_bin_union(1, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `at least n reluctant repetition`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 2,
                    max: nil,
                    isEager: false,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x61, 2),
                    s_bin_union(3, 1),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Group Tests

    @Test
    func `group passes through`() throws {
        let nfaWithGroup = try NFA.build(
            from: .group(Group(child: .literal(["a"]))),
        )
        let nfaWithoutGroup = try NFA.build(from: .literal(["a"]))

        equals(
            actual: nfaWithGroup,
            expected: nfaWithoutGroup,
        )
    }

    @Test
    func `nested groups`() throws {
        let nfa = try NFA.build(
            from: .group(
                Group(
                    child: .group(
                        Group(
                            child: .literal(["a"]),
                        ),
                    ),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(states: [s_byte(0x61, 1), s_match()], start: 0),
        )
    }

    // MARK: - Complex Pattern Tests

    @Test
    func `alternation in concatenation`() throws {
        let nfa = try NFA.build(
            from: .concat([
                .literal(["a"]),
                .alternation([.literal(["b"]), .literal(["c"])]),
                .literal(["d"]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 3),
                    s_byte(0x62, 4),
                    s_byte(0x63, 4),
                    s_bin_union(1, 2),
                    s_byte(0x64, 5),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `concatenation in alternation`() throws {
        let nfa = try NFA.build(
            from: .alternation([
                .concat([.literal(["a"]), .literal(["b"])]),
                .concat([.literal(["c"]), .literal(["d"])]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x62, 5),
                    s_byte(0x63, 3),
                    s_byte(0x64, 5),
                    s_bin_union(0, 2),
                    s_match(),
                ],
                start: 4,
            ),
        )
    }

    @Test
    func `quantifier on alternation`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: nil,
                    isEager: true,
                    child: .alternation([.literal(["a"]), .literal(["b"])]),
                ),
            ),
        )

        // FIXME: optimize
        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 3),
                    s_byte(0x62, 3),
                    s_bin_union(0, 1),
                    s_bin_union(2, 5),
                    s_bin_union(2, 5),
                    s_match(),
                ],
                start: 4,
            ),
        )
    }

    @Test
    func `email-like pattern`() throws {
        let charClass = CharacterClass(ranges: ["a" ... "z"])
        let nfa = try NFA.build(
            from: .concat([
                .quantification(
                    Quantification(
                        min: 1,
                        max: nil,
                        isEager: true,
                        child: .class(charClass),
                    ),
                ),
                .literal(["@"]),
                .quantification(
                    Quantification(
                        min: 1,
                        max: nil,
                        isEager: true,
                        child: .class(charClass),
                    ),
                ),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_range(0x61, 0x7A, 1),
                    s_bin_union(0, 2),
                    s_byte(0x40, 3),
                    s_range(0x61, 0x7A, 4),
                    s_bin_union(3, 5),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - UTF-8 Tests

    @Test
    func `ASCII character is single byte`() throws {
        let nfa = try NFA.build(from: .literal(["a"]))

        equals(
            actual: nfa,
            expected: .init(states: [s_byte(0x61, 1), s_match()], start: 0),
        )
    }

    @Test
    func `two-byte UTF8 character`() throws {
        // 'é' = U+00E9 = 0xC3 0xA9 in UTF-8
        let nfa = try NFA.build(from: .literal(["é"]))

        equals(
            actual: nfa,
            expected: .init(
                states: [s_byte(0xC3, 1), s_byte(0xA9, 2), s_match()],
                start: 0,
            ),
        )
    }

    @Test
    func `three-byte UTF8 character`() throws {
        // '中' = U+4E2D = 0xE4 0xB8 0xAD in UTF-8
        let nfa = try NFA.build(from: .literal(["中"]))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0xE4, 1), s_byte(0xB8, 2), s_byte(0xAD, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `four-byte UTF8 character`() throws {
        // '😀' = U+1F600 = 0xF0 0x9F 0x98 0x80 in UTF-8
        let nfa = try NFA.build(from: .literal(["😀"]))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0xF0, 1), s_byte(0x9F, 2), s_byte(0x98, 3),
                    s_byte(0x80, 4), s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `mixed ASCII and UTF8`() throws {
        let nfa = try NFA.build(from: .literal(["a", "é"]))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1), s_byte(0xC3, 2), s_byte(0xA9, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `compile ASCII class single range`() throws {
        let charClass = CharacterClass(ranges: ["a" ... "z"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [s_range(0x61, 0x7A, 1), s_match()],
                start: 0,
            ),
        )
    }

    @Test
    func `compile ASCII class multiple ranges`() throws {
        let charClass = CharacterClass(ranges: ["a" ... "c", "x" ... "z"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_sparse(
                        (start: 0x61, end: 0x63, next: 1),
                        (start: 0x78, end: 0x7A, next: 1),
                    ),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `compile UTF8 class - same range count`() throws {
        // 🤔 = F0 9F A4 94
        // 🤣 = F0 9F A4 A3
        let charClass = CharacterClass(ranges: ["🤔" ... "🤣"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_range(0x94, 0xA3, 4),
                    s_range(0xA4, 0xA4, 0),
                    s_range(0x9F, 0x9F, 1),
                    s_range(0xF0, 0xF0, 2),
                    s_match(),
                ],
                start: 3,
            ),
        )
    }

    @Test
    func `compile UTF8 class - different range count`() throws {
        let charClass = CharacterClass(ranges: ["中" ... "😀"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_range(173, 191, 9),
                    s_range(128, 191, 9),
                    s_sparse(
                        (start: 184, end: 184, next: 0),
                        (start: 185, end: 191, next: 1),
                    ),
                    s_range(128, 191, 1),
                    s_range(128, 159, 1),
                    s_range(128, 128, 9),
                    s_sparse(
                        (start: 128, end: 151, next: 1),
                        (start: 152, end: 152, next: 5),
                    ),
                    s_sparse(
                        (start: 144, end: 158, next: 3),
                        (start: 159, end: 159, next: 6),
                    ),
                    s_sparse(
                        (start: 228, end: 228, next: 2),
                        (start: 229, end: 236, next: 3),
                        (start: 237, end: 237, next: 4),
                        (start: 238, end: 239, next: 3),
                        (start: 240, end: 240, next: 7),
                    ),
                    s_match(),
                ],
                start: 8,
            ),
        )
    }

    @Test
    func `compile ab+ group`() throws {
        let nfa = try NFA.build(
            from: .concat([
                .literal(["a"]),
                .quantification(
                    Quantification(
                        min: 1,
                        max: nil,
                        isEager: true,
                        child: .literal(["b"]),
                    ),
                ),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x62, 2),
                    s_bin_union(1, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `compile ab group`() throws {
        let nfa = try NFA.build(
            from: .group(
                Group(child: .concat([.literal(["a"]), .literal(["b"])])),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [s_byte(0x61, 1), s_byte(0x62, 2), s_match()],
                start: 0,
            ),
        )
    }

    @Test
    func `compile ab plus grouped`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: nil,
                    isEager: true,
                    child: .group(
                        Group(
                            child: .concat([.literal(["a"]), .literal(["b"])]),
                        ),
                    ),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x62, 2),
                    s_bin_union(0, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `compile empty class fails`() throws {
        #expect(throws: NFAConstructionError.invalidOperation(description: "Sparse state with no transitions.")) {
            try NFA.build(
                from: .class(
                    [],
                ),
            )
        }
    }

    // MARK: - Unicode Class Structure Tests

    @Test
    func `compile Greek letters class`() throws {
        // [α-δ] where α = U+03B1 = 0xCE 0xB1, δ = U+03B4 = 0xCE 0xB4
        // All share leading byte 0xCE, so creates:
        // S0: byteRange(0xCE, S1)
        // S1: byteRange(0xB1-0xB4, S2)
        // S2: match
        let charClass = CharacterClass(ranges: ["α" ... "δ"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_range(0xB1, 0xB4, 2),
                    s_byte(0xCE, 0),
                    s_match(),
                ],
                start: 1,
            ),
        )
    }

    @Test
    func `compile mixed ASCII and Unicode class`() throws {
        // [a-z☃] where ☃ = U+2603 = 0xE2 0x98 0x83
        // Creates alternation between ASCII range and UTF-8 sequence
        let charClass = CharacterClass(ranges: ["a" ... "z", "☃" ... "☃"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x83, 3),
                    s_byte(0x98, 0),
                    s_sparse(
                        (start: 0x61, end: 0x7A, next: 3),
                        (start: 0xE2, end: 0xE2, next: 1),
                    ),
                    s_match(),
                ],
                start: 2,
            ),
        )
    }

    // MARK: - Zero Count Quantifier Tests

    @Test
    func `zero count quantifier produces empty`() throws {
        // a{0} should produce empty (matches empty string)
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: 0,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(states: [s_match()], start: 0),
        )
    }

    @Test
    func `zero count quantifier on complex pattern`() throws {
        // (ab){0} should also produce empty
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: 0,
                    isEager: true,
                    child: .concat([.literal(["a"]), .literal(["b"])]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(states: [s_match()], start: 0),
        )
    }

    // MARK: - Up To N Quantifier Tests

    @Test
    func `up to five quantifier`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: 5,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_bin_union(1, 10),
                    s_byte(0x61, 2),
                    s_bin_union(3, 10),
                    s_byte(0x61, 4),
                    s_bin_union(5, 10),
                    s_byte(0x61, 6),
                    s_bin_union(7, 10),
                    s_byte(0x61, 8),
                    s_bin_union(9, 10),
                    s_byte(0x61, 10),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Nested Quantifier Tests

    @Test
    func `nested optional quantifiers (a{0,1}){0,1}`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: 1,
                    isEager: true,
                    child: .quantification(
                        Quantification(
                            min: 0,
                            max: 1,
                            isEager: true,
                            child: .literal(["a"]),
                        ),
                    ),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_bin_union(1, 3),
                    s_bin_union(2, 3),
                    s_byte(0x61, 3),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `nested repetition (a*)+`() throws {
        // (a*)+
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: nil,
                    isEager: true,
                    child: .quantification(
                        Quantification(
                            min: 0,
                            max: nil,
                            isEager: true,
                            child: .literal(["a"]),
                        ),
                    ),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_bin_union(0, 3),
                    s_bin_union(0, 3),
                    s_bin_union(2, 4),
                    s_match(),
                ],
                start: 2,
            ),
        )
    }

    @Test
    func `nested repetition (a+)*`() throws {
        // (a+)*
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: nil,
                    isEager: true,
                    child: .quantification(
                        Quantification(
                            min: 1,
                            max: nil,
                            isEager: true,
                            child: .literal(["a"]),
                        ),
                    ),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_bin_union(0, 2),
                    s_bin_union(0, 4),
                    s_bin_union(0, 4),
                    s_match(),
                ],
                start: 3,
            ),
        )
    }

    @Test
    func `range inside range (a{1,2}){2,3}`() throws {
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: 2,
                    isEager: true,
                    child: .quantification(
                        Quantification(
                            min: 2,
                            max: 3,
                            isEager: true,
                            child: .literal(["a"]),
                        ),
                    ),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    .byteRange(.init(start: 97, end: 97, next: 1)),
                    .byteRange(.init(start: 97, end: 97, next: 2)),
                    .binaryUnion(3, 4),
                    .byteRange(.init(start: 97, end: 97, next: 4)),
                    .binaryUnion(5, 9),
                    .byteRange(.init(start: 97, end: 97, next: 6)),
                    .byteRange(.init(start: 97, end: 97, next: 7)),
                    .binaryUnion(8, 9),
                    .byteRange(.init(start: 97, end: 97, next: 9)),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Empty Alternation Branch Tests

    @Test
    func `alternation with leading empty`() throws {
        // (|a) - empty or 'a'
        let nfa = try NFA.build(
            from: .alternation([
                .empty,
                .literal(["a"]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 2),
                    s_bin_union(2, 0),
                    s_match(),
                ],
                start: 1,
            ),
        )
    }

    @Test
    func `alternation with trailing empty`() throws {
        // (a|) - 'a' or empty
        let nfa = try NFA.build(
            from: .alternation([
                .literal(["a"]),
                .empty,
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 2),
                    s_bin_union(0, 2),
                    s_match(),
                ],
                start: 1,
            ),
        )
    }

    @Test
    func `alternation with middle empty`() throws {
        // (a||b) - 'a', empty, or 'b'
        let nfa = try NFA.build(
            from: .alternation([
                .literal(["a"]),
                .empty,
                .literal(["b"]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 3),
                    s_byte(0x62, 3),
                    s_union(0, 3, 1),
                    s_match(),
                ],
                start: 2,
            ),
        )
    }

    @Test
    func `alternation all empty`() throws {
        // (||) - three empty branches
        let nfa = try NFA.build(
            from: .alternation([
                .empty,
                .empty,
                .empty,
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_union(1, 1, 1),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Complex Nested Pattern Tests

    @Test
    func `deeply nested alternation ((a|b)|(c|d))`() throws {
        // ((a|b)|(c|d))
        let nfa = try NFA.build(
            from: .alternation([
                .alternation([.literal(["a"]), .literal(["b"])]),
                .alternation([.literal(["c"]), .literal(["d"])]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 7),
                    s_byte(0x62, 7),
                    s_bin_union(0, 1),
                    s_byte(0x63, 7),
                    s_byte(0x64, 7),
                    s_bin_union(3, 4),
                    s_bin_union(2, 5),
                    s_match(),
                ],
                start: 6,
            ),
        )
    }

    @Test
    func `alternation inside concatenation inside quantifier ((a|b)c)+`() throws {
        // ((a|b)c)+
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: nil,
                    isEager: true,
                    child: .concat([
                        .alternation([.literal(["a"]), .literal(["b"])]),
                        .literal(["c"]),
                    ]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 3),
                    s_byte(0x62, 3),
                    s_bin_union(0, 1),
                    s_byte(0x63, 4),
                    s_bin_union(2, 5),
                    s_match(),
                ],
                start: 2,
            ),
        )
    }

    @Test
    func `quantifier inside alternation inside concatenation a(b+|c*)d`() throws {
        // a(b+|c*)d
        let nfa = try NFA.build(
            from: .concat([
                .literal(["a"]),
                .alternation([
                    .quantification(
                        Quantification(
                            min: 1,
                            max: nil,
                            isEager: true,
                            child: .literal(["b"]),
                        ),
                    ),
                    .quantification(
                        Quantification(
                            min: 0,
                            max: nil,
                            isEager: true,
                            child: .literal(["c"]),
                        ),
                    ),
                ]),
                .literal(["d"]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 6),
                    s_byte(0x62, 2),
                    s_bin_union(1, 7),
                    s_byte(0x63, 4),
                    s_bin_union(3, 7),
                    s_bin_union(3, 7),
                    s_bin_union(1, 5),
                    s_byte(0x64, 8),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Character Class Edge Cases

    @Test
    func `single character class`() throws {
        // [a] - single character class
        let charClass = CharacterClass(ranges: ["a" ... "a"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(states: [s_byte(0x61, 1), s_match()], start: 0),
        )
    }

    @Test
    func `three disjoint ranges class`() throws {
        // [a-cf-hx-z]
        let charClass = CharacterClass(ranges: [
            "a" ... "c",
            "f" ... "h",
            "x" ... "z",
        ])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_sparse(
                        (start: 0x61, end: 0x63, next: 1),
                        (start: 0x66, end: 0x68, next: 1),
                        (start: 0x78, end: 0x7A, next: 1),
                    ),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `unicode class spanning byte lengths`() throws {
        // [a-é] spans ASCII (1 byte) and 2-byte UTF-8
        // UTF-8 sequences:
        // 1. [61-7F] - ASCII
        // 2. [C2][80-BF] - 2-byte for U+0080-00BF
        // 3. [C3][80-A9] - 2-byte for U+00C0-00E9
        let charClass = CharacterClass(ranges: ["a" ... "é"])
        let nfa = try NFA.build(from: .class(charClass))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_range(0x80, 0xBF, 3),
                    s_range(0x80, 0xA9, 3),
                    s_sparse(
                        (start: 0x61, end: 0x7F, next: 3),
                        (start: 0xC2, end: 0xC2, next: 0),
                        (start: 0xC3, end: 0xC3, next: 1),
                    ),
                    s_match(),
                ],
                start: 2,
            ),
        )
    }

    // MARK: - Concatenation Edge Cases

    @Test
    func `long concatenation`() throws {
        // abcdefghij - 10 character concatenation
        let chars: [HIRKind] = "abcdefghij".map { .literal([$0]) }
        let nfa = try NFA.build(from: .concat(chars))

        var expectedStates: [NFAState] = []
        let bytes: [UInt8] = [
            0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A,
        ]
        for (i, byte) in bytes.enumerated() {
            expectedStates.append(s_byte(byte, NFAStateID(UInt32(i + 1))))
        }
        expectedStates.append(s_match())

        equals(
            actual: nfa,
            expected: .init(states: expectedStates, start: 0),
        )
    }

    @Test
    func `concatenation with empty in middle`() throws {
        let nfa = try NFA.build(
            from: .concat([
                .literal(["a"]),
                .empty,
                .literal(["b"]),
            ]),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x62, 2),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Group Edge Cases

    @Test
    func `empty group`() throws {
        // () - empty group
        let nfa = try NFA.build(from: .group(Group(child: .empty)))

        equals(
            actual: nfa,
            expected: .init(states: [s_match()], start: 0),
        )
    }

    @Test
    func `group with quantifier`() throws {
        // (a)+ - group with plus
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: nil,
                    isEager: true,
                    child: .group(Group(child: .literal(["a"]))),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_bin_union(0, 2),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Mixed UTF-8 Length Tests

    @Test
    func `literal with mixed UTF-8 lengths`() throws {
        // "aéこ" = 'a' (1 byte) + 'é' (2 bytes) + 'こ' (3 bytes)
        let nfa = try NFA.build(from: .literal(["a", "é", "こ"]))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0xC3, 2),
                    s_byte(0xA9, 3),
                    s_byte(0xE3, 4),
                    s_byte(0x81, 5),
                    s_byte(0x93, 6),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    @Test
    func `four byte emoji sequence`() throws {
        // 𝄞 = U+1D11E (Musical symbol G clef) = F0 9D 84 9E
        let nfa = try NFA.build(from: .literal(["𝄞"]))

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0xF0, 1),
                    s_byte(0x9D, 2),
                    s_byte(0x84, 3),
                    s_byte(0x9E, 4),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - Exact Repetition Edge Cases

    @Test
    func `exact one repetition`() throws {
        // a{1} should be same as 'a'
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: 1,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(states: [s_byte(0x61, 1), s_match()], start: 0),
        )
    }

    @Test
    func `exact two repetition`() throws {
        // a{2}
        let nfa = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 2,
                    max: 2,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfa,
            expected: .init(
                states: [
                    s_byte(0x61, 1),
                    s_byte(0x61, 2),
                    s_match(),
                ],
                start: 0,
            ),
        )
    }

    // MARK: - At Least N Edge Cases

    @Test
    func `at least zero is star`() throws {
        // a{0,} should be same as a*
        let nfaStar = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: nil,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        let nfaAtLeast = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 0,
                    max: nil,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfaStar,
            expected: nfaAtLeast,
        )
    }

    @Test
    func `at least one is plus`() throws {
        // a{1,} should be same as a+
        let nfaPlus = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: nil,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        let nfaAtLeast = try NFA.build(
            from: .quantification(
                Quantification(
                    min: 1,
                    max: nil,
                    isEager: true,
                    child: .literal(["a"]),
                ),
            ),
        )

        equals(
            actual: nfaPlus,
            expected: nfaAtLeast,
        )
    }
}

// TODO: add optimization and add the following tests
/*
 Non-Applicable Tests
 Rust Test: compile_unanchored_prefix
 Reason: No unanchored prefix ((?s:.)*?) support
 ────────────────────────────────────────
 Rust Test: compile_no_unanchored_prefix_with_start_anchor
 Reason: No anchor (^) support
 ────────────────────────────────────────
 Rust Test: compile_yes_unanchored_prefix_with_end_anchor
 Reason: No anchor ($) support
 ────────────────────────────────────────
 Rust Test: compile_alternation (optimized a|b → range)
 Reason: Our implementation doesn't optimize alternation of adjacent chars to ranges
 ────────────────────────────────────────
 Rust Test: compile_many_start_pattern
 Reason: No multi-pattern NFA support
 ────────────────────────────────────────
 */
