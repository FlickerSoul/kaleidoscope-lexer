public class LexerIterator<Token: LexerTokenProtocol>: Sequence, IteratorProtocol {
    public typealias Lexer = LexerMachine<Token>

    @usableFromInline
    private(set) var _lexer: Lexer // TODO: beginAccess/endAccess overhead

    @inlinable
    init(lexer: consuming Lexer) {
        _lexer = consume lexer
    }

    public func next() -> Result<Token, Token.LexerError>? {
        _lexer.next()
    }
}

public extension LexerMachine {
    consuming func asIterator() -> LexerIterator<Token> {
        LexerIterator(lexer: self)
    }

    @inlinable
    var iterator: LexerIterator<Token> {
        consuming get {
            LexerIterator(lexer: self)
        }
    }
}
