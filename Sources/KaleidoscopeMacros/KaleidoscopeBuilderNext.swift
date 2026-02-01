import KaleidoscopeMacroSupportNext
import SwiftSyntax
import SwiftSyntaxMacros

public struct KaleidoscopeBuilderNext: ExtensionMacro {
    public static func expansion(
        of _: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo _: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext,
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw KaleidoscopeError.notAnEnum
        }

        let macroVisitor = KaleidoscopeMacroVisitor(context: context)
        try macroVisitor.walk(enumDecl: enumDecl)

        let graph = try Graph.build(from: macroVisitor.leaves)
        let type = type.trimmed

        if !graph.errors.isEmpty {
            for error in graph.errors {
                switch error {
                case .multipleLeavesWithSamePriority(let leaves, priority: _):
                    context.diagnose(.init(
                        node: enumDecl,
                        message: error,
                        highlights: leaves
                            .sorted()
                            .map { leafID in
                                macroVisitor.leaves[leafID.id].pattern.source
                            },
                    ))
                }
            }
            throw KaleidoscopeError.graphCompositionError
        }

        #if StateMachineCodegen
            let useStateMachineCodeGen = true
        #else
            let useStateMachineCodeGen = false
        #endif

        let config = KaleidoscopeMacroSupportNext.Generator.Config(
            useStateMachineCodeGen: useStateMachineCodeGen,
        )
        var generator = KaleidoscopeMacroSupportNext.Generator(
            enumType: type,
            config: config,
            graph: graph,
            context: context,
        )

        return try [
            ExtensionDeclSyntax("extension \(type): \(raw: Constants.Types.lexerProtocol)") {
                "typealias Source = String" // TODO: allow this to be customizable
                "typealias UserError = Never" // TODO: allow user to customize Error type

                try FunctionDeclSyntax(
                    "public static func lex(_ lexer: inout \(raw: Constants.Types.lexerMachine)<\(type)>) -> \(type).\(Constants.Types.lexerOutput)?",
                ) {
                    try generator.generateLex()
                }
            },
        ]
    }
}
