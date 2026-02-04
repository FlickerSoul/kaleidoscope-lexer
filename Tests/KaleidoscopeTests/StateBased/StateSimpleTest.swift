import KaleidoscopeLexer
import Testing

@Kaleidoscope(useStateMachineCodegen: true)
private enum StateSimpleTest: Equatable {
    @regex(/a/)
    case a

    @regex(/b/)
    case b
}

extension `State Based Tokenizer Tests` {
    @Test(arguments: [
        ("a", [.success(.a)]),
        ("b", [.success(.b)]),
        ("ab", [.success(.a), .success(.b)]),
        ("ba", [.success(.b), .success(.a)]),
        ("c", [.failure(.lexerError)]),
        ("acb", [.success(.a), .failure(.lexerError), .success(.b)]),
    ] as [(String, [StateSimpleTest.LexerOutput])])
    private func `simple tokenizer`(source: String, expected: [StateSimpleTest.LexerOutput]) {
        let actual = Array(StateSimpleTest.lexer(source: source))
        #expect(actual == expected)
    }
}
