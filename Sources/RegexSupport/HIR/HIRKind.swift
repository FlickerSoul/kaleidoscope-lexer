//
//  HIRKind.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//

/// HIR stands for high-level intermediate representation, specifically for regexes.
///
/// This HIR only contains constructs that can be completed using finite automata.
/// Therefore, constructs and features that require backtracking or CFG will not be represented here.
public indirect enum HIRKind: Hashable, Sendable {
    public typealias Scalar = Character
    public typealias Scalars = [Scalar]

    case empty
    case concat([HIRKind])
    case alternation([HIRKind])
    case quantification(Quantification)
    case literal(Scalars)
    case `class`(CharacterClass)
    case group(Group)

    static func literal(_ scalar: Scalar) -> HIRKind {
        .literal([scalar])
    }
}

// MARK: Quantification

/// Quantification represents repetition of a sub-expression.
public struct Quantification: Hashable, Sendable {
    /// The minimum number of repititions
    ///
    /// Special constructs like `?`, `+` and `*` all get translated into
    /// the ranges `{0,1}`, `{1,}` and `{0,}`, respectively.
    public var min: UInt32
    /// The maximum number of the repetition.
    ///
    /// When `max` is `nil`, this quantification is unbounded. When `max` and `min` are the same, the regex has to match
    /// `child` exactly `min` times. It's guaranteed that `max` is either `nil` or greater than `min`.
    public var max: UInt32?

    /// Whether this quantification is eager (greedy) or not.
    ///
    /// Use `?` for reluctant (lazy) quantifiers and `+`
    ///
    /// - Note: possessive repetition kind is not supported at this moment
    public var isEager: Bool
    /// The child HIR that is being quantified.
    public var child: HIRKind
}

// MARK: CharacterClass

public typealias CharacterClass = RangeSet<HIRKind.Scalar>

extension CharacterClass {
    func isAllAscii() -> Bool {
        ranges.last.flatMap { range in
            range.upperBound <= "\u{7F}"
        } ?? true
    }
}

extension CharacterClass {
    // FIXME: more cases of unicode representation of `.`
    static func dot() -> CharacterClass {
        [Character.min ... Character.max]
    }

    static var trueAny: CharacterClass {
        [Character.min ... Character.max]
    }

    static var decimalDigits: CharacterClass {
        ["0" ... "9"]
    }

    static var newLine: CharacterClass {
        CharacterClass(ranges: ["\n" ... "\n"])
    }

    static var horizontalWhiteSpaces: CharacterClass {
        .init(ranges: [
            "\t" ... "\t",
            " " ... " ",
            "\u{00A0}" ... "\u{00A0}", // NO-BREAK SPACE
            "\u{1680}" ... "\u{1680}", // OGHAM SPACE MARK
            "\u{2000}" ... "\u{200A}", // EN QUAD through HAIR SPACE
            "\u{202F}" ... "\u{202F}", // NARROW NO-BREAK SPACE
            "\u{205F}" ... "\u{205F}", // MEDIUM MATHEMATICAL SPACE
            "\u{3000}" ... "\u{3000}", // IDEOGRAPHIC SPACE
        ])
    }

    static var verticalWhiteSpaces: CharacterClass {
        .init(ranges: [
            "\n" ... "\n",
            "\u{000B}" ... "\u{000B}", // VERTICAL TAB
            "\u{000C}" ... "\u{000C}", // FORM FEED
            "\r" ... "\r",
            "\u{0085}" ... "\u{0085}", // NEXT LINE
            "\u{2028}" ... "\u{2028}", // LINE SEPARATOR
            "\u{2029}" ... "\u{2029}", // PARAGRAPH SEPARATOR
        ])
    }

    static var wordCharacters: CharacterClass {
        .init(ranges: [
            "0" ... "9",
            "A" ... "Z",
            "_" ... "_",
            "a" ... "z",
        ])
    }

    static var whiteSpaces: CharacterClass {
        .init(ranges: [
            "\t" ... "\t",
            "\n" ... "\n",
            "\u{000B}" ... "\u{000B}",
            "\u{000C}" ... "\u{000C}",
            "\r" ... "\r",
            " " ... " ",
            "\u{0085}" ... "\u{0085}",
            "\u{00A0}" ... "\u{00A0}", // NO-BREAK SPACE
            "\u{1680}" ... "\u{1680}", // OGHAM SPACE MARK
            "\u{202F}" ... "\u{202F}", // NARROW NO-BREAK SPACE
            "\u{205F}" ... "\u{205F}", // MEDIUM MATHEMATICAL SPACE
            "\u{3000}" ... "\u{3000}", // IDEOGRAPHIC SPACE (full-width space)
            "\u{2000}" ... "\u{2000}", // EN QUAD
            "\u{2001}" ... "\u{2001}", // EM QUAD
            "\u{2002}" ... "\u{2002}", // EN SPACE
            "\u{2003}" ... "\u{2003}", // EM SPACE
            "\u{2004}" ... "\u{2004}", // THREE-PER-EM SPACE
            "\u{2005}" ... "\u{2005}", // FOUR-PER-EM SPACE
            "\u{2006}" ... "\u{2006}", // SIX-PER-EM SPACE
            "\u{2007}" ... "\u{2007}", // FIGURE SPACE
            "\u{2008}" ... "\u{2008}", // PUNCTUATION SPACE
            "\u{2009}" ... "\u{2009}", // THIN SPACE
            "\u{200A}" ... "\u{200A}", // HAIR SPACE
            "\u{2028}" ... "\u{2028}", // LINE SEPARATOR
            "\u{2029}" ... "\u{2029}", // PARAGRAPH SEPARATOR
        ])
    }
}

// MARK: Group

/// Group represents a (non-)capturing group.
///
/// Since capturing groups are not relevant in HIR currently, we only have one kind of Group here.
public struct Group: Hashable, Sendable {
    let child: HIRKind
}

public extension HIRKind {
    func complexity() -> Int {
        switch self {
        case .empty:
            0
        case let .concat(concat):
            concat.map { $0.complexity() }.reduce(0, +)
        case let .alternation(alternates):
            alternates.map { $0.complexity() }.min() ?? 0
        case let .quantification(repetition):
            Int(repetition.min) * repetition.child.complexity()
        case let .literal(scalars):
            scalars.count * 2
        case .class:
            2
        case let .group(group):
            group.child.complexity()
        }
    }
}
