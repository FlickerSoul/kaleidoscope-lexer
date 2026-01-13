//
//  HIRTests.swift
//
//
//  Created by Larry Zeng on 11/30/23.
//

import Testing

import KaleidoscopeMacroSupport

enum TestError: Error {
    case CannotGenerateCharacterSequence
}

func characters(_ start: Character, _ end: Character, inverted: Bool = false) -> HIR.ScalarByteRanges {
    return [start.scalarByte ... end.scalarByte]
}

func disemableString(_ string: String) -> HIR {
    return .Concat(string.map { .Literal($0.scalarBytes) })
}

func literal(_ char: Character) -> HIR {
    return .Literal(char.scalarBytes)
}

@Suite
struct HIRTests {
    @Test(arguments: [
        (
            "ab",
            .success(disemableString("ab"))
        ),
        (
            " \n\t", .success(disemableString(" \n\t"))
        ),
        (
            "a*",
            .failure(HIRParsingError.GreedyMatchingMore)
        ),
        (
            "a|b",
            .success(.Alternation([literal("a"), literal("b")]))
        ),
        (
            "[a-z]",
            .success(.Class(characters("a", "z")))
        ),
        (
            "[a-c]+?",
            .success(.Concat([.Class(characters("a", "c")), .Loop(.Class(characters("a", "c")))]))
        ),
        (
            "[a-cx-z]+?",
            .success(.Concat([.Class(characters("a", "c") + characters("x", "z")), .Loop(.Class(characters("a", "c") + characters("x", "z")))]))
        ),
        
        (
            "(foo)+?",
            .success(.Concat([disemableString("foo"), .Loop(disemableString("foo"))]))
        ),
        (
            "(foo|bar)+?",
            .success(.Concat([.Alternation([disemableString("foo"), disemableString("bar")]), .Loop(.Alternation([disemableString("foo"), disemableString("bar")]))]))
        ),
        (
            ".",
            .success(.Class([HIR.ScalarByte.min ... HIR.ScalarByte.max]))
        ),
    ] as [(String, Result<HIR, HIRParsingError>)])
    func testHIRRegexGeneration(regexContent: String, expected: Result<HIR, HIRParsingError>) throws {
        let actual = Result { () throws(HIRParsingError) in
            try HIR(regex: regexContent)
        }
        #expect(actual == expected)
    }

    @Test(arguments: [
        ("\\w", disemableString("\\w")),
        ("\\[a-b\\]", disemableString("\\[a-b\\]")),
    ])
    func testHIRTokenGeneration(tokenContent: String, expected: HIR) throws {
        let actual = try! HIR(token: tokenContent)
        #expect(actual == expected, "The HIR generated for token `\(tokenContent)` is incorrect")
    }

    @Test(arguments: [
        ("ab", 4),
        ("[a-b]", 1),
        ("a|b", 2),
        ("(foo|bar)+?", 6),
        ("(foo|long)+?(bar)", 12),
    ])
    func testHIRPriority(regexContent: String, expected: UInt) throws {
        let hir = try! HIR(regex: regexContent)
        let actual = hir.priority()
        #expect(actual == expected, "The priority should be \(expected) instead of \(actual)")
    }
}
