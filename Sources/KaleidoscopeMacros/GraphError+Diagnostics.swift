import KaleidoscopeMacroSupportNext
import SwiftDiagnostics
import SwiftSyntax

extension GraphError: DiagnosticMessage {
    public var message: String {
        switch self {
        case let .multipleLeavesWithSamePriority(_, priority):
            "Multiple leaves have the same priority of \(priority). Priorities must be unique."
        }
    }

    public var diagnosticID: SwiftDiagnostics.MessageID {
        .init(domain: "observer.universe.kaleidoscope-lexer", id: "GraphError")
    }

    public var severity: SwiftDiagnostics.DiagnosticSeverity {
        .error
    }
}
