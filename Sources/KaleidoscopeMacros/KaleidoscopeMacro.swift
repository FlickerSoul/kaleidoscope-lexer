import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct KaleidoscopePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumCaseRegistry.self,
        KaleidoscopeBuilderNext.self,
    ]
}
