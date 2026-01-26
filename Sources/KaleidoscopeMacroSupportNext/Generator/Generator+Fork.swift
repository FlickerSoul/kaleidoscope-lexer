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
                "let \(nextState): \(Constants.Identifiers.keleidoscopeStates)?"

                try SwitchExprSyntax("switch byte") {
                    for (index, state) in table.enumerated() {
                        if let state {
                            try SwitchCaseSyntax("case \(raw: index):") {
                                try "\(nextState) = \(stateValue(state))"
                            }
                        }
                    }

                    SwitchCaseSyntax("default:") {
                        "nextState = nil"
                    }
                }

                try IfExprSyntax("if let \(nextState)") {
                    "\(Constants.Identifiers.offset) += 1"
                    action
                }
            }
        } else {
            let stateSet = Set(table.compactMap(\.self))
            let states = stateSet.sorted()

            let stateIdents = try states.map(getIdentifier(_:))
            let actions = try states.map { state in
                try stateAction(stateIdent: stateValue(state))
            }

            body = try CodeBlockItemListSyntax {
                let noneState: TokenSyntax = .identifier("__none")
                let nextStateType = TokenSyntax.identifier("NextState")

                try EnumDeclSyntax("enum \(nextStateType)") {
                    for stateIdent in stateIdents {
                        EnumCaseDeclSyntax(elements: [.init(name: stateIdent)])
                    }
                    EnumCaseDeclSyntax(elements: [.init(name: noneState)])
                }

                "let \(nextState): \(nextStateType)?"

                "\(Constants.Identifiers.offset) += 1"

                try SwitchExprSyntax("switch byte") {
                    for (index, state) in table.enumerated() {
                        if let state {
                            try SwitchCaseSyntax("case \(raw: index):") {
                                try "\(nextState) = \(stateValue(state))"
                            }
                        }
                    }

                    SwitchCaseSyntax("default:") {
                        "nextState = nil"
                    }
                }

                try SwitchExprSyntax("switch \(nextState)") {
                    for (stateIdent, action) in zip(stateIdents, actions) {
                        SwitchCaseSyntax("case .\(stateIdent):") {
                            action
                        }
                    }

                    SwitchCaseSyntax("case .\(noneState)") {
                        "break"
                    }
                }

                "\(Constants.Identifiers.offset) -= 1"
            }
        }

        let eoi = try forkEOI(state: state)

        return try CodeBlockItemListSyntax {
            "let other = try lexer.read(offset: offset)"

            try IfExprSyntax("if let other") {
                body
            } else: {
                eoi
            }

            try takeAction(
                lex: Constants.Identifiers.lexerMachineIdent,
                offset: Constants.Identifiers.offset,
                context: Constants.Identifiers.context,
                state: Constants.Identifiers.state,
            )
        }
    }

    private func forkEOI(state: State) throws -> CodeBlockItemListSyntax {
        try CodeBlockItemListSyntax {
            if state == graph.root {
                try IfExprSyntax(
                    "if \(Constants.Identifiers.lexerMachineIdent).offset() == \(Constants.Identifiers.offset)",
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

    //         "let \(other) = try lexer.read(offset: \(Constants.Identifiers.offset))"

    //         try IfExprSyntax("if let \(other)") {
    //             innerCase
    //         } else: {
    //             eoi
    //         }

    //         try takeAction(
    //             lex: Constants.Identifiers.lexerMachineIdent,
    //             offset: Constants.Identifiers.offset,
    //             context: Constants.Identifiers.context,
    //             state: Constants.Identifiers.state,
    //         )
    //     }
    // }
}
