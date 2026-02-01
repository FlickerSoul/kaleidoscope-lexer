public struct SpannedLexerIterator<Token: LexerTokenProtocol>: Sequence, IteratorProtocol {
    public typealias Span = Range<Int>

    @usableFromInline
    private(set) var _lexer: LexerMachine<Token>

    @inlinable
    public init(lexer: LexerMachine<Token>) {
        _lexer = lexer
    }

    public mutating func next() -> (Result<Token, Token.LexerError>, Span)? {
        _lexer.next().map { token in
            (token, _lexer.span)
        }
    }
}

public extension LexerMachine {
    @inlinable
    var spanned: SpannedLexerIterator<Token> {
        .init(lexer: self)
    }
}
