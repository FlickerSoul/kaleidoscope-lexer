import KaleidoscopeLexer
import Testing

private let intCallback = { @Sendable (machine: inout LexerMachine<CallbackTest>) -> Int in
    Int(machine.slice())!
}

private let printCallback = { @Sendable (machine: inout LexerMachine<CallbackTest>) in
    print(machine.slice())
}

private let skipPrintCallback = { @Sendable (machine: inout LexerMachine<CallbackTest>) -> _SkipResult<CallbackTest> in
    print("skipping \(machine.slice())")
    return .skip
}

// TODO: @skip(/aaa/, callback: skipPrintCallback) // This doesn't work because circular reference in swift
@Kaleidoscope
@skip(/[ ]/)
private enum CallbackTest: Equatable {
    @regex(/[0-9]+?/, callback: intCallback)
    case number(Int)

    @token("ident", callback: printCallback)
    case ident

    @skip("skip", callback: skipPrintCallback)
    case skipped

    @skip("regular skip")
    case regularSkip
}

extension `Tokenizer Tests` {
    @Test(arguments: [
        ("123", [.success(.number(123))]),
        ("456", [.success(.number(456))]),
        ("78 90", [.success(.number(78)), .success(.number(90))]),
        ("ident", [.success(.ident)]),
        ("ident 123", [.success(.ident), .success(.number(123))]),
        ("skip ident 42 skip 99", [.success(.ident), .success(.number(42)), .success(.number(99))]),
        ("regular skip 99", [.success(.number(99))]),
    ] as [(String, [CallbackTest.LexerOutput])])
    private func `callback tokenizer`(source: String, expected: [CallbackTest.LexerOutput]) {
        let actual = Array(CallbackTest.lexer(source: source))
        #expect(actual == expected)
    }
}
