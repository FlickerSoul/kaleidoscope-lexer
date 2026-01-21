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
public indirect enum HIRKind: Equatable, Sendable {
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
public struct Quantification: Equatable, Sendable {
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
        [Character.minValue ... Character.maxValue]
    }
}

// MARK: Group

/// Group represents a (non-)capturing group.
///
/// Since capturing groups are not relevant in HIR currently, we only have one kind of Group here.
public struct Group: Equatable, Sendable {
    let child: HIRKind
}
