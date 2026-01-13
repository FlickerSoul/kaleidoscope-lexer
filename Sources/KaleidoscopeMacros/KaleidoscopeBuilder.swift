//
//  KaleidoscopeBuilder.swift
//
//
//  Created by Larry Zeng on 11/26/23.
//

import KaleidoscopeMacroSupport
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

let KALEIDOSCOPE_PACKAGE_NAME: String = "Kaleidoscope"

let KALEIDOSCOPE_MACRO_NAME: String = "kaleidoscope"
let KALEIDOSCOPE_MACRO_SKIP_ATTR: String = "skip"

let KALEIDOSCOPE_REGEX_NAME: String = "regex"
let KALEIDOSCOPE_TOKEN_NAME: String = "token"

let KALEIDOSCOPE_PRIORITY_OPTION: String = "priority"
let KALEIDOSCOPE_FILL_CALLBACK_OPTION: String = "fillCallback"
let KALEIDOSCOPE_CREATE_CALLBACK_OPTION: String = "createCallback"

/// This extension macro generates an extension to the decorated enum and make it conform to the lexer protocol
/// so that the decorated enum can be a tokenizer.
public struct KaleidoscopeBuilder: ExtensionMacro {
    public static func expansion(
        of _: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf _: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo _: [SwiftSyntax.TypeSyntax],
        in _: some SwiftSyntaxMacros.MacroExpansionContext,
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw KaleidoscopeError.notAnEnum
        }

        // get enum identity
        let enumIdent = enumDecl.name.text

        // generate graph
        var graph = Graph()

        // get the macro lists
        let kaleidoscopeMacroDelcList = enumDecl.attributes.filter { attr in
            let attrName: TypeSyntax? = attr.as(AttributeSyntax.self)?.attributeName
            let ident = attrName?.as(IdentifierTypeSyntax.self)?.name.text
            let member = attrName?.as(MemberTypeSyntax.self)
            let memberIdent = member?.name.text
            let memberType = member?.baseType.as(IdentifierTypeSyntax.self)?.name.text

            // check how many of the attributes are like
            // @kaleidoscope() or Kaleidoscope.kaleidoscope()
            return ident == KALEIDOSCOPE_MACRO_NAME ||
                (memberIdent == KALEIDOSCOPE_MACRO_NAME && memberType == KALEIDOSCOPE_PACKAGE_NAME)
        }

        // if there are more than 1,
        // throw error to indicate duplication
        if kaleidoscopeMacroDelcList.count > 1 {
            throw KaleidoscopeError.multipleMacroDeclaration
        }

        if let kaleidoscopeAttrs = kaleidoscopeMacroDelcList[0].as(AttributeSyntax.self)?.arguments?
            .as(LabeledExprListSyntax.self) {
            for kaleidoscopeAttr in kaleidoscopeAttrs {
                switch kaleidoscopeAttr.label?.text {
                case KALEIDOSCOPE_MACRO_SKIP_ATTR:
                    guard let skipString = kaleidoscopeAttr.expression.as(StringLiteralExprSyntax.self)?.segments
                        .description else {
                        throw KaleidoscopeError.expectingString
                    }
                    try graph.push(input: .init(
                        token: "SKIP_REGEX_TOKEN",
                        tokenType: .skip,
                        hir: HIR(regex: skipString),
                    ))
                case _:
                    break
                }
            }
        }

        // get the member case xxx blocks
        for member in enumDecl.memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }

            // summarize `case  A, B, C(K.String), D(String, Int)`
            // get (name, paramTypes) tuples
            // for example, (A, nil), (C, ["K.String"])
            let caseTypes: [(name: String, paramTypes: [String]?)] = caseDecl.elements.map { element in
                (name: element.name.text, paramTypes: element.parameterClause?.parameters.map(\.type.description))
            }

            var attrMatches: [AttrMatchInfo] = []

            // parse attributes
            for attr in caseDecl.attributes {
                guard let attr = attr.as(AttributeSyntax.self) else {
                    continue
                }

                let attrName: TypeSyntax? = attr.attributeName
                let ident = attrName?.as(IdentifierTypeSyntax.self)?.name.text
                let member = attrName?.as(MemberTypeSyntax.self)
                let memberIdent = member?.name.text
                let memberType = member?.baseType.as(IdentifierTypeSyntax.self)?.name.text

                switch (ident, memberIdent, memberType) {
                case (KALEIDOSCOPE_REGEX_NAME, _, _), (_, KALEIDOSCOPE_REGEX_NAME, KALEIDOSCOPE_PACKAGE_NAME):
                    try attrMatches.append(parse(regex: attr))
                case (KALEIDOSCOPE_TOKEN_NAME, _, _), (_, KALEIDOSCOPE_TOKEN_NAME, KALEIDOSCOPE_PACKAGE_NAME):
                    try attrMatches.append(parse(token: attr))
                case _:
                    break
                }
            }

            for token in caseTypes {
                for (hir, tokenType, priority) in attrMatches {
                    try graph.push(input: .init(token: token.name, tokenType: tokenType, hir: hir, priority: priority))
                }
            }
        }

        _ = try graph.makeRoot()
        let rootId = try graph.shake()

        var generator = Generator(graph: graph, enumIdent: enumIdent)

        let lexerConformance = try ExtensionDeclSyntax("extension \(raw: enumIdent): Kaleidoscope.LexerProtocol") {
            "typealias TokenType = Self"
            "typealias RawSource = String"

            try FunctionDeclSyntax("public static func lex(_ lexer: inout Kaleidoscope.LexerMachine<Self>) throws") {
                try generator.buildFunctions()

                "try \(raw: generator.generateFuncIdent(nodeId: rootId))(&lexer)"
            }

            try FunctionDeclSyntax("public static func lexer(source: RawSource) -> Kaleidoscope.LexerMachine<Self>") {
                "return Kaleidoscope.LexerMachine(raw: source)"
            }
        }

        let tokenResultConformance = try ExtensionDeclSyntax("extension \(raw: enumIdent): Kaleidoscope.Into") {
            "public typealias IntoType = Kaleidoscope.TokenResult<\(raw: enumIdent)>"
            try FunctionDeclSyntax("public func into() -> IntoType") {
                "return .result(self)"
            }
        }

        return [
            lexerConformance,
            tokenResultConformance,
        ]
    }
}

typealias AttrMatchInfo = (hir: HIR, type: TokenType, priority: UInt?)

extension SyntaxCollection {
    subscript(index: Int) -> Element {
        self[self.index(startIndex, offsetBy: index)]
    }
}

func parse(regex: AttributeSyntax) throws -> AttrMatchInfo {
    try parse(regex, isToken: false)
}

func parse(token: AttributeSyntax) throws -> AttrMatchInfo {
    try parse(token, isToken: true)
}

/// Parses an enum case's information.
func parse(_ attr: AttributeSyntax, isToken: Bool) throws -> AttrMatchInfo {
    guard let arguments = attr.arguments?.as(LabeledExprListSyntax.self) else {
        throw KaleidoscopeError.parsingError
    }

    // TODO: this might be wrong
    guard let regexOrToken = arguments[0].expression.as(StringLiteralExprSyntax.self)?.segments.description else {
        throw KaleidoscopeError.expectingString
    }

    let hir: HIR = if isToken {
        try HIR(token: regexOrToken)
    } else {
        try HIR(regex: regexOrToken)
    }

    var matchCallback: TokenType = .standalone
    var priority: UInt?

    if let foundExpr = findExpression(KALEIDOSCOPE_FILL_CALLBACK_OPTION, in: arguments)?.expression {
        if let lambda = foundExpr.as(ClosureExprSyntax.self) {
            // TODO: this might be wrong
            matchCallback = .fillCallback(.lambda(lambda.description))
        } else {
            // TODO: this might be wrong
            matchCallback = .fillCallback(.named(foundExpr.description))
        }
    }

    if let foundExpr = findExpression(KALEIDOSCOPE_CREATE_CALLBACK_OPTION, in: arguments)?.expression {
        if case .standalone = matchCallback {
            if let lambda = foundExpr.as(ClosureExprSyntax.self) {
                // TODO: this might be wrong
                matchCallback = .createCallback(.lambda(lambda.description))
            } else {
                // TODO: this might be wrong
                matchCallback = .createCallback(.named(foundExpr.description))
            }
        } else {
            throw KaleidoscopeError.onlyFillOrCreateCallbackIsAllowed
        }
    }

    if let foundExpr = findExpression(KALEIDOSCOPE_PRIORITY_OPTION, in: arguments)?.expression {
        guard let num = foundExpr.as(IntegerLiteralExprSyntax.self) else {
            throw KaleidoscopeError.expectingIntegerLiteral
        }
        priority = UInt(num.literal.text)
    }

    return (hir, matchCallback, priority)
}

func findExpression(_ name: String, in exprList: LabeledExprListSyntax) -> LabeledExprSyntax? {
    for labeledExpr in exprList where labeledExpr.label?.text == name {
        return labeledExpr
    }

    return nil
}
