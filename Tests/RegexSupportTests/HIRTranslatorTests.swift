//
//  HIRTranslatorTests.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//

import _RegexParser
@testable import RegexSupport
import Testing

/// Parses a regex pattern string and converts it to HIRKind
func parseToHIR(_ pattern: String) throws -> HIRKind {
    let ast = try _RegexParser.parse(pattern, .traditional)
    return try HIRKind(ast)
}

@Suite("HIRTranslator Tests")
struct HIRTranslatorTests {
    // MARK: - Literal Tests

    @Test(arguments: [
        ("a", HIRKind.literal(["a"])),
        ("abc", HIRKind.concat([.literal(["a"]), .literal(["b"]), .literal(["c"])])),
        ("1", HIRKind.literal(["1"])),
        (" ", HIRKind.literal([" "])),
    ])
    func `literal characters`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test(arguments: [
        ("\t| |\n", HIRKind.alternation([.literal("\t"), .literal(" "), .literal("\n")])),
    ])
    func `altertive literals`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test(arguments: [
        ("\n", HIRKind.literal(["\n"])),
        ("\t", HIRKind.literal(["\t"])),
        ("\r", HIRKind.literal(["\r"])),
        (#"\\"#, HIRKind.literal([#"\"#])),
        (#"\a"#, HIRKind.literal("\u{0007}")),
        (#"\e"#, HIRKind.literal("\u{001B}")),
        (#"\f"#, HIRKind.literal("\u{000C}")),
    ])
    func `escaped characters`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    // MARK: - Escaped Character Class Tests

    @Test(arguments: [
        (#"\d"#, HIRKind.class(.decimalDigits)),
        (#"\D"#, HIRKind.class(.decimalDigits.inverting())),
        (#"\w"#, HIRKind.class(.wordCharacters)),
        (#"\W"#, HIRKind.class(.wordCharacters.inverting())),
        (#"\s"#, HIRKind.class(.whiteSpaces)),
        (#"\S"#, HIRKind.class(.whiteSpaces.inverting())),
        (#"\h"#, HIRKind.class(.horizontalWhiteSpaces)),
        (#"\H"#, HIRKind.class(.horizontalWhiteSpaces.inverting())),
        (#"\v"#, HIRKind.class(.verticalWhiteSpaces)),
        (#"\V"#, HIRKind.class(.verticalWhiteSpaces.inverting())),
        // (#"\N"#, HIRKind.class(.newLine.inverting())), // Not supported by traditional syntax option
    ])
    func `escaped character classes`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test
    func `escaped newline sequence`() throws {
        let result = try parseToHIR(#"\R"#)
        let expected = HIRKind.alternation([
            .literal("\n"),
            .literal("\r\n".map(\.self)),
            .literal("\r"),
            .literal("\u{000B}"),
            .literal("\u{000C}"),
            .literal("\u{0085}"),
            .literal("\u{2028}"),
            .literal("\u{2029}"),
        ])
        #expect(result == expected)
    }

    @Test
    func `escaped character class in concatenation`() throws {
        let result = try parseToHIR(#"\d\w"#)
        let expected = HIRKind.concat([
            .class(.decimalDigits),
            .class(.wordCharacters),
        ])
        #expect(result == expected)
    }

    @Test
    func `escaped character class with quantifier`() throws {
        let result = try parseToHIR(#"\d+"#)
        let expected = HIRKind.quantification(
            Quantification(
                min: 1,
                max: nil,
                isEager: true,
                child: .class(.decimalDigits),
            ),
        )
        #expect(result == expected)
    }

    @Test(arguments: [
        #"\b"#,
        #"\B"#,
    ])
    func `unsupported escaped characters throw errors`(pattern: String) throws {
        #expect(throws: RegexConversionError.self) {
            try parseToHIR(pattern)
        }
    }

    // MARK: - Quantification Tests

    @Test(arguments: [
        (
            "a*",
            HIRKind.quantification(
                Quantification(min: 0, max: nil, isEager: true, child: .literal(["a"])),
            ),
        ),
        (
            "a+",
            HIRKind.quantification(
                Quantification(min: 1, max: nil, isEager: true, child: .literal(["a"])),
            ),
        ),
        (
            "a?",
            HIRKind.quantification(
                Quantification(min: 0, max: 1, isEager: true, child: .literal(["a"])),
            ),
        ),
    ])
    func `basic quantifiers`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test(arguments: [
        (
            "a*?",
            HIRKind.quantification(
                Quantification(min: 0, max: nil, isEager: false, child: .literal(["a"])),
            ),
        ),
        (
            "a+?",
            HIRKind.quantification(
                Quantification(min: 1, max: nil, isEager: false, child: .literal(["a"])),
            ),
        ),
        (
            "a??",
            HIRKind.quantification(
                Quantification(min: 0, max: 1, isEager: false, child: .literal(["a"])),
            ),
        ),
    ])
    func `reluctant quantifiers`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test(arguments: [
        (
            "a{3}",
            HIRKind.quantification(
                Quantification(min: 3, max: 3, isEager: true, child: .literal(["a"])),
            ),
        ),
        (
            "a{2,5}",
            HIRKind.quantification(
                Quantification(min: 2, max: 5, isEager: true, child: .literal(["a"])),
            ),
        ),
        (
            "a{2,}",
            HIRKind.quantification(
                Quantification(min: 2, max: nil, isEager: true, child: .literal(["a"])),
            ),
        ),
        (
            "a{,3}",
            HIRKind.quantification(
                Quantification(min: 0, max: 3, isEager: true, child: .literal(["a"])),
            ),
        ),
    ])
    func `range quantifiers`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test
    func `possessive quantifier throws error`() throws {
        #expect(throws: RegexConversionError.self) {
            try parseToHIR("a*+")
        }
    }

    // MARK: - Alternation Tests

    @Test(arguments: [
        (
            "a|b",
            HIRKind.alternation([.literal(["a"]), .literal(["b"])]),
        ),
        (
            "a|b|c",
            HIRKind.alternation([.literal(["a"]), .literal(["b"]), .literal(["c"])]),
        ),
        (
            "ab|cd",
            HIRKind.alternation([
                .concat([.literal(["a"]), .literal(["b"])]),
                .concat([.literal(["c"]), .literal(["d"])]),
            ]),
        ),
    ])
    func `alternation patterns`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    // MARK: - Concatenation Tests

    @Test(arguments: [
        (
            "ab",
            HIRKind.concat([.literal(["a"]), .literal(["b"])]),
        ),
        (
            "abc",
            HIRKind.concat([.literal(["a"]), .literal(["b"]), .literal(["c"])]),
        ),
    ])
    func `concatenation patterns`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    // MARK: - Group Tests

    @Test(arguments: [
        (
            "(a)",
            HIRKind.group(Group(child: .literal(["a"]))),
        ),
        (
            "(ab)",
            HIRKind.group(Group(child: .concat([.literal(["a"]), .literal(["b"])]))),
        ),
        (
            "(a|b)",
            HIRKind.group(Group(child: .alternation([.literal(["a"]), .literal(["b"])]))),
        ),
    ])
    func `group patterns`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test
    func `nested groups`() throws {
        let result = try parseToHIR("((a))")
        let expected = HIRKind.group(Group(child: .group(Group(child: .literal(["a"])))))
        #expect(result == expected)
    }

    // MARK: - Character Class Tests

    @Test
    func `single character class`() throws {
        let result = try parseToHIR("[a]")
        let expected = HIRKind.class(CharacterClass(ranges: ["a" ... "a"]))
        #expect(result == expected)
    }

    @Test
    func `character range class`() throws {
        let result = try parseToHIR("[a-z]")
        let expected = HIRKind.class(CharacterClass(ranges: ["a" ... "z"]))
        #expect(result == expected)
    }

    @Test
    func `multiple characters class`() throws {
        let result = try parseToHIR("[abc]")
        let expected = HIRKind.class(
            CharacterClass(ranges: [
                "a" ... "a",
                "b" ... "b",
                "c" ... "c",
            ]),
        )
        #expect(result == expected)
    }

    // MARK: - Dot Tests

    @Test
    func `dot pattern`() throws {
        let result = try parseToHIR(".")
        let expected = HIRKind.class(CharacterClass.dot())
        #expect(result == expected)
    }

    @Test
    func `dot with quantifier`() throws {
        let result = try parseToHIR(".*")
        let expected = HIRKind.quantification(
            Quantification(
                min: 0,
                max: nil,
                isEager: true,
                child: .class(CharacterClass.dot()),
            ),
        )
        #expect(result == expected)
    }

    // MARK: - Quote Tests

    @Test
    func `quoted literal`() throws {
        let result = try parseToHIR("\\Qabc\\E")
        let expected = HIRKind.literal(["a", "b", "c"])
        #expect(result == expected)
    }

    @Test
    func `quoted special characters`() throws {
        let result = try parseToHIR("\\Q.*+?\\E")
        let expected = HIRKind.literal([".", "*", "+", "?"])
        #expect(result == expected)
    }

    // MARK: - Error Cases Tests

    @Test(arguments: [
        "^", // caret anchor
        "$", // dollar anchor
    ])
    func `unsupported anchors throw errors`(pattern: String) throws {
        #expect(throws: RegexConversionError.self) {
            try parseToHIR(pattern)
        }
    }

    @Test
    func `backreference throws error`() throws {
        #expect(throws: RegexConversionError.self) {
            try parseToHIR("(a)\\1")
        }
    }

    // MARK: - Complex Pattern Tests

    @Test
    func `combined quantifier and alternation`() throws {
        let result = try parseToHIR("(a|b)*")
        let expected = HIRKind.quantification(
            Quantification(
                min: 0,
                max: nil,
                isEager: true,
                child: .group(Group(child: .alternation([.literal(["a"]), .literal(["b"])]))),
            ),
        )
        #expect(result == expected)
    }

    @Test
    func `character class with quantifier`() throws {
        let result = try parseToHIR("[a-z]+")
        let expected = HIRKind.quantification(
            Quantification(
                min: 1,
                max: nil,
                isEager: true,
                child: .class(CharacterClass(ranges: ["a" ... "z"])),
            ),
        )
        #expect(result == expected)
    }

    @Test
    func `nested groups with quantifiers`() throws {
        let result = try parseToHIR("((ab)+)")
        let expected = HIRKind.group(
            Group(
                child:
                .quantification(
                    Quantification(
                        min: 1,
                        max: nil,
                        isEager: true,
                        child: .group(
                            Group(child: .concat([.literal(["a"]), .literal(["b"])])),
                        ),
                    ),
                ),
            ),
        )
        #expect(result == expected)
    }

    // MARK: - Empty Pattern Tests

    @Test
    func `empty pattern`() throws {
        let result = try parseToHIR("")
        let expected = HIRKind.empty
        #expect(result == expected)
    }

    @Test
    func `empty group`() throws {
        let result = try parseToHIR("()")
        let expected = HIRKind.group(Group(child: .empty))
        #expect(result == expected)
    }

    @Test
    func `empty non-capturing group`() throws {
        let result = try parseToHIR("(?:)")
        let expected = HIRKind.group(Group(child: .empty))
        #expect(result == expected)
    }

    @Test
    func `empty alternation`() throws {
        let result = try parseToHIR("|")
        let expected = HIRKind.alternation([.empty, .empty])
        #expect(result == expected)
    }

    @Test
    func `alternation with empty branches`() throws {
        let result = try parseToHIR("()|()")
        let expected = HIRKind.alternation([
            .group(Group(child: .empty)),
            .group(Group(child: .empty)),
        ])
        #expect(result == expected)
    }

    @Test
    func `alternation starting with empty`() throws {
        let result = try parseToHIR("(|b)")
        let expected = HIRKind.group(Group(child: .alternation([.empty, .literal(["b"])])))
        #expect(result == expected)
    }

    @Test
    func `alternation ending with empty`() throws {
        let result = try parseToHIR("(a|)")
        let expected = HIRKind.group(Group(child: .alternation([.literal(["a"]), .empty])))
        #expect(result == expected)
    }

    @Test
    func `alternation with middle empty`() throws {
        let result = try parseToHIR("(a||c)")
        let expected = HIRKind.group(
            Group(
                child: .alternation([
                    .literal(["a"]),
                    .empty,
                    .literal(["c"]),
                ]),
            ),
        )
        #expect(result == expected)
    }

    @Test
    func `alternation all empty`() throws {
        let result = try parseToHIR("(||)")
        let expected = HIRKind.group(Group(child: .alternation([.empty, .empty, .empty])))
        #expect(result == expected)
    }

    // MARK: - Escape Sequence Tests (from Rust escape test)

    @Test
    func `escaped metacharacters`() throws {
        let result = try parseToHIR(#"\.\+\*\?\(\)\|\[\]\{\}"#)
        let expected = HIRKind.concat([
            .literal(["."]),
            .literal(["+"]),
            .literal(["*"]),
            .literal(["?"]),
            .literal(["("]),
            .literal([")"]),
            .literal(["|"]),
            .literal(["["]),
            .literal(["]"]),
            .literal(["{"]),
            .literal(["}"]),
        ])
        #expect(result == expected)
    }

    @Test
    func `escaped backslash`() throws {
        let result = try parseToHIR(#"\\"#)
        let expected = HIRKind.literal(["\\"])
        #expect(result == expected)
    }

    // MARK: - Additional Repetition Tests (from Rust repetition test)

    @Test
    func `repetition with exact count`() throws {
        let result = try parseToHIR("a{1}")
        let expected = HIRKind.quantification(
            Quantification(
                min: 1,
                max: 1,
                isEager: true,
                child: .literal(["a"]),
            ),
        )
        #expect(result == expected)
    }

    @Test
    func `repetition exact count reluctant`() throws {
        let result = try parseToHIR("a{1}?")
        let expected = HIRKind.quantification(
            Quantification(
                min: 1,
                max: 1,
                isEager: false,
                child: .literal(["a"]),
            ),
        )
        #expect(result == expected)
    }

    @Test
    func `repetition range reluctant`() throws {
        let result = try parseToHIR("a{1,2}?")
        let expected = HIRKind.quantification(
            Quantification(
                min: 1,
                max: 2,
                isEager: false,
                child: .literal(["a"]),
            ),
        )
        #expect(result == expected)
    }

    @Test
    func `repetition unbounded reluctant`() throws {
        let result = try parseToHIR("a{1,}?")
        let expected = HIRKind.quantification(
            Quantification(
                min: 1,
                max: nil,
                isEager: false,
                child: .literal(["a"]),
            ),
        )
        #expect(result == expected)
    }

    @Test
    func `quantifier in concatenation`() throws {
        let result = try parseToHIR("ab?")
        let expected = HIRKind.concat([
            .literal(["a"]),
            .quantification(Quantification(min: 0, max: 1, isEager: true, child: .literal(["b"]))),
        ])
        #expect(result == expected)
    }

    @Test
    func `quantifier on group`() throws {
        let result = try parseToHIR("(ab)?")
        let expected = HIRKind.quantification(
            Quantification(
                min: 0,
                max: 1,
                isEager: true,
                child: .group(Group(child: .concat([.literal(["a"]), .literal(["b"])]))),
            ),
        )
        #expect(result == expected)
    }

    @Test
    func `alternation with quantifier`() throws {
        let result = try parseToHIR("a|b?")
        let expected = HIRKind.alternation([
            .literal(["a"]),
            .quantification(Quantification(min: 0, max: 1, isEager: true, child: .literal(["b"]))),
        ])
        #expect(result == expected)
    }

    // MARK: - Concatenation and Alternation Combination Tests (from Rust cat_alt test)

    @Test
    func `group with concatenation`() throws {
        let result = try parseToHIR("(ab)")
        let expected = HIRKind.group(Group(child: .concat([.literal(["a"]), .literal(["b"])])))
        #expect(result == expected)
    }

    @Test
    func `nested alternation in group`() throws {
        let result = try parseToHIR("(a|b)")
        let expected = HIRKind.group(
            Group(child: .alternation([.literal(["a"]), .literal(["b"])])),
        )
        #expect(result == expected)
    }

    @Test
    func `alternation of groups`() throws {
        let result = try parseToHIR("(a)|(b)")
        let expected = HIRKind.alternation([
            .group(Group(child: .literal(["a"]))),
            .group(Group(child: .literal(["b"]))),
        ])
        #expect(result == expected)
    }

    @Test
    func `deeply nested groups`() throws {
        let result = try parseToHIR("((a|b)|(c|d))")
        let expected = HIRKind.group(
            Group(
                child: .alternation([
                    .group(Group(child: .alternation([.literal(["a"]), .literal(["b"])]))),
                    .group(Group(child: .alternation([.literal(["c"]), .literal(["d"])]))),
                ]),
            ),
        )
        #expect(result == expected)
    }

    // MARK: - Additional Character Class Tests (from Rust class_bracketed test)

    @Test
    func `character class range combined`() throws {
        let result = try parseToHIR("[a-fd-h]")
        // After normalization: a-h
        let expected = HIRKind.class(CharacterClass(ranges: ["a" ... "h"]))
        #expect(result == expected)
    }

    @Test
    func `character class overlapping ranges`() throws {
        let result = try parseToHIR("[a-fg-m]")
        // After normalization: a-m
        let expected = HIRKind.class(CharacterClass(ranges: ["a" ... "m"]))
        #expect(result == expected)
    }

    @Test
    func `character class with null`() throws {
        let result = try parseToHIR("[\\x00]")
        let expected = HIRKind.class(CharacterClass(ranges: ["\0" ... "\0"]))
        #expect(result == expected)
    }

    @Test
    func `character class with newline`() throws {
        let result = try parseToHIR("[\\n]")
        let expected = HIRKind.class(CharacterClass(ranges: ["\n" ... "\n"]))
        #expect(result == expected)
    }

    @Test
    func `character class bracket literal`() throws {
        let result = try parseToHIR("[\\[]")
        let expected = HIRKind.class(CharacterClass(ranges: ["[" ... "["]))
        #expect(result == expected)
    }

    @Test
    func `character class ampersand`() throws {
        let result = try parseToHIR("[&]")
        let expected = HIRKind.class(CharacterClass(ranges: ["&" ... "&"]))
        #expect(result == expected)
    }

    @Test
    func `character class tilde`() throws {
        let result = try parseToHIR("[~]")
        let expected = HIRKind.class(CharacterClass(ranges: ["~" ... "~"]))
        #expect(result == expected)
    }

    @Test
    func `character class hyphen`() throws {
        let result = try parseToHIR("[-]")
        let expected = HIRKind.class(CharacterClass(ranges: ["-" ... "-"]))
        #expect(result == expected)
    }

    @Test
    func `character class escaped hyphen`() throws {
        let result = try parseToHIR("[\\-]")
        let expected = HIRKind.class(CharacterClass(ranges: ["-" ... "-"]))
        #expect(result == expected)
    }

    // MARK: - Character Class Intersection Tests (from Rust class_bracketed_intersect test)

    @Test
    func `character class intersection basic`() throws {
        let result = try parseToHIR("[abc&&b-c]")
        let expected = HIRKind.class(CharacterClass(ranges: ["b" ... "c"]))
        #expect(result == expected)
    }

    @Test
    func `character class intersection with nested class`() throws {
        let result = try parseToHIR("[abc&&[b-c]]")
        let expected = HIRKind.class(CharacterClass(ranges: ["b" ... "c"]))
        #expect(result == expected)
    }

    @Test
    func `character class intersection both nested`() throws {
        let result = try parseToHIR("[[abc]&&[b-c]]")
        let expected = HIRKind.class(CharacterClass(ranges: ["b" ... "c"]))
        #expect(result == expected)
    }

    @Test
    func `character class triple intersection`() throws {
        let result = try parseToHIR("[a-z&&b-y&&c-x]")
        let expected = HIRKind.class(CharacterClass(ranges: ["c" ... "x"]))
        #expect(result == expected)
    }

    @Test
    func `character class intersection order independent`() throws {
        let result1 = try parseToHIR("[c-da-b&&a-d]")
        let result2 = try parseToHIR("[a-d&&c-da-b]")
        let expected = HIRKind.class(CharacterClass(ranges: ["a" ... "d"]))
        #expect(result1 == expected)
        #expect(result2 == expected)
    }

    @Test
    func `character class intersection range subset`() throws {
        let result = try parseToHIR("[a-z&&a-c]")
        let expected = HIRKind.class(CharacterClass(ranges: ["a" ... "c"]))
        #expect(result == expected)
    }

    @Test
    func `character class intersection caret`() throws {
        let result = try parseToHIR("[\\^&&^]")
        let expected = HIRKind.class(CharacterClass(ranges: ["^" ... "^"]))
        #expect(result == expected)
    }

    @Test
    func `character class intersection precedence`() throws {
        // [a-w&&[^c-g]z] means intersection of [a-w] with [[^c-g]z]
        // [^c-g] inside a class acts as a nested class with negation
        // This tests that && has lower precedence than nested class union
        let result = try parseToHIR("[a-w&&[^c-g]z]")
        // [a-w] intersect [^c-g union z] = [a-w] intersect [a-b, h-z]
        // = [a-b, h-w]
        let expected = HIRKind.class(
            CharacterClass(ranges: [
                "a" ... "b",
                "h" ... "w",
            ]),
        )
        #expect(result == expected)
    }

    // MARK: - Character Class Difference Tests (from Rust class_bracketed_difference test)

    @Test
    func `character class difference basic`() throws {
        // [a-z--m-n] = a-z minus m-n = [a-l, o-z]
        let result = try parseToHIR("[a-z--m-n]")
        let expected = HIRKind.class(
            CharacterClass(ranges: [
                "a" ... "l",
                "o" ... "z",
            ]),
        )
        #expect(result == expected)
    }

    @Test
    func `character class difference alpha minus lower`() throws {
        // [a-zA-Z--a-z] = [A-Z]
        let result = try parseToHIR("[a-zA-Z--a-z]")
        let expected = HIRKind.class(CharacterClass(ranges: ["A" ... "Z"]))
        #expect(result == expected)
    }

    // MARK: - Character Class Symmetric Difference Tests (from Rust class_bracketed_symmetric_difference test)

    @Test
    func `character class symmetric difference`() throws {
        // [a-g~~c-j] = (a-g union c-j) minus (a-g intersect c-j)
        // = [a-j] minus [c-g] = [a-b, h-j]
        let result = try parseToHIR("[a-g~~c-j]")
        let expected = HIRKind.class(
            CharacterClass(ranges: [
                "a" ... "b",
                "h" ... "j",
            ]),
        )
        #expect(result == expected)
    }

    @Test
    func `character class symmetric difference same ranges`() throws {
        // [a-z~~a-z] = empty set
        let result = try parseToHIR("[a-z~~a-z]")
        let expected = HIRKind.class(CharacterClass(ranges: []))
        #expect(result == expected)
    }

    @Test
    func `character class symmetric difference disjoint`() throws {
        // [a-c~~x-z] = [a-c, x-z] (no overlap)
        let result = try parseToHIR("[a-c~~x-z]")
        let expected = HIRKind.class(
            CharacterClass(ranges: [
                "a" ... "c",
                "x" ... "z",
            ]),
        )
        #expect(result == expected)
    }

    // MARK: - Character Class Union Tests (from Rust class_bracketed_union test)

    @Test
    func `character class union basic`() throws {
        let result = try parseToHIR("[a-zA-Z]")
        let expected = HIRKind.class(
            CharacterClass(ranges: [
                "A" ... "Z",
                "a" ... "z",
            ]),
        )
        #expect(result == expected)
    }

    // MARK: - Negated Character Class Tests

    @Test
    func `negated character class single char`() throws {
        let result = try parseToHIR("[^a]")
        // Negation of [a] should be everything except 'a'
        // This creates [min...('a'-1), ('a'+1)...max]
        let negatedClass = CharacterClass(ranges: ["a" ... "a"]).inverting()
        let expected = HIRKind.class(negatedClass)
        #expect(result == expected)
    }

    @Test
    func `negated character class range`() throws {
        let result = try parseToHIR("[^a-z]")
        let negatedClass = CharacterClass(ranges: ["a" ... "z"]).inverting()
        let expected = HIRKind.class(negatedClass)
        #expect(result == expected)
    }

    // MARK: - Nested Character Class Tests (from Rust class_bracketed_nested test)

    @Test
    func `nested character class with negation`() throws {
        // [a[^c]] = union of [a] and [^c] = everything except c that isn't a
        // Actually [a[^c]] means union of 'a' with negation of 'c'
        // = [^c] since 'a' is already not 'c'
        let result = try parseToHIR("[a[^c]]")
        let negatedC = CharacterClass(ranges: ["c" ... "c"]).inverting()
        let expected = HIRKind.class(negatedC)
        #expect(result == expected)
    }

    @Test
    func `nested negated class union with range`() throws {
        // [a-b[^c]] = [a-b] union [^c] = [^c] (since a-b is subset of [^c])
        let result = try parseToHIR("[a-b[^c]]")
        let negatedC = CharacterClass(ranges: ["c" ... "c"]).inverting()
        let expected = HIRKind.class(negatedC)
        #expect(result == expected)
    }

    // MARK: - Character Property Tests

    @Test(arguments: [
        // POSIX character classes
        (#"[[:alnum:]]"#, HIRKind.class(.posixAlnum)),
        (#"[[:blank:]]"#, HIRKind.class(.posixBlank)),
        (#"[[:graph:]]"#, HIRKind.class(.posixGraph)),
        (#"[[:print:]]"#, HIRKind.class(.posixPrint)),
        (#"[[:word:]]"#, HIRKind.class(.posixWord)),
        (#"[[:xdigit:]]"#, HIRKind.class(.posixXdigit)),
    ])
    func `POSIX character classes`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test(arguments: [
        // Inverted POSIX character classes
        (#"[[:^alnum:]]"#, HIRKind.class(.posixAlnum.inverting())),
        (#"[[:^blank:]]"#, HIRKind.class(.posixBlank.inverting())),
        (#"[[:^graph:]]"#, HIRKind.class(.posixGraph.inverting())),
        (#"[[:^print:]]"#, HIRKind.class(.posixPrint.inverting())),
        (#"[[:^word:]]"#, HIRKind.class(.posixWord.inverting())),
        (#"[[:^xdigit:]]"#, HIRKind.class(.posixXdigit.inverting())),
    ])
    func `inverted POSIX character classes`(pattern: String, expected: HIRKind) throws {
        let result = try parseToHIR(pattern)
        #expect(result == expected)
    }

    @Test
    func `general category lowercase letter`() throws {
        let result = try parseToHIR(#"\p{Ll}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Lowercase 'a' should be in the class
        #expect(charClass.ranges.contains { $0.contains("a") })
        // Uppercase 'A' should NOT be in the class
        #expect(!charClass.ranges.contains { $0.contains("A") })
    }

    @Test
    func `general category uppercase letter`() throws {
        let result = try parseToHIR(#"\p{Lu}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Uppercase 'A' should be in the class
        #expect(charClass.ranges.contains { $0.contains("A") })
        // Lowercase 'a' should NOT be in the class
        #expect(!charClass.ranges.contains { $0.contains("a") })
    }

    @Test
    func `general category letter`() throws {
        let result = try parseToHIR(#"\p{L}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Both 'a' and 'A' should be in the class
        #expect(charClass.ranges.contains { $0.contains("a") })
        #expect(charClass.ranges.contains { $0.contains("A") })
        // Digit '0' should NOT be in the class
        #expect(!charClass.ranges.contains { $0.contains("0") })
    }

    @Test
    func `general category number`() throws {
        let result = try parseToHIR(#"\p{N}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Digit '0' should be in the class
        #expect(charClass.ranges.contains { $0.contains("0") })
        // Letter 'a' should NOT be in the class
        #expect(!charClass.ranges.contains { $0.contains("a") })
    }

    @Test
    func `inverted general category`() throws {
        let result = try parseToHIR(#"\P{Lu}"#)
        let charClass = try #require(result[case: \.class])
        // Lowercase 'a' should be in the inverted class
        #expect(charClass.ranges.contains { $0.contains("a") })
        // Uppercase 'A' should NOT be in the inverted class
        #expect(!charClass.ranges.contains { $0.contains("A") })
    }

    @Test
    func `script Latin`() throws {
        let result = try parseToHIR(#"\p{Latin}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // ASCII letters should be in Latin script
        #expect(charClass.ranges.contains { $0.contains("a") })
        #expect(charClass.ranges.contains { $0.contains("A") })
    }

    @Test
    func `script Greek`() throws {
        let result = try parseToHIR(#"\p{Greek}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Greek alpha should be in the class
        #expect(charClass.ranges.contains { $0.contains("α") })
        // ASCII 'a' should NOT be in Greek script
        #expect(!charClass.ranges.contains { $0.contains("a") })
    }

    @Test
    func `binary property Alphabetic`() throws {
        let result = try parseToHIR(#"\p{Alphabetic}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Letters should be alphabetic
        #expect(charClass.ranges.contains { $0.contains("a") })
    }

    @Test
    func `binary property Whitespace`() throws {
        let result = try parseToHIR(#"\p{Whitespace}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Space should be whitespace
        #expect(charClass.ranges.contains { $0.contains(" ") })
        // 'a' should NOT be whitespace
        #expect(!charClass.ranges.contains { $0.contains("a") })
    }

    @Test
    func `ascii property`() throws {
        let result = try parseToHIR(#"\p{ascii}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges == [
            .min ... "\u{7F}",
        ])
    }

    @Test
    func `any property`() throws {
        let result = try parseToHIR(#"\p{any}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass == .trueAny)
    }

    @Test
    func `character property in character class`() throws {
        // Combining property with other elements in a character class
        let result = try parseToHIR(#"[\p{Lu}0-9]"#)
        let charClass = try #require(result[case: \.class])
        // Should contain uppercase letters and digits
        #expect(charClass.ranges.contains { $0.contains("A") })
        #expect(charClass.ranges.contains { $0.contains("0") })
    }

    @Test
    func `character property with quantifier`() throws {
        let result = try parseToHIR(#"\p{L}+"#)
        let quant = try #require(result[case: \.quantification])
        #expect(quant.min == 1)
        #expect(quant.max == nil)
        #expect(quant.isEager == true)
        _ = try #require(quant.child[case: \.class])
    }

    @Test
    func `assigned property`() throws {
        let result = try parseToHIR(#"\p{Assigned}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // ASCII letters should be assigned
        #expect(charClass.ranges.contains { $0.contains("a") })
        #expect(charClass.ranges.contains { $0.contains("A") })
        // Common characters should be assigned
        #expect(charClass.ranges.contains { $0.contains("0") })
        #expect(charClass.ranges.contains { $0.contains(" ") })
    }

    @Test
    func `inverted assigned property`() throws {
        let result = try parseToHIR(#"\P{Assigned}"#)
        let charClass = try #require(result[case: \.class])
        // Assigned characters should NOT be in inverted class
        #expect(!charClass.ranges.contains { $0.contains("a") })
        #expect(!charClass.ranges.contains { $0.contains("0") })
    }

    @Test
    func `script extension Latin`() throws {
        let result = try parseToHIR(#"\p{scx=Latin}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // ASCII letters should be in Latin script extension
        #expect(charClass.ranges.contains { $0.contains("a") })
        #expect(charClass.ranges.contains { $0.contains("A") })
    }

    @Test
    func `script extension Greek`() throws {
        let result = try parseToHIR(#"\p{scx=Greek}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Greek alpha should be in the class
        #expect(charClass.ranges.contains { $0.contains("α") })
        // ASCII 'a' should NOT be in Greek script extension
        #expect(!charClass.ranges.contains { $0.contains("a") })
    }

    @Test
    func `script extension with full name`() throws {
        let result = try parseToHIR(#"\p{Script_Extensions=Cyrillic}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Cyrillic 'а' (U+0430) should be in the class
        #expect(charClass.ranges.contains { $0.contains("а") })
        // ASCII 'a' should NOT be in Cyrillic script extension
        #expect(!charClass.ranges.contains { $0.contains("a") })
    }

    @Test
    func `age property`() throws {
        let result = try parseToHIR(#"\p{age=10.0}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Basic ASCII characters have been assigned since Unicode 1.1
        #expect(charClass.ranges.contains { $0.contains("a") })
        // emoji were added in Unicode 10.0
        #expect(charClass.ranges.contains { $0.contains("🤟") })
        // character newer than Unicode 10.0
        #expect(!charClass.ranges.contains { $0.contains("🥳") })
    }

    @Test
    func `inverted age property`() throws {
        let result = try parseToHIR(#"\P{age=10.0}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Basic ASCII characters have been assigned since Unicode 1.1
        #expect(!charClass.ranges.contains { $0.contains("a") })
        // emoji were added in Unicode 10.0
        #expect(!charClass.ranges.contains { $0.contains("🤟") })
        // character newer than Unicode 10.0
        #expect(charClass.ranges.contains { $0.contains("🥳") })
        #expect(charClass.ranges.contains { $0.contains("🫩") })
    }

    @Test
    func `age property older version`() throws {
        let result = try parseToHIR(#"\p{age=1.1}"#)
        let charClass = try #require(result[case: \.class])
        #expect(charClass.ranges.count > 0)
        // Basic ASCII should be in Unicode 1.1
        #expect(charClass.ranges.contains { $0.contains("a") })
        // Arabic question mark '؟' (U+061F) should be in Unicode 1.1
        #expect(charClass.ranges.contains { $0.contains("؟") })
        // Korean added in Unicode 2.0
        #expect(!charClass.ranges.contains { $0.contains("가") })
    }

    // TODO: Implement the following features and test them
    /*
     1. Anchors not supported in Swift implementation:
     - assertions - ^, $, \A, \z, \b, \B
     - line_anchors - multiline anchors

     2. Flags not supported:
     - literal_case_insensitive - (?i)a
     - flags - (?i:a)a, (?im), etc.
     - ignore_whitespace - (?x) extended mode
     - Parts of empty with flags - (?i), (?x)

     6. Analysis/properties not implemented:
     - analysis_is_utf8
     - analysis_captures_len
     - analysis_static_captures_len
     - analysis_is_all_assertions
     - analysis_look_set_prefix_any
     - analysis_is_anchored
     - analysis_is_any_anchored
     - analysis_can_empty
     - analysis_is_literal
     - analysis_is_alternation_literal

     7. Other tests not copied:
     - cat_class_flattened - alternation of classes being flattened
     - smart_repetition - a{0} → empty, a{1} → literal
     - smart_concat - literal concatenation optimization
     - smart_alternation - alternation simplification
     - regression_* tests - regression tests for specific bugs
     */
}
