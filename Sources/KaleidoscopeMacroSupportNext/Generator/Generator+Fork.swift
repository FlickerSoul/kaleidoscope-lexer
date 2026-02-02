import SwiftSyntax

extension Generator {
    func implementFork(
        state: State,
        stateData: borrowing StateData,
        ignoreSelf: Bool,
    ) throws -> CodeBlockItemListSyntax {
        try implementForkTable(state: state, stateData: stateData, ignoreSelf: ignoreSelf)
        // if stateData.normal.count > 2 {
        //     try implementForkTable(state: state, stateData: stateData, ignoreSelf: ignoreSelf)
        // } else {
        //     try implementForkMatch(state: state, stateData: stateData, ignoreSelf: ignoreSelf)
        // }
    }

    private func implementForkTable(
        state: State,
        stateData: borrowing StateData,
        ignoreSelf: Bool,
    ) throws -> CodeBlockItemListSyntax {
        var table = [State?](repeating: nil, count: 256)
        for normal in stateData.normal {
            if ignoreSelf, normal.state == state {
                continue
            }

            for range in normal.byteClass.ranges {
                for byte in range {
                    table[Int(byte)] = normal.state
                }
            }
        }

        let nextState: TokenSyntax = .identifier("nextState")
        let body: CodeBlockItemListSyntax

        if config.useStateMachineCodeGen {
            let action = stateAction(stateIdent: nextState)

            body = try CodeBlockItemListSyntax {
                "let \(nextState): \(nameSpace.keleidoscopeStates)?"

                try SwitchExprSyntax("switch byte") {
                    for (index, state) in table.enumerated() {
                        if let state {
                            try SwitchCaseSyntax("case \(raw: index):") {
                                try "\(nextState) = .\(stateValue(state))"
                            }
                        }
                    }

                    SwitchCaseSyntax("default:") {
                        "nextState = nil"
                    }
                }

                try IfExprSyntax("if let \(nextState)") {
                    "\(nameSpace.offset) += 1"
                    action
                }
            }
        } else {
            let stateSet = Set(table.compactMap(\.self))
            let states = stateSet.sorted()

            let actions = try Dictionary(
                uniqueKeysWithValues: states.map { state in
                    try (
                        state,
                        stateAction(stateIdent: stateValue(state)),
                    )
                },
            )

            body = try CodeBlockItemListSyntax {
                if !states.isEmpty {
                    "\(nameSpace.offset) += 1"

                    try SwitchExprSyntax("switch byte") {
                        var previousActionInfo: (byte: Int, action: CodeBlockItemListSyntax?) = (0, nil)

                        for (byteToJump, state) in table.enumerated() {
                            let action = state.map { actions[$0]! }

                            if action != previousActionInfo.action {
                                if let previousAction = previousActionInfo.action {
                                    SwitchCaseSyntax(
                                        "case \(previousActionInfo.byte.hexLiteral) ..< \(byteToJump.hexLiteral):",
                                    ) {
                                        previousAction
                                    }
                                }

                                // swiftlint:disable:next redundant_discardable_let
                                let _ = previousActionInfo = (byteToJump, action)
                            }
                        }

                        if let previousAction = previousActionInfo.action {
                            SwitchCaseSyntax("case \(previousActionInfo.byte.hexLiteral) ... 0xFF:") {
                                previousAction
                            }
                        }

                        SwitchCaseSyntax("default:") {
                            "break"
                        }
                    }

                    "\(nameSpace.offset) -= 1"
                }
            }
        }

        let eoi = try forkEOI(state: state)

        return try CodeBlockItemListSyntax {
            if !body.isEmpty || !eoi.isEmpty {
                "let byte = lexer.read(offset: \(nameSpace.offset))"

                try IfExprSyntax("if let byte") {
                    body
                } else: {
                    eoi
                }
            }

            try takeAction(
                lex: nameSpace.lexerMachineIdent,
                offset: nameSpace.offset,
                context: nameSpace.context,
                state: nameSpace.state,
            )
        }
    }

    private func forkEOI(state: State) throws -> CodeBlockItemListSyntax {
        try CodeBlockItemListSyntax {
            if state == graph.root {
                try IfExprSyntax(
                    "if \(nameSpace.lexerMachineIdent).offset() == \(nameSpace.offset)",
                ) {
                    "return nil"
                }
            }
        }
    }

    // private func implementForkMatch(
    //     state: State,
    //     stateData: borrowing StateData,
    //     ignoreSelf: Bool,
    // ) throws -> CodeBlockItemListSyntax {
    //     let innerCase = CodeBlockItemListSyntax {
    //         for normal in stateData.normal where !ignoreSelf || normal.state != state {}
    //     }
    //     let eoi = try forkEOI(state: state)

    //     return try CodeBlockItemListSyntax {
    //         let other = TokenSyntax.identifier("other")

    //         "let \(other) = try lexer.read(offset: \(nameSpace.offset))"

    //         try IfExprSyntax("if let \(other)") {
    //             innerCase
    //         } else: {
    //             eoi
    //         }

    //         try takeAction(
    //             lex: nameSpace.lexerMachineIdent,
    //             offset: nameSpace.offset,
    //             context: nameSpace.context,
    //             state: nameSpace.state,
    //         )
    //     }
    // }
}
