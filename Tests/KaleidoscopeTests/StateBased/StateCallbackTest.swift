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

private let abCallback = { @Sendable (machine: inout LexerMachine<CallbackTest>) -> (String, String) in
    let slice = machine.slice()
    let parts = slice.split(separator: ".")
    return (String(parts[0]), String(parts[1]))
}

// TODO: @skip(/aaa/, callback: skipPrintCallback) // This doesn't work because circular reference in swift
@Kaleidoscope(useStateMachineCodegen: true)
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

    @regex(/a+?.b+?/, callback: abCallback)
    case abGroup(a: String, b: String)
}

extension `State Based Tokenizer Tests` {
    @Test(arguments: [
        ("123", [.success(.number(123))]),
        ("456", [.success(.number(456))]),
        ("78 90", [.success(.number(78)), .success(.number(90))]),
        ("ident", [.success(.ident)]),
        ("ident 123", [.success(.ident), .success(.number(123))]),
        ("skip ident 42 skip 99", [.success(.ident), .success(.number(42)), .success(.number(99))]),
        ("regular skip 99", [.success(.number(99))]),
        ("a.bbb", [.success(.abGroup(a: "a", b: "bbb"))]),
        ("aaa.bbbbb", [.success(.abGroup(a: "aaa", b: "bbbbb"))]),
    ] as [(String, [CallbackTest.LexerOutput])])
    private func `callback tokenizer`(source: String, expected: [CallbackTest.LexerOutput]) {
        let actual = Array(CallbackTest.lexer(source: source))
        #expect(actual == expected)
    }
}
