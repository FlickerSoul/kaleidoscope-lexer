extension LexerMachine: Sequence, IteratorProtocol {
    @inlinable
    public mutating func next() -> Output? {
        tokenStart = tokenEnd
        return Token.lex(&self)
    }
}
