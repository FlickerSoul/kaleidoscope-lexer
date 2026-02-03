extension LexerMachine: Sequence, IteratorProtocol {
    public mutating func next() -> Output? {
        tokenStart = tokenEnd
        return Token.lex(&self)
    }
}
