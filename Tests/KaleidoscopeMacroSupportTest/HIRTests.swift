//
//  HIRTests.swift
//
//
//  Created by Larry Zeng on 11/30/23.
//

import Testing

import KaleidoscopeMacroSupport

enum TestError: Error {
    case cannotGenerateCharacterSequence
}

func characters(_ start: Character, _ end: Character, inverted _: Bool = false) -> HIR.ScalarByteRanges {
    [start.scalarByte ... end.scalarByte]
}

func disemableString(_ string: String) -> HIR {
    .concat(string.map { .literal($0.scalarBytes) })
}

func literal(_ char: Character) -> HIR {
    .literal(char.scalarBytes)
}

@Suite
struct HIRTests {
    @Test(arguments: [
        (
            "ab",
            .success(disemableString("ab")),
        ),
        (
            " \n\t", .success(disemableString(" \n\t")),
        ),
        (
            "a*",
            .failure(HIRParsingError.greedyMatchingMore),
        ),
        (
            "a|b",
            .success(.alternation([literal("a"), literal("b")])),
        ),
        (
            "[a-z]",
            .success(.class(characters("a", "z"))),
        ),
        (
            "[a-c]+?",
            .success(.concat([.class(characters("a", "c")), .loop(.class(characters("a", "c")))])),
        ),
        (
            "[a-cx-z]+?",
            .success(.concat([
                .class(characters("a", "c") + characters("x", "z")),
                .loop(.class(characters("a", "c") + characters("x", "z"))),
            ])),
        ),

        (
            "(foo)+?",
            .success(.concat([disemableString("foo"), .loop(disemableString("foo"))])),
        ),
        (
            "(foo|bar)+?",
            .success(.concat([
                .alternation([disemableString("foo"), disemableString("bar")]),
                .loop(.alternation([disemableString("foo"), disemableString("bar")])),
            ])),
        ),
        (
            ".",
            .success(.class([HIR.ScalarByte.min ... HIR.ScalarByte.max])),
        ),
    ] as [(String, Result<HIR, HIRParsingError>)])
    func hIRRegexGeneration(regexContent: String, expected: Result<HIR, HIRParsingError>) throws {
        let actual = Result { () throws(HIRParsingError) in
            try HIR(regex: regexContent)
        }
        #expect(actual == expected)
    }

    @Test(arguments: [
        ("\\w", disemableString("\\w")),
        ("\\[a-b\\]", disemableString("\\[a-b\\]")),
    ])
    func hIRTokenGeneration(tokenContent: String, expected: HIR) throws {
        let actual = try HIR(token: tokenContent)
        #expect(actual == expected, "The HIR generated for token `\(tokenContent)` is incorrect")
    }

    @Test(arguments: [
        ("ab", 4),
        ("[a-b]", 1),
        ("a|b", 2),
        ("(foo|bar)+?", 6),
        ("(foo|long)+?(bar)", 12),
    ])
    func hIRPriority(regexContent: String, expected: UInt) throws {
        let hir = try HIR(regex: regexContent)
        let actual = hir.priority()
        #expect(actual == expected, "The priority should be \(expected) instead of \(actual)")
    }
}
