import SwiftSyntax
import SwiftSyntaxBuilder
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
            keleidoscopeStates = .identifier("Swift.Int")
            keleidoscopeLeaves = .identifier("Swift.Int")
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

    /// LUT optimization - maps bit tables to indices
    /// BitTable is a 256-element array where each element indicates if that byte matches
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
            context.makeUniqueName("leaf\(idx)")
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

    @CodeBlockItemListBuilder
    func generateStateSetup(stateData: StateData) -> CodeBlockItemListSyntax {
        if let currentLeaf = stateData.type.acceptCurrent {
            let leafIdent = leafIdentifiers[currentLeaf.id]
            "lexer.end(at: \(nameSpace.offset))"
            updateContext(with: leafIdent)
        } else if let beforeLeaf = stateData.type.acceptBefore {
            let leafIdent = leafIdentifiers[beforeLeaf.id]
            "lexer.end(at: \(nameSpace.offset) - 1)"
            updateContext(with: leafIdent)
        }
    }

    // @CodeBlockItemListBuilder
    // private func updateContext(with leafIdent: TokenSyntax) -> CodeBlockItemListSyntax {
    //     "\(nameSpace.context) = .\(leafIdent)"
    // }

    @CodeBlockItemListBuilder
    private func updateContext(with leafIdent: TokenSyntax) -> CodeBlockItemListSyntax {
        "\(nameSpace.context) = \(leafIdent)"
    }

    @CodeBlockItemListBuilder
    func generateCallbackInvocation(callback: CallbackKind, caseName _: TokenSyntax) -> CodeBlockItemListSyntax {
        switch callback {
        case let .named(callbackName):
            "try lexer.setToken(\(callbackName)(&lexer))"
        case let .lambda(closure):
            "try lexer.setToken(\(closure)(&lexer))"
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
                try FunctionDeclSyntax("func \(loopTest)(_ byte: UInt8) -> Bool") {
                    "return (\(lut)[Int(byte)] & \(loopMask.binaryLiteral)) == 0"
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
            tableIdent: tableIdentifier(for: tableIndex),
            mask: 1 << bitPosition,
        )
    }

    private func tableIdentifier(for index: Int) -> TokenSyntax {
        .identifier("_TABLE_\(index)")
    }

    private func renderLUT() -> CodeBlockItemListSyntax {
        let sortedLUTs = loopMasks.sorted { lhs, rhs in
            lhs.value < rhs.value
        }
        var result = CodeBlockItemListSyntax {}
        for (lutIndex, bitArrays) in sortedLUTs.chunk(size: 8).enumerated() {
            var bitValues = [UInt8](repeating: 0, count: 256)
            for (bitIndex, (bits, _)) in bitArrays.enumerated() {
                for (arrayIndex, bit) in bits.enumerated() where bit {
                    bitValues[arrayIndex] |= (1 as UInt8) << bitIndex
                }
            }

            let ident = tableIdentifier(for: lutIndex)
            result.append(contentsOf: CodeBlockItemListSyntax {
                let elements = ArrayElementListSyntax(expressions: bitValues.map { bits in
                    let integer = bits.binaryLiteral

                    return ExprSyntax(IntegerLiteralExprSyntax(literal: integer))
                })

                "let \(ident): InlineArray<256, UInt8> = [\(elements)]"
            })
        }

        return result
    }

    // TODO: use this when compiler crash is fixed
    // private func generateLeavesDefinition() throws -> EnumDeclSyntax {
    //     try EnumDeclSyntax("enum \(nameSpace.keleidoscopeLeaves)") {
    //         for ident in leafIdentifiers {
    //             EnumCaseDeclSyntax(elements: [.init(name: ident)])
    //         }
    //     }
    // }

    /// leaves enum replacement, to avoid compiler crash
    @CodeBlockItemListBuilder
    private func generateLeavesDefinition() throws -> CodeBlockItemListSyntax {
        for (index, ident) in leafIdentifiers.enumerated() {
            "let \(ident): \(nameSpace.keleidoscopeLeaves) = \(raw: index)"
        }
    }

    private func generateLexCommon() throws -> CodeBlockItemListSyntax {
        try CodeBlockItemListSyntax {
            try generateLeavesDefinition()
            try tokenFunctions()
            try renderLUT()
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
                "return \(Constants.Helpers.__convertTupleToEnum)(cb, on: \(enumType).\(caseName))"
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
            try GuardStmtSyntax("guard let context else ") {
                "lexer.endToBoundary(offset: Swift.max(offset, lexer.offset() + 1))"

                "return \(raw: Constants.Types.callbackResult).defaultError"
            }

            try SwitchExprSyntax("switch context") {
                generateLeafBodies(leafIdents: leafIdents, leafBodies: leafBodies)
            }
        }
    }

    // To be used with Leaves enum, when compiler crash is fixed
    // @SwitchCaseListBuilder
    // private func generateLeafBodies(
    //     leafIdents: some Sequence<TokenSyntax>,
    //     leafBodies: some Sequence<CodeBlockItemListSyntax>,
    // ) -> SwitchCaseListSyntax {
    //     for (leafIdent, body) in zip(leafIdents, leafBodies) {
    //         SwitchCaseSyntax("case .\(leafIdent):") {
    //             body
    //         }
    //     }
    // }

    @SwitchCaseListBuilder
    private func generateLeafBodies(
        leafIdents: some Sequence<TokenSyntax>,
        leafBodies: some Sequence<CodeBlockItemListSyntax>,
    ) -> SwitchCaseListSyntax {
        for (leafIdent, body) in zip(leafIdents, leafBodies) {
            SwitchCaseSyntax("case \(leafIdent):") {
                body
            }
        }

        SwitchCaseSyntax("default:") {
            #"fatalError("Invalid leaf identifier. Unknown leaf \(context)")"#
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
                "while let buffer: InlineArray<\(raw: unrollFactor), UInt8> = \(lexer).read(offset: \(offset))",
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
                """

                "\(offset) += 1"
            }
        })
    }

    @CodeBlockItemListBuilder
    func stateAction(stateIdent: TokenSyntax) -> CodeBlockItemListSyntax {
        if config.useStateMachineCodeGen {
            "state = \(stateIdent)"
            "continue"
        } else {
            "return \(stateIdent)(&\(nameSpace.lexerMachineIdent), \(nameSpace.offset), \(nameSpace.context))"
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

        if config.useStateMachineCodeGen {
            return try CodeBlockItemListSyntax {
                let switchCases: [SwitchCaseSyntax] = try states.map { state in
                    try generateState(state: state)
                }
                try generateLexCommon()

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
                        for switchCase in switchCases {
                            switchCase
                        }
                    }
                }
            }
        } else {
            return try CodeBlockItemListSyntax {
                let stateFunctions: [FunctionDeclSyntax] = try states.map { state in
                    try generateState(state: state)
                }

                try generateLexCommon()

                for stateFunction in stateFunctions {
                    stateFunction
                }

                "return \(initStateIdent)(&\(nameSpace.lexerMachineIdent), \(nameSpace.lexerMachineIdent).offset(), nil)"
            }
        }
    }
}

extension Collection {
    func chunk(size: Int) -> [SubSequence] {
        var result: [SubSequence] = []
        var index = startIndex
        while index < endIndex {
            let end = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(self[index ..< end])
            index = end
        }
        return result
    }
}
