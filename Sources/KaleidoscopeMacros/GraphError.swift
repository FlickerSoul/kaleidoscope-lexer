import KaleidoscopeMacroSupportNext
import SwiftDiagnostics
import SwiftSyntax

enum GraphError: Error, Hashable, Sendable, DiagnosticMessage {
    case multipleLeavesWithSamePriority([String], priority: Int)

    var message: String {
        switch self {
        case let .multipleLeavesWithSamePriority(leaves, priority):
            "Multiple leaves have the same priority of \(priority). Priorities must be unique. (\(leaves))"
        }
    }

    var diagnosticID: SwiftDiagnostics.MessageID {
        .init(domain: "observer.universe.kaleidoscope-lexer", id: "GraphError")
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        .error
    }
}
