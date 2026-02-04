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
                with: conditional.location,
            )
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
                    with: quantification.kind.location,
                )
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
                    with: quantification.amount.location,
                )
            }
            min = exactNumber
            max = exactNumber
        case let .nOrMore(number):
            guard let nOrMoreNumber = number.value else {
                throw .invalid("N or more quantifier parsing failed").toError(
                    with: quantification.amount.location,
                )
            }
            min = nOrMoreNumber
            max = nil
        case let .upToN(number):
            guard let upToNNumber = number.value else {
                throw .invalid("Up to N quantifier parsing failed").toError(
                    with: quantification.amount.location,
                )
            }
            min = 0
            max = upToNNumber
        case let .range(lhs, rhs):
            guard let rangeMin = lhs.value else {
                throw .invalid("Range min quantifier parsing failed").toError(
                    with: quantification.amount.location,
                )
            }
            guard let rangeMax = rhs.value else {
                throw .invalid("Range max quantifier parsing failed").toError(
                    with: quantification.amount.location,
                )
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

    init(_ atom: AST.Atom) throws(RegexConversionError) { // swiftlint:disable:this cyclomatic_complexity
        switch atom.kind {
        case let .char(char):
            self = .literal([char])
        case let .scalar(scalar):
            self = .literal([.init(scalar.value)])
        case .scalarSequence:
            throw .unavailable("Scalar sequence not supported in atom").toError(with: atom.location)
        case let .property(property):
            self = try .init(property, location: atom.location)
        case let .escaped(escaped):
            if let escapedHIR = escaped.escapedCharacterHIR {
                self = escapedHIR
            } else {
                throw .unavailable("Escaped character \\\(escaped.character) not supported")
                    .toError(with: atom.location)
            }
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
                    with: atom.location,
                )
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
                with: reference.innerLoc,
            )
        case let .subpattern(subpattern):
            throw .unavailable("Subpattern not supported").toError(with: subpattern.innerLoc)
        case .callout:
            throw .unavailable("Calllout is not supported").toError(with: atom.location)
        case .backtrackingDirective:
            throw .unsupportedConstruct("Backtracking directive is not supported").toError(
                with: atom.location,
            )
        case .changeMatchingOptions:
            // FIXME: support change matching options/flags
            throw .unavailable("Change matching options is not supported").toError(
                with: atom.location,
            )
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

    // swiftlint:disable:next cyclomatic_complexity
    init(
        _ property: AST.Atom.CharacterProperty,
        location: SourceLocation,
    ) throws(RegexConversionError) {
        var characterClass: CharacterClass

        switch property.kind {
        case .any:
            characterClass = .trueAny
        case .assigned:
            // Assigned is the inverse of Unassigned general category
            if let ranges = GeneralCategory.BY_NAME["Unassigned"] {
                characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
                characterClass.invert()
            } else {
                throw .unavailable("Assigned property table not found").toError(with: location)
            }
        case .ascii:
            characterClass = .posixAscii
        case let .generalCategory(category):
            let categoryName = category.rawValue
            // First try to find the category directly
            if let ranges = GeneralCategory.BY_NAME[categoryName] {
                characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
            } else {
                // Try to look up via PROPERTY_VALUES for aliases
                let normalizedName = categoryName.lowercased().replacingOccurrences(of: "_", with: "")
                if let canonicalName = PROPERTY_VALUES["General_Category"]?[normalizedName],
                   let ranges = GeneralCategory.BY_NAME[canonicalName] {
                    characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
                } else {
                    throw .unavailable("General category '\(categoryName)' not found").toError(
                        with: location,
                    )
                }
            }
        case let .binary(binaryProp, value):
            let propName = binaryProp.rawValue
            // Look up the canonical name first
            let normalizedName = propName.lowercased().replacingOccurrences(of: "_", with: "")
            let canonicalName = PROPERTY_NAMES
                .first { $0.0 == normalizedName }?.1 ?? propName
            if let ranges = PropertyBool.BY_NAME[canonicalName] {
                characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
                // If value is false, invert the class
                if !value {
                    characterClass.invert()
                }
            } else {
                throw .unavailable("Binary property '\(propName)' not found").toError(with: location)
            }
        case let .script(script):
            let scriptName = script.rawValue
            if let ranges = ScriptExtension.BY_NAME[scriptName] {
                characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
            } else {
                // Try to look up via PROPERTY_VALUES for aliases
                let normalizedName = scriptName.lowercased().replacingOccurrences(of: "_", with: "")
                if let canonicalName = PROPERTY_VALUES["Script"]?[normalizedName],
                   let ranges = ScriptExtension.BY_NAME[canonicalName] {
                    characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
                } else {
                    throw .unavailable("Script '\(scriptName)' not found").toError(with: location)
                }
            }
        case let .scriptExtension(script):
            let scriptName = script.rawValue
            if let ranges = ScriptExtension.BY_NAME[scriptName] {
                characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
            } else {
                // Try to look up via PROPERTY_VALUES for aliases
                let normalizedName = scriptName.lowercased().replacingOccurrences(of: "_", with: "")
                if let canonicalName = PROPERTY_VALUES["Script"]?[normalizedName],
                   let ranges = ScriptExtension.BY_NAME[canonicalName] {
                    characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
                } else {
                    throw .unavailable("Script extension '\(scriptName)' not found").toError(
                        with: location,
                    )
                }
            }
        case let .posix(posixProp):
            characterClass = CharacterClass.fromPOSIX(posixProp)
        case let .age(major, minor):
            let versionString = "V\(major)_\(minor)"
            if let ranges = Age.BY_NAME[versionString] {
                characterClass = CharacterClass(ranges: ranges.map { $0.0 ... $0.1 })
            } else {
                throw .unavailable("Age '\(major).\(minor)' not found").toError(with: location)
            }
        case .named:
            throw .unsupportedConstruct("Named character property is not supported").toError(
                with: location,
            )
        case .numericType:
            throw .unsupportedConstruct("Numeric type property is not supported").toError(
                with: location,
            )
        case .numericValue:
            throw .unsupportedConstruct("Numeric value property is not supported").toError(
                with: location,
            )
        case .mapping:
            throw .unsupportedConstruct("Mapping property is not supported").toError(with: location)
        case .ccc:
            throw .unsupportedConstruct("Canonical combining class property is not supported")
                .toError(with: location)
        case .block:
            throw .unsupportedConstruct("Block property is not supported").toError(with: location)
        case .pcreSpecial:
            throw .unsupportedConstruct("PCRE special category is not supported").toError(
                with: location,
            )
        case .javaSpecial:
            throw .unsupportedConstruct("Java special property is not supported").toError(
                with: location,
            )
        case .invalid:
            throw .invalid("Invalid character property").toError(with: location)
        }

        if property.isInverted {
            characterClass.invert()
        }

        self = .class(characterClass)
    }
}

// MARK: - POSIX Character Class Support

extension CharacterClass {
    static func fromPOSIX(_ posixProp: Unicode.POSIXProperty) -> CharacterClass {
        switch posixProp {
        case .alnum:
            .posixAlnum
        case .blank:
            .posixBlank
        case .graph:
            .posixGraph
        case .print:
            .posixPrint
        case .word:
            .posixWord
        case .xdigit:
            .posixXdigit
        }
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
                partialResult.union(next)
            }
        } else {
            self = CharacterClass(ranges: [])
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
                    with: range.lhs.location,
                )
            }
            guard let rhsCharacter else {
                throw .invalid("Character class range rhs is not a single character").toError(
                    with: range.rhs.location,
                )
            }
            guard lhsCharacter <= rhsCharacter else {
                throw .invalid(
                    "Character class range lhs is greater than rhs: \(lhsCharacter) > \(rhsCharacter)",
                ).toError(with: range.lhs.location)
            }

            self = .init(
                ranges: [
                    lhsCharacter ... rhsCharacter,
                ],
            )
        case let .atom(atom):
            let character = atom.literalCharacterValue
            guard let character else {
                throw .invalid("Character class atom is not a single character").toError(
                    with: atom.location,
                )
            }
            self = .init(
                ranges: [character ... character],
            )
        case let .quote(quote):
            self = .init(
                ranges: quote.literal.map { value in
                    value ... value
                },
            )
        case .trivia:
            self = .init(ranges: [])
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

public extension HIRKind {
    static func from(regex: String, options: SyntaxOptions = .traditional) throws -> HIRKind {
        let ast = try parse(regex, options)
        return try HIRKind(ast)
    }

    static func from(token: String) -> HIRKind {
        .literal(token.map(\.self))
    }
}

extension AST.Atom.EscapedBuiltin {
    var escapedCharacterHIR: HIRKind? {
        switch self {
        // Literal single characters
        case .alarm: .literal("\u{0007}")
        case .escape: .literal("\u{001B}")
        case .formfeed: .literal("\u{000C}")
        case .newline: .literal("\n")
        case .carriageReturn: .literal("\r")
        case .tab: .literal("\t")
        case .backspace: .literal("\u{0008}")
        // Character types
        case .decimalDigit: .class(.decimalDigits)
        case .notDecimalDigit: .class(.decimalDigits.inverting())
        case .horizontalWhitespace: .class(.horizontalWhiteSpaces)
        case .notHorizontalWhitespace: .class(.horizontalWhiteSpaces.inverting())
        case .verticalTab: .class(.verticalWhiteSpaces)
        case .notVerticalTab: .class(.verticalWhiteSpaces.inverting())
        case .whitespace: .class(.whiteSpaces)
        case .notWhitespace: .class(.whiteSpaces.inverting())
        case .wordCharacter: .class(.wordCharacters)
        case .notWordCharacter: .class(.wordCharacters.inverting())
        case .notNewline: .class(.newLine.inverting())
        case .newlineSequence: .alternation([
                .literal("\n"),
                .literal("\r\n".map(\.self)),
                .literal("\r"),
                .literal("\u{000B}"),
                .literal("\u{000C}"),
                .literal("\u{0085}"),
                .literal("\u{2028}"),
                .literal("\u{2029}"),
            ])
        case .trueAnychar: .class(.trueAny)
        // Not representable in finite automata
        case .singleDataUnit: nil
        case .graphemeCluster: nil
        // Assertions / anchors (not representable in HIR)
        case .wordBoundary: nil
        case .notWordBoundary: nil
        case .startOfSubject: nil
        case .endOfSubjectBeforeNewline: nil
        case .endOfSubject: nil
        case .firstMatchingPositionInSubject: nil
        case .resetStartOfMatch: nil
        case .textSegment: nil
        case .notTextSegment: nil
        }
    }
}
