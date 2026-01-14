//
//  RegexParser.swift
//
//
//  Created by Larry Zeng on 11/27/23.
//
import _RegexParser
import Foundation

// MARK: - HIR and Errors

/// High-level Intermediate Representation
///
/// This is an abstraction to be fed into automata building,
/// and to determine the weight the expression.
/// The repetitions are unrolled to improve performance
///
/// - SeeAlso
/// [Regex AST API](https://swiftinit.org/docs/swift/_regexparser/ast)
/// - SeeAlso
/// [AST Node API](https://swiftinit.org/docs/swift/_regexparser/ast/node)
public indirect enum HIR: Hashable, Sendable {
    public typealias ScalarByte = UInt32
    public typealias ScalarBytes = [ScalarByte]

    public typealias ScalarByteRange = ClosedRange<ScalarByte>
    public typealias ScalarByteRanges = [ScalarByteRange]

    static let SCALAR_RANGE = ScalarByte.min ... ScalarByte.max

    case empty
    case concat([HIR])
    case alternation([HIR])
    case loop(HIR)
    case maybe(HIR)
    case literal(ScalarBytes)
    case `class`([ScalarByteRange])
}

extension Unicode.Scalar {
    var scalarByte: HIR.ScalarByte {
        value
    }

    var scalarBytes: HIR.ScalarBytes {
        [value]
    }
}

package extension Character {
    var scalarByte: HIR.ScalarByte {
        unicodeScalars.first!.scalarByte
    }

    var scalarBytes: HIR.ScalarBytes {
        [scalarByte]
    }
}

extension HIR.ScalarByteRange: @retroactive Comparable {
    public static func < (lhs: ClosedRange<Bound>, rhs: ClosedRange<Bound>) -> Bool {
        lhs.lowerBound < rhs.lowerBound || (lhs.lowerBound == rhs.lowerBound && lhs.upperBound < rhs.upperBound)
    }

    public func toCode() -> String {
        if lowerBound == upperBound {
            "\(lowerBound)"
        } else {
            "\(lowerBound) ... \(upperBound)"
        }
    }
}

public extension HIR.ScalarBytes {
    func toCode() -> String {
        description
    }
}

package extension HIR.ScalarByte {
    var scalarByteRange: HIR.ScalarByteRange {
        self ... self
    }
}

public enum HIRParsingError: Error, Equatable {
    case invalidRegexString(String)
    case invalidRepetitionRange
    case greedyMatchingMore
    case notSupportedRepetitionKind
    case notSupportedQualification
    case notSupportedAtomKind
    case notSupportedRegexNode
    case notSupportedCharacterClass
    case incorrectCharRange
    case incorrectChar
    case notSupportedCharacterRangeKind
    case invalidEscapeCharacter
    case quoteInCharacterClass
    case widerUnicodeThanSurpported
}

// MARK: - Regex Repetition Kinds

/// A representation of regex repetition.
enum RepetitionRange {
    case exactly(right: Int)
    case nOrMore(left: Int)
    case upToN(right: Int)
    case range(left: Int, right: Int)

    init(_ amount: AST.Quantification.Amount) throws(HIRParsingError) {
        switch amount {
        case let .exactly(right):
            guard let right_num = right.value else {
                throw HIRParsingError.invalidRepetitionRange
            }

            self = .exactly(right: right_num)
        case let .nOrMore(left):
            guard let left_num = left.value else {
                throw HIRParsingError.invalidRepetitionRange
            }
            self = .nOrMore(left: left_num)
        case .oneOrMore:
            self = .nOrMore(left: 1)
        case .zeroOrMore:
            self = .nOrMore(left: 0)
        case let .upToN(right):
            guard let right_num = right.value else {
                throw HIRParsingError.invalidRepetitionRange
            }
            self = .upToN(right: right_num)
        case let .range(left, right):
            guard let left_num = left.value, let right_num = right.value else {
                throw HIRParsingError.invalidRepetitionRange
            }
            guard left_num <= right_num else {
                throw HIRParsingError.invalidRepetitionRange
            }

            self = .range(left: left_num, right: right_num)
        case .zeroOrOne:
            self = .range(left: 0, right: 1)
        case _:
            throw HIRParsingError.invalidRepetitionRange
        }
    }
}

// MARK: - Flat HIR Array

extension [HIR] {
    func wrapOrExtract(wrapper: ([HIR]) -> HIR) -> HIR {
        if count == 1 {
            self[0]
        } else {
            wrapper(self)
        }
    }
}

// MARK: - Init

public extension HIR {
    init(regex string: String, option: SyntaxOptions = .traditional) throws(HIRParsingError) {
        let ast: AST
        do {
            ast = try parse(string, option)
        } catch {
            throw .invalidRegexString(string)
        }
        self = try HIR(ast: ast)
    }

    init(token string: String) throws {
        self = try HIR(regex: NSRegularExpression.escapedPattern(for: string))
    }

    init(ast: AST) throws(HIRParsingError) {
        self = try HIR(node: ast.root)
    }

    init(node: AST.Node) throws(HIRParsingError) {
        switch node {
        case let .alternation(alter):
            let children = try alter.children.map(HIR.init(node:)).compactMap(\.self)
            self = children.wrapOrExtract(wrapper: HIR.alternation)
        case let .concatenation(concat):
            let children = try concat.children.map(HIR.init(node:)).compactMap(\.self)
            self = children.wrapOrExtract(wrapper: HIR.concat)
        case let .group(group):
            self = try HIR(node: group.child)
        case let .quantification(qualification):
            switch qualification.amount.value {
            case .zeroOrMore where qualification.kind.value == .eager,
                 .oneOrMore where qualification.kind.value == .eager:
                throw HIRParsingError.greedyMatchingMore
            case _:
                let child = try HIR(node: qualification.child)

                switch qualification.amount.value {
                case .zeroOrMore, .oneOrMore:
                    switch qualification.kind.value {
                    case .reluctant, .possessive:
                        let range = try RepetitionRange(qualification.amount.value)
                        self = HIR.processRange(child: child, kind: range)
                    case _:
                        throw HIRParsingError.notSupportedRepetitionKind
                    }
                case .zeroOrOne, .exactly, .nOrMore, .upToN, .range:
                    let range = try RepetitionRange(qualification.amount.value)
                    self = HIR.processRange(child: child, kind: range)
                case _:
                    throw HIRParsingError.notSupportedQualification
                }
            }
        case let .quote(quote):
            self = HIR(quote)
        case let .atom(atom):
            self = try HIR(atom)
        case let .customCharacterClass(charClass):
            self = try .class(HIR.processCharacterClass(charClass))
        case .empty:
            self = .empty
        case _:
            throw HIRParsingError.notSupportedRegexNode
        }
    }

    internal init(_ quote: AST.Quote) {
        self = quote.literal.map { .literal($0.scalarBytes) }.wrapOrExtract(wrapper: HIR.concat)
    }

    internal init(_ atom: AST.Atom) throws(HIRParsingError) {
        switch atom.kind {
        case let .char(char), let .keyboardMeta(char), let .keyboardControl(char), let .keyboardMetaControl(char):
            self = .literal(char.scalarBytes)
        case let .scalar(scalar):
            self = .literal(scalar.value.scalarBytes)
        case let .scalarSequence(scalarSequence):
            self = scalarSequence.scalarValues.map { .literal($0.scalarBytes) }.wrapOrExtract(wrapper: HIR.concat)
        case let .escaped(escaped):
            guard let scalar = escaped.scalarValue else {
                throw HIRParsingError.invalidEscapeCharacter
            }
            self = .literal(scalar.scalarBytes)
        case .dot:
            // wildcard
            self = .class([HIR.SCALAR_RANGE])
        case .caretAnchor, .dollarAnchor, _:
            // start of the line
            // end of the line
            // and other things
            throw HIRParsingError.notSupportedAtomKind
        }
    }

    internal static func parseRange(_ range: AST.CustomCharacterClass
        .Range) throws(HIRParsingError) -> ScalarByteRanges {
        let lhs = range.lhs.kind
        let rhs = range.rhs.kind
        if case let .char(leftChar) = lhs, case let .char(rightChar) = rhs {
            let start = leftChar.scalarByte
            let end = rightChar.scalarByte

            return [start ... end]
        } else if case let .scalar(leftScalar) = lhs, case let .scalar(rightScalar) = rhs {
            let start = leftScalar.value.scalarByte
            let end = rightScalar.value.scalarByte
            return [start ... end]
        } else {
            throw HIRParsingError.notSupportedCharacterRangeKind
        }
    }

    internal static func processCharacterClass(_ charClass: AST
        .CustomCharacterClass) throws(HIRParsingError) -> ScalarByteRanges {
        let ranges: [ScalarByteRanges] = try charClass.members.map { member throws(HIRParsingError) in
            switch member {
            case let .custom(childMember):
                return try self.processCharacterClass(childMember).compactMap(\.self)
            case let .range(range):
                return try HIR.parseRange(range)
            case let .atom(atom):
                switch try HIR(atom) {
                case let .literal(scalar):
                    assert(scalar.count == 1)

                    return [scalar[0] ... scalar[0]]
                case _:
                    throw HIRParsingError.notSupportedAtomKind
                }
            case .quote:
                throw HIRParsingError.quoteInCharacterClass
            case _:
                throw HIRParsingError.notSupportedCharacterClass
            }
        }

        // sort out and make distinct ranges
        var flattened: ScalarByteRanges = []

        for currRange in ranges.flatMap(\.self).sorted() {
            if flattened.count == 0 {
                flattened.append(currRange)
            } else {
                let prevResult = flattened[flattened.count - 1]
                if currRange.lowerBound <= prevResult.upperBound {
                    if currRange.upperBound <= prevResult.upperBound {
                        // perfectly contained in prev range,
                        continue
                    } else {
                        // has intersection
                        // ----
                        //  -----
                        flattened[flattened.count - 1] = prevResult.lowerBound ... currRange.upperBound
                    }
                } else {
                    // does not have intersection
                    // ---
                    //     ----
                    flattened.append(currRange)
                }
            }
        }

        // do invert
        if charClass.isInverted {
            var results: ScalarByteRanges = []
            var remaining: ScalarByteRange? = Self.SCALAR_RANGE

            for scalar in flattened {
                guard let remainingUnwrapped = remaining else {
                    throw HIRParsingError.widerUnicodeThanSurpported
                }

                if remainingUnwrapped.lowerBound < scalar.lowerBound {
                    let left = remainingUnwrapped.lowerBound ... (scalar.lowerBound - 1)
                    results.append(left)
                } else if scalar.upperBound > remainingUnwrapped.upperBound {
                    throw HIRParsingError.widerUnicodeThanSurpported
                }

                if scalar.upperBound < remainingUnwrapped.upperBound {
                    remaining = scalar.upperBound + 1 ... remainingUnwrapped.upperBound
                } else {
                    remaining = nil
                }
            }

            if let remaining {
                results.append(remaining)
            }

            flattened = results
        }

        return flattened
    }

    internal static func processRange(child: HIR, kind: RepetitionRange) -> HIR {
        var children: [HIR]
        switch kind {
        case let .exactly(right):
            children = (0 ..< right).map { _ in child }
        case let .nOrMore(left):
            children = (0 ..< left).map { _ in child }
            children.append(.loop(child))
        case let .upToN(right):
            children = (0 ..< right).map { _ in .maybe(child) }
        case let .range(left, right):
            children = (0 ..< left).map { _ in child }
            children.append(contentsOf: (left ..< right).map { _ in .maybe(child) })
        }

        return children.wrapOrExtract(wrapper: HIR.concat)
    }
}

// MARK: - HIR priority

public extension HIR {
    /// Calculate this hir's priority. It has the following property.
    /// The more specific, the higher the score is.
    /// The longer the regex is, the higher the score is.
    func priority() -> UInt {
        switch self {
        case .empty, .loop, .maybe:
            return 0
        case .class:
            return 1
        case .literal:
            return 2
        case let .concat(children):
            return children.map { $0.priority() }.reduce(0, +)
        case let .alternation(children):
            if children.count > 0 {
                let priorities = children.map { $0.priority() }
                return priorities.reduce(priorities[0], min)
            } else {
                return 0
            }
        }
    }
}
