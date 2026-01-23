import KaleidoscopeMacroSupportNext
import MacroToolkit
import RegexSupport
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum MacroInfoError: Error, DiagnosticMessage {
    case notAnEnum
    case multipleMacroDeclaration(macro: String)
    case invalidMacroArgument(reason: String)
    case regexParsingError(reason: String)
    case onlyOneEnumCaseAllowed
    case fatalError(reason: String)
    case noSkipInEnumCase

    var message: String {
        switch self {
        case .notAnEnum: "@kaleidoscope can only be applied to enums."
        case let .multipleMacroDeclaration(macro):
            "Multiple @\(macro) declarations found on the same enum."
        case let .invalidMacroArgument(reason):
            "Invalid arguments provided to the macro. This is likely a bug in the macro implementation. Reason: \(reason)"
        case let .regexParsingError(reason: reason):
            "Cannot parse regex. \(reason)"
        case .onlyOneEnumCaseAllowed:
            "Only one enum case is allowed per enum case declaration."
        case let .fatalError(reason: reason):
            "Fatal error during macro expansion: \(reason)"
        case .noSkipInEnumCase:
            "`@skip` macro cannot be applied to enum cases."
        }
    }

    var diagnosticID: SwiftDiagnostics.MessageID {
        .init(domain: "observer.universe.kaleidoscope-lexer", id: "MacroInfoError")
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        .error
    }
}

private struct MacroArguments {
    let patternKind: PatternKind
    let priority: Int?
    let callbackKind: CallbackKind?
}

class KaleidoscopeMacroVisitor: SyntaxVisitor {
    let context: any MacroExpansionContext
    private(set) var errors: [Diagnostic] = []

    private(set) var leaves: [Leaf] = []
    private var enumDecl: EnumDeclSyntax?

    init(context: any MacroExpansionContext) {
        self.context = context
        super.init(viewMode: .sourceAccurate)
    }

    func walk(enumDecl: EnumDeclSyntax) throws(KaleidoscopeError) {
        walk(enumDecl)
        try validate()
    }

    func validate() throws(KaleidoscopeError) {
        for error in errors {
            context.diagnose(error)
        }

        if !errors.isEmpty {
            throw .macroInfoError
        }
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        guard enumDecl == nil else {
            print("Multiple enum declarations found.")
            return .skipChildren
        }
        enumDecl = node

        checkMacroCount(node.attributes, of: [Constants.Macro.kaleidoscope])

        return .visitChildren
    }

    override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let (macroAttribute, macro) = checkMacroCount(
            node.attributes,
            of: [Constants.Macro.regex, Constants.Macro.token],
        ) else {
            return .skipChildren
        }

        do {
            let leaf = try synthesizeLeaf(
                attribute: macroAttribute,
                on: node,
                macro: macro,
            ).get()
            leaves.append(leaf)
        } catch {
            errors.append(.init(node: node, message: error))
        }

        return .skipChildren
    }

    private func synthesizeLeaf(
        attribute: AttributeSyntax,
        on caseDecl: EnumCaseDeclSyntax,
        macro: PackageEntity,
    ) -> Result<Leaf, MacroInfoError> {
        if macro == Constants.Macro.skip {
            return .failure(.noSkipInEnumCase)
        }

        let arguments = Result { () throws(MacroInfoError) in
            try parseMacroArguments(from: attribute)
        }

        let pattern = arguments
            .flatMap { arguments in
                Result {
                    let hir = switch arguments.patternKind {
                    case let .regex(regex):
                        try HIRKind.from(regex: regex)
                    case let .token(token):
                        HIRKind.from(token: token)
                    }

                    return Pattern(source: arguments.patternKind, hir: hir)
                }
                .mapError { error in
                    MacroInfoError.regexParsingError(reason: error.localizedDescription)
                }
            }

        let enumCaseKind = Result { () throws(MacroInfoError) in
            return try getEnumCaseKind(caseDecl)
        }

        return arguments.together(with: pattern, enumCaseKind) { arguments, pattern, enumCaseKind in
            Leaf(
                pattern: pattern,
                priority: arguments.priority ?? 0, // FIXME: real priority
                kind: enumCaseKind,
                callback: arguments.callbackKind,
            )
        }
    }

    private func parseMacroArguments(from attribute: AttributeSyntax) throws(MacroInfoError) -> MacroArguments {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else {
            throw MacroInfoError.invalidMacroArgument(reason: "@regex/token/skip must have an argument list")
        }

        var argumentIterator = arguments.makeIterator()
        guard let regexArgument = argumentIterator.next() else {
            throw MacroInfoError.invalidMacroArgument(reason: "@regex/token/skip must have at least one argument")
        }

        let patternKind: PatternKind = if let regexLiteral = regexArgument.expression.as(RegexLiteralExprSyntax.self) {
            .regex(regexLiteral.regex.text)
        } else if let stringLiteral = Expr(regexArgument.expression).asStringLiteral?.value {
            .token(stringLiteral)
        } else {
            throw MacroInfoError.invalidMacroArgument(
                reason: "The argument to @regex/token/skip only accept regex literals or string literals",
            )
        }
        var priority: Int?
        var callbackKind: CallbackKind?

        while let argument = argumentIterator.next() {
            switch argument.label?.text {
            case Constants.MacroArgument.priority:
                if let intLiteral = Expr(argument.expression).asIntegerLiteral?.value {
                    priority = intLiteral
                } else {
                    throw MacroInfoError.invalidMacroArgument(
                        reason: "The priority argument must be an unsigned integer literal",
                    )
                }
            case Constants.MacroArgument.callback:
                if let closure = argument.expression.as(ClosureExprSyntax.self) {
                    callbackKind = .lambda(closure: closure)
                } else {
                    callbackKind = .named(callbackName: argument.expression)
                }
            default:
                throw MacroInfoError.invalidMacroArgument(
                    reason: "Unknown argument \(argument.label?.text ?? "<no label>")",
                )
            }
        }

        return .init(
            patternKind: patternKind,
            priority: priority,
            callbackKind: callbackKind,
        )
    }

    private func getEnumCaseKind(_ caseDecl: EnumCaseDeclSyntax) throws(MacroInfoError) -> LeafKind {
        let caseElements = caseDecl.elements
        guard let caseElement = caseElements.first else {
            throw .fatalError(reason: "At least one enum case expected")
        }

        guard caseElements.count == 1 else {
            throw .onlyOneEnumCaseAllowed
        }

        guard let caseParameters = caseElement.parameterClause?.parameters else {
            return .caseOnly(caseName: caseElement.name)
        }

        guard !caseParameters.isEmpty else {
            throw .fatalError(reason: "Empty enum case parameters. This should have been rejected by compiler.")
        }

        // TODO: handle skip?
        return .associatedValues(caseName: caseElement.name, parameters: caseParameters)
    }

    @discardableResult
    private func checkMacroCount(
        _ attributes: AttributeListSyntax,
        of macro: [PackageEntity],
    ) -> (attribute: AttributeSyntax, macro: PackageEntity)? {
        let allowedNames = Set([macro.map(\.name), macro.map(\.qualifiedName)].joined())
        let kaleidoscopeAttributes = attributes
            .compactMap { attribute in
                switch attribute {
                case let .attribute(attribute):
                    let attributeName = attribute.attributeName.description
                    if allowedNames.contains(attributeName) {
                        return (attribute, attributeName)
                    }
                case .ifConfigDecl: break
                }

                return nil
            }

        if kaleidoscopeAttributes.count > 1 {
            for (attribute, attributeName) in kaleidoscopeAttributes {
                errors.append(.init(
                    node: attribute,
                    message: MacroInfoError.multipleMacroDeclaration(macro: attributeName),
                ))
            }
        } else if let (attribute, attributeName) = kaleidoscopeAttributes.first {
            return macro
                .first { macro in
                    macro.name == attributeName || macro.qualifiedName == attributeName
                }
                .map { macro in
                    (attribute, macro)
                }
        }

        return nil
    }
}
