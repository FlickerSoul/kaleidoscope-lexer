//
//  HIRTranslator.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//
import _RegexParser
import Foundation

public extension HIRKind {
    init(_ ast: AST) throws(RegexConversionError) {
        let root = ast.root
        self = try HIRKind(root)
    }

    init(_ astNode: AST.Node) throws(RegexConversionError) {
        switch astNode {
        case let .alternation(alternation):
            self = try .init(alternation)
        case let .concatenation(concatenation):
            self = try .init(concatenation)
        case let .group(group):
            self = try .init(group)
        case let .conditional(conditional):
            throw .unsupportedConstruct("Conditional is not supported`").toError(
                with: conditional.location)
        case let .quantification(quantification):
            self = try .init(quantification)
        case let .quote(quote):
            self = try .init(quote)
        case let .trivia(trivia):
            self = try .init(trivia)
        case let .interpolation(interpolation):
            throw .unsupportedConstruct(
                "Interpolation is not supported",
            ).toError(with: interpolation.location)
        case let .atom(atom):
            self = try .init(atom)
        case let .customCharacterClass(customCharacterClass):
            self = try .init(customCharacterClass)
        case let .absentFunction(absentFunction):
            throw .unsupportedConstruct(
                "Absent function is not supported",
            ).toError(with: absentFunction.location)
        case .empty:
            self = .empty
        }
    }

    init(_ alternation: AST.Alternation) throws(RegexConversionError) {
        self = try .alternation(alternation.children.map(HIRKind.init))
    }

    init(_ concatenation: AST.Concatenation) throws(RegexConversionError) {
        self = try .concat(concatenation.children.map(HIRKind.init))
    }

    init(_ group: AST.Group) throws(RegexConversionError) {
        self = try .group(.init(child: .init(group.child)))
    }

    init(_ quantification: AST.Quantification) throws(RegexConversionError) {
        let isEager =
            switch quantification.kind.value {
            case .eager:
                true
            case .reluctant:
                false
            case .possessive:
                throw .unsupportedConstruct("Possessive quantifiers are not supported").toError(
                    with: quantification.kind.location)
            }

        let min: Int
        let max: Int?

        switch quantification.amount.value {
        case .zeroOrMore:
            min = 0
            max = nil
        case .oneOrMore:
            min = 1
            max = nil
        case .zeroOrOne:
            min = 0
            max = 1
        case let .exactly(number):
            guard let exactNumber = number.value else {
                throw .invalid("Exact quantifier parsing failed").toError(
                    with: quantification.amount.location)
            }
            min = exactNumber
            max = exactNumber
        case let .nOrMore(number):
            guard let nOrMoreNumber = number.value else {
                throw .invalid("N or more quantifier parsing failed").toError(
                    with: quantification.amount.location)
            }
            min = nOrMoreNumber
            max = nil
        case let .upToN(number):
            guard let upToNNumber = number.value else {
                throw .invalid("Up to N quantifier parsing failed").toError(
                    with: quantification.amount.location)
            }
            min = 0
            max = upToNNumber
        case let .range(lhs, rhs):
            guard let rangeMin = lhs.value else {
                throw .invalid("Range min quantifier parsing failed").toError(
                    with: quantification.amount.location)
            }
            guard let rangeMax = rhs.value else {
                throw .invalid("Range max quantifier parsing failed").toError(
                    with: quantification.amount.location)
            }
            min = rangeMin
            max = rangeMax
        }

        guard min >= 0, max == nil || max! >= min else {
            throw .invalid(
                "Quantifier min/max values are invalid: \(min), \(max.debugDescription)`",
            ).toError(with: quantification.amount.location)
        }

        self = try .quantification(
            .init(
                min: UInt32(min),
                max: max.map(UInt32.init),
                isEager: isEager,
                child: .init(quantification.child),
            ),
        )
    }

    init(_ quote: AST.Quote) throws(RegexConversionError) {
        self = .literal(quote.literal.map(\.self))
    }

    init(_ atom: AST.Atom) throws(RegexConversionError) {
        switch atom.kind {
        case let .char(char):
            self = .literal([char])
        case let .scalar(scalar):
            self = .literal([.init(scalar.value)])
        case .scalarSequence:
            throw .unavailable("Scalar sequence not supported in atom").toError(with: atom.location)
        case let .property(property):
            // FIXME: needs to support properties
            throw .unavailable("Property not supported: \(property)").toError(with: atom.location)
        case let .escaped(escaped):
            self = .literal([escaped.character])
        case let .keyboardControl(keyboardControl):
            self = .literal([keyboardControl])
        case let .keyboardMeta(keyboardMeta):
            self = .literal([keyboardMeta])
        case let .keyboardMetaControl(keyboardMetaControl):
            self = .literal([keyboardMetaControl])
        case let .namedCharacter(namedCharacter):
            let wrappedName = "\\N{\(namedCharacter)}"
            let characterNSString = NSMutableString(string: wrappedName)
            CFStringTransform(characterNSString, nil, kCFStringTransformToUnicodeName, true)
            let characterString = characterNSString as String

            guard characterString != wrappedName else {
                throw .invalid("Failed to parse named character: \(namedCharacter)").toError(
                    with: atom.location)
            }

            guard let char = characterString.first else {
                throw .invalid(
                    "Failed to extract character from named character: \(namedCharacter)",
                ).toError(with: atom.location)
            }

            self = .literal([char])
        case .dot:
            // FIXME: different kinds of dot based on configurations
            self = .class(.dot())
        case .caretAnchor:
            throw .unavailable("Caret anchor ^ not supported").toError(with: atom.location)
        case .dollarAnchor:
            throw .unavailable("Dollar anchor $ not supported").toError(with: atom.location)
        case let .backreference(reference):
            throw .unsupportedConstruct("Back reference is not supported").toError(
                with: reference.innerLoc)
        case let .subpattern(subpattern):
            throw .unavailable("Subpattern not supported").toError(with: subpattern.innerLoc)
        case .callout:
            throw .unavailable("Calllout is not supported").toError(with: atom.location)
        case .backtrackingDirective:
            throw .unsupportedConstruct("Backtracking directive is not supported").toError(
                with: atom.location)
        case .changeMatchingOptions:
            // FIXME: support change matching options/flags
            throw .unavailable("Change matching options is not supported").toError(
                with: atom.location)
        case .invalid:
            throw .invalid("Encountered invalid atom").toError(with: atom.location)
        }
    }

    init(_ customCharacterClass: AST.CustomCharacterClass) throws(RegexConversionError) {
        self = try .class(.init(customCharacterClass.members, inverted: customCharacterClass.isInverted))
    }

    init(_: AST.Trivia) throws(RegexConversionError) {
        self = .empty
    }
}

public extension CharacterClass {
    init(
        _ customCharacterClassMembers: [AST.CustomCharacterClass.Member],
        inverted: Bool,
    )
        throws(RegexConversionError) {
        let members = try customCharacterClassMembers.map(CharacterClass.init)
        let firstMember = members.first

        if let firstMember {
            self = members.dropFirst().reduce(into: firstMember) { partialResult, next in
                partialResult.union(other: next)
            }
        } else {
            self = CharacterClass(classes: .init(ranges: []))
        }

        if inverted {
            invert()
        }
    }

    init(_ customCharacterClassMember: AST.CustomCharacterClass.Member)
        throws(RegexConversionError) {
        switch customCharacterClassMember {
        case let .custom(customCharacterClass):
            self = try .init(
                customCharacterClass.members,
                inverted: customCharacterClass.isInverted,
            )
        case let .range(range):
            let lhsCharacter = range.lhs.literalCharacterValue
            let rhsCharacter = range.rhs.literalCharacterValue
            guard let lhsCharacter else {
                throw .invalid("Character class range lhs is not a single character").toError(
                    with: range.lhs.location)
            }
            guard let rhsCharacter else {
                throw .invalid("Character class range rhs is not a single character").toError(
                    with: range.rhs.location)
            }
            guard lhsCharacter <= rhsCharacter else {
                throw .invalid(
                    "Character class range lhs is greater than rhs: \(lhsCharacter) > \(rhsCharacter)",
                ).toError(with: range.lhs.location)
            }

            self = .init(
                classes: .init(
                    ranges: [
                        lhsCharacter ... rhsCharacter,
                    ],
                ),
            )
        case let .atom(atom):
            let character = atom.literalCharacterValue
            guard let character else {
                throw .invalid("Character class atom is not a single character").toError(
                    with: atom.location)
            }
            self = .init(
                classes: .init(
                    ranges: [character ... character],
                ),
            )
        case let .quote(quote):
            self = .init(
                classes: .init(
                    ranges: quote.literal.map { value in
                        value ... value
                    },
                ),
            )
        case .trivia:
            self = .init(classes: [])
        case let .setOperation(lhs, op, rhs):
            var lhsClasses = try CharacterClass(lhs, inverted: false)
            let rhsClasses = try CharacterClass(rhs, inverted: false)

            switch op.value {
            case .subtraction:
                lhsClasses.subtraction(rhsClasses)
            case .intersection:
                lhsClasses.intersection(rhsClasses)
            case .symmetricDifference:
                lhsClasses.symmetricDifference(rhsClasses)
            }

            self = lhsClasses
        }
    }
}
