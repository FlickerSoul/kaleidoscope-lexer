import SwiftSyntax
import SwiftSyntaxMacros

public struct Generator {
    public struct Config {
        public let useStateMachineCodeGen: Bool

        public init(useStateMachineCodeGen: Bool = false) {
            self.useStateMachineCodeGen = useStateMachineCodeGen
        }
    }

    public let config: Config
    public let graph: Graph
    public let context: any MacroExpansionContext

    public init(
        config: Config,
        graph: Graph,
        context: any MacroExpansionContext,
    ) {
        self.config = config
        self.graph = graph
        self.context = context
    }

    public mutating func generateLex() throws -> CodeBlockItemListSyntax {
        let states = graph.states()

        return CodeBlockItemListSyntax {}
    }

    enum StateMatchingCode {
        case switchCase(SwitchCaseSyntax)
        case function(FunctionDeclSyntax)

        var syntax: any SyntaxProtocol {
            switch self {
            case let .switchCase(switchCase):
                switchCase
            case let .function(function):
                function
            }
        }
    }

    mutating func generateState(state: State) -> StateMatchingCode {
        let stateData = graph.getStateData(state)
    }
}
