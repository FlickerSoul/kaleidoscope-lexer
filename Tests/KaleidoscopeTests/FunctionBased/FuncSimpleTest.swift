import KaleidoscopeLexer
import Testing

@Kaleidoscope
private enum SimpleTest: Equatable {
    @regex(/a/)
    case a

    @regex(/b/)
    case b
}

extension `Function Based Tokenizer Tests` {
    @Test(arguments: [
        ("a", [.success(.a)]),
        ("b", [.success(.b)]),
        ("ab", [.success(.a), .success(.b)]),
        ("ba", [.success(.b), .success(.a)]),
        ("c", [.failure(.lexerError)]),
        ("acb", [.success(.a), .failure(.lexerError), .success(.b)]),
    ] as [(String, [SimpleTest.LexerOutput])])
    private func `simple tokenizer`(source: String, expected: [SimpleTest.LexerOutput]) {
        let actual = Array(SimpleTest.lexer(source: source))
        #expect(actual == expected)
    }
}
