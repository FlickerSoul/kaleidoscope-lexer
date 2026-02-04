public struct SpannedLexerIterator<Token: LexerTokenProtocol>: Sequence, IteratorProtocol {
    public typealias Lexer = LexerMachine<Token>

    @usableFromInline
    private(set) var _lexer: Lexer // TODO: beginAccess/endAccess overhead

    @inlinable
    init(lexer: consuming Lexer) {
        _lexer = consume lexer
    }

    @inlinable
    public mutating func next() -> (Lexer.Output, Lexer.Span)? {
        _lexer.next().map { token in
            (token, _lexer.span)
        }
    }
}

public extension LexerMachine {
    @inlinable
    func makeSpannedIterator() -> SpannedLexerIterator<Token> {
        .init(lexer: self)
    }
}
