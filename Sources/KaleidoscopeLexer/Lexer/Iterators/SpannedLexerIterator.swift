public class SpannedLexerIterator<Token: LexerTokenProtocol>: Sequence, IteratorProtocol {
    public typealias Lexer = LexerMachine<Token>

    @usableFromInline
    private(set) var _lexer: Lexer // TODO: beginAccess/endAccess overhead

    @inlinable
    init(lexer: consuming Lexer) {
        _lexer = consume lexer
    }

    public func next() -> (Lexer.Output, Lexer.Span)? {
        _lexer.next().map { token in
            (token, _lexer.span)
        }
    }
}

public extension LexerMachine {
    @inlinable
    consuming func asSpannedIterator() -> SpannedLexerIterator<Token> {
        .init(lexer: self)
    }
}
