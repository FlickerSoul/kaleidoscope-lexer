import SwiftSyntax
import SwiftSyntaxMacros

public enum GeneratorError: Error {
    case invalidStateIdentifier(stateID: Int)
}

public struct Generator {
    public struct Config {
        public let useStateMachineCodeGen: Bool

        public init(useStateMachineCodeGen: Bool = false) {
            self.useStateMachineCodeGen = useStateMachineCodeGen
        }
    }

    struct NameSpace {
        let lexerMachineIdent: TokenSyntax
        let keleidoscopeStates: TokenSyntax
        let keleidoscopeLeaves: TokenSyntax
        let getAction: TokenSyntax
        let offset: TokenSyntax
        let context: TokenSyntax
        let state: TokenSyntax

        init(macroContext: any MacroExpansionContext) {
            lexerMachineIdent = .identifier("lexer")
            keleidoscopeStates = macroContext.makeUniqueName("__KaleidoscopeStates")
            keleidoscopeLeaves = macroContext.makeUniqueName("__KaleidoscopeLeaves")
            getAction = macroContext.makeUniqueName("__getAction")
            offset = macroContext.makeUniqueName("offset")
            context = macroContext.makeUniqueName("context")
            state = macroContext.makeUniqueName("state")
        }
    }

    public let enumType: any TypeSyntaxProtocol
    public let config: Config
    public let graph: Graph
    public let context: any MacroExpansionContext
    let nameSpace: NameSpace

    // State and leaf identifiers (cached for performance)
    private var stateIdentifiers: [State: TokenSyntax] = [:]
    private var leafIdentifiers: [TokenSyntax] = []

    // LUT optimization - maps bit tables to indices
    // BitTable is a 256-element array where each element indicates if that byte matches
    private var loopMasks: [[Bool]: Int] = [:]

    public init(
        enumType: any TypeSyntaxProtocol,
        config: Config,
        graph: Graph,
        context: any MacroExpansionContext,
    ) {
        self.enumType = enumType
        self.config = config
        self.graph = graph
        self.context = context
        nameSpace = NameSpace(macroContext: context)

        // Pre-compute state identifiers
        stateIdentifiers = graph
            .states()
            .reduce(into: [:]) { result, state in
                result[state] = stateIdentifier(for: state)
            }

        // Pre-compute leaf identifiers
        leafIdentifiers = (0 ..< graph.leaves.count).map { idx in
            .identifier("leaf\(idx)")
        }
    }

    func stateIdentifier(for state: State) -> TokenSyntax {
        .identifier(config.useStateMachineCodeGen ? "state\(state.id)" : "jumpTo_\(state.id)")
    }

    // MARK: - State Identifier Helpers

    func getIdentifier(_ state: State) throws(GeneratorError) -> TokenSyntax {
        guard let stateIdentifier = stateIdentifiers[state] else {
            throw GeneratorError.invalidStateIdentifier(stateID: state.id)
        }

        return stateIdentifier
    }

    func stateValue(_ state: State) throws(GeneratorError) -> TokenSyntax {
        let ident = try getIdentifier(state)
        if config.useStateMachineCodeGen {
            return "\(nameSpace.keleidoscopeStates).\(ident)"
        } else {
            return "\(ident)"
        }
    }

    /// Convert ByteClass to 256-element bit array
    func byteClassToTableBits(_ byteClass: ByteClass) -> [Bool] {
        var bits = [Bool](repeating: false, count: 256)
        for range in byteClass.ranges {
            for byte in range.lowerBound ... range.upperBound {
                bits[Int(byte)] = true
            }
        }
        return bits
    }

    // MARK: - State Setup

    func generateStateSetup(stateData: StateData) -> CodeBlockItemListSyntax {
        if let earlyLeaf = stateData.type.early {
            let leafIdent = leafIdentifiers[earlyLeaf.id]
            return CodeBlockItemListSyntax {
                "lexer.end(at: \(nameSpace.offset))"
                "\(nameSpace.context) = .\(leafIdent)"
            }
        } else if let acceptLeaf = stateData.type.accept {
            let leafIdent = leafIdentifiers[acceptLeaf.id]
            return CodeBlockItemListSyntax {
                "lexer.end(at: \(nameSpace.offset) - 1)"
                "\(nameSpace.context) = .\(leafIdent)"
            }
        } else {
            return CodeBlockItemListSyntax {}
        }
    }

    func generateCallbackInvocation(callback: CallbackKind, caseName _: TokenSyntax) -> CodeBlockItemListSyntax {
        switch callback {
        case let .named(callbackName):
            CodeBlockItemListSyntax {
                "try lexer.setToken(\(callbackName)(&lexer))"
            }
        case let .lambda(closure):
            CodeBlockItemListSyntax {
                "try lexer.setToken(\(closure)(&lexer))"
            }
        }
    }

    // MARK: - State Generation

    private mutating func generateState(state: State) throws -> SwitchCaseSyntax {
        let thisIdent = try getIdentifier(state)

        return try SwitchCaseSyntax("case .\(thisIdent)") {
            try generateStateImpl(state: state)
        }
    }

    private mutating func generateState(state: State) throws -> FunctionDeclSyntax {
        let thisIdent = try getIdentifier(state)

        return try FunctionDeclSyntax(
            "func \(thisIdent)(_ \(raw: nameSpace.lexerMachineIdent): inout \(raw: Constants.Types.lexerMachine)<\(enumType)>, _ offset: Int, _ context: \(raw: nameSpace.keleidoscopeLeaves)?) -> Result<\(enumType), \(enumType).\(Constants.Types.lexerError)>?",
        ) {
            "var \(raw: nameSpace.offset) = offset"
            "var \(raw: nameSpace.context) = context"
            try generateStateImpl(state: state)
        }
    }

    private mutating func generateStateImpl(state: State) throws -> CodeBlockItemListSyntax {
        let stateData = graph.getStateData(state)
        // Generate setup code for accepting states
        let setup = generateStateSetup(stateData: stateData)

        // Generate byte matching (fork)
        let fastLoop = try maybeImplementFastLoop(state: state, stateData: stateData)
        let fork = try implementFork(state: state, stateData: stateData, ignoreSelf: true)

        return CodeBlockItemListSyntax {
            fastLoop
            setup
            fork
        }
    }

    private mutating func maybeImplementFastLoop(
        state: State,
        stateData: borrowing StateData,
    ) throws -> CodeBlockItemListSyntax {
        let selfEdge = stateData.normal.filter { $0.state == state }
        assert(selfEdge.count <= 1, "Multiple self-loops detected")
        if let selfEdge = selfEdge.first {
            let (lut, loopMask) = addTestToLUT(byteClass: selfEdge.byteClass)
            return try CodeBlockItemListSyntax {
                let loopTest: TokenSyntax = .identifier("loopTest")
                try FunctionDeclSyntax("func \(loopTest)(byte: UInt8) -> Bool") {
                    "return (\(lut)[Int(byte)] & \(raw: loopMask)) == 0"
                }
                try fastLoop(
                    unrollFactor: 8,
                    lexer: nameSpace.lexerMachineIdent,
                    test: loopTest,
                    offset: nameSpace.offset,
                )
            }
        } else {
            return CodeBlockItemListSyntax {}
        }
    }

    private mutating func addTestToLUT(byteClass: ByteClass) -> (tableIdent: TokenSyntax, mask: UInt8) {
        let tableBits = byteClassToTableBits(byteClass)

        let loopId: Int
        if let existing = loopMasks[tableBits] {
            loopId = existing
        } else {
            loopId = loopMasks.count
            loopMasks[tableBits] = loopId
        }

        let tableIndex = loopId / 8
        let bitPosition = loopId % 8

        return (
            tableIdent: .identifier("_TABLE_\(tableIndex)"),
            mask: 1 << bitPosition,
        )
    }

    private func generateLexCommon() throws -> CodeBlockItemListSyntax {
        try CodeBlockItemListSyntax {
            // compiler crahses :((
            try EnumDeclSyntax("enum \(nameSpace.keleidoscopeLeaves)") {
                for ident in leafIdentifiers {
                    EnumCaseDeclSyntax(elements: [.init(name: ident)])
                }
            }

            try tokenFunctions()
        }
    }

    private func generateCallback(from leaf: borrowing Leaf) -> CodeBlockItemListSyntax {
        let callbackOp: ExprSyntax? = switch leaf.callback {
        case let .named(callbackName: callbackRef):
            ExprSyntax("\(callbackRef)(&\(nameSpace.lexerMachineIdent))")
        case let .lambda(closure: callbackFunc):
            ExprSyntax("\(callbackFunc)(&\(nameSpace.lexerMachineIdent))")
        case nil:
            nil
        }

        return CodeBlockItemListSyntax {
            switch (leaf.kind, callbackOp) {
            case (.skip, nil):
                "return \(raw: Constants.Types.callbackResult).skip"
            case let (.skip, callback?):
                "let cb = \(callback) as \(raw: Constants.Types.skipResultSource)"
                "return cb.convert()"
            case let (.caseOnly(caseName), nil):
                "return \(raw: Constants.Types.callbackResult).emit(\(enumType).\(caseName))"
            case let (.caseOnly(caseName), callback?):
                "let cb: Void = \(callback)"
                "return \(enumType).\(caseName)"
            case (.associatedValues, nil):
                #"#error("Associated values require a callback")"#
            case let (.associatedValues(caseName, _), callback?):
                "let cb = \(callback)"
                "return \(raw: Constants.Helpers.__convertTupleToEnum)(cb, converter: \(enumType).\(caseName))"
            }
        }
    }

    private func tokenFunctions() throws -> FunctionDeclSyntax {
        let leafBodies = graph
            .leaves
            .map { leaf in
                generateCallback(from: leaf)
            }
        let leafIdents = leafIdentifiers

        assert(leafBodies.count == leafIdents.count, "Leaf identifiers and bodies count mismatch")

        return try FunctionDeclSyntax(
            "func \(nameSpace.getAction)(lexer: inout \(raw: Constants.Types.lexerMachine)<\(enumType)>, offset: Int, context: \(nameSpace.keleidoscopeLeaves)?) -> \(raw: Constants.Types.callbackResult)<\(enumType)>",
        ) {
            try SwitchExprSyntax("switch context") {
                SwitchCaseSyntax("case nil:") {
                    "lexer.endToBoundary(offset: Swift.max(offset, lexer.offset() + 1))"

                    "return \(raw: Constants.Types.callbackResult).defaultError"
                }
                for (leafIdent, leafBody) in zip(leafIdents, leafBodies) {
                    SwitchCaseSyntax("case .\(leafIdent):") {
                        leafBody
                    }
                }
            }
        }
    }

    private func fastLoop(
        unrollFactor: Int,
        lexer: TokenSyntax,
        test: TokenSyntax,
        offset: TokenSyntax,
    ) throws -> LabeledStmtSyntax {
        try LabeledStmtSyntax(label: "outer", statement: DoStmtSyntax {
            try WhileStmtSyntax(
                "while let buffer = \(lexer).read(offset: \(offset), length: \(raw: unrollFactor))",
            ) {
                for i in 0 ..< unrollFactor {
                    try IfExprSyntax("if \(test)(buffer[\(raw: i)])") {
                        "\(offset) += \(raw: i)"
                        "break outer"
                    }
                }
                "\(offset) += \(raw: unrollFactor)"
            }

            try WhileStmtSyntax("while let byte = \(lexer).read(offset: \(offset))") {
                """
                if \(test)(byte) {
                    break outer
                }
                \(offset) += 1
                """
            }
        })
    }

    func stateAction(stateIdent: TokenSyntax) -> CodeBlockItemListSyntax {
        if config.useStateMachineCodeGen {
            CodeBlockItemListSyntax {
                "state = \(stateIdent)"
                "continue"
            }
        } else {
            CodeBlockItemListSyntax {
                "return \(stateIdent)(&\(nameSpace.lexerMachineIdent), \(nameSpace.offset), \(nameSpace.context))"
            }
        }
    }

    func takeAction(
        lex: TokenSyntax,
        offset: TokenSyntax,
        context: TokenSyntax,
        state: TokenSyntax,
    ) throws -> CodeBlockItemListSyntax {
        let stateIdent = try stateValue(graph.root)
        let restartLexer = CodeBlockItemListSyntax {
            if config.useStateMachineCodeGen {
                "\(state) = \(stateIdent)"
                "continue"
            } else {
                "return \(stateIdent)(&\(lex), \(offset), \(context))"
            }
        }

        return try CodeBlockItemListSyntax {
            "let action = \(nameSpace.getAction)(lexer: &\(lex), offset: \(offset), context: \(context))"

            try SwitchExprSyntax("switch action") {
                SwitchCaseSyntax("case .emit(let token):") {
                    "return .success(token)"
                }
                SwitchCaseSyntax("case .skip:") {
                    "lexer.trivia()"
                    "\(offset) = lexer.offset()"
                    "\(context) = nil"
                    restartLexer
                }
                SwitchCaseSyntax("case .error(let error):") {
                    "return .failure(.userError(error))"
                }
                SwitchCaseSyntax("case .defaultError:") {
                    "return .failure(.lexerError)"
                }
            }
        }
    }

    // MAKR: - Fix compiler crash

    public mutating func generateLex() throws -> CodeBlockItemListSyntax {
        let states = graph.states()

        let initStateIdent = try getIdentifier(graph.root)
        let commons = try generateLexCommon()

        if config.useStateMachineCodeGen {
            return try CodeBlockItemListSyntax {
                commons

                try EnumDeclSyntax("enum \(nameSpace.keleidoscopeStates)") {
                    for state in states {
                        try EnumCaseDeclSyntax(elements: [.init(name: getIdentifier(state))])
                    }
                }

                "var \(nameSpace.state) = \(nameSpace.keleidoscopeStates).\(initStateIdent)"
                "var \(nameSpace.offset) = lexer.offset()"
                "var \(nameSpace.context): \(nameSpace.keleidoscopeLeaves)? = nil"

                try WhileStmtSyntax("while true") {
                    try SwitchExprSyntax("switch \(nameSpace.state)") {
                        for state in states {
                            try generateState(state: state)
                        }
                    }
                }
            }
        } else {
            return try CodeBlockItemListSyntax {
                commons

                for state in states {
                    try generateState(state: state)
                }

                "return \(initStateIdent)(&\(nameSpace.lexerMachineIdent), \(nameSpace.lexerMachineIdent).offset(), nil)"
            }
        }
    }
}
