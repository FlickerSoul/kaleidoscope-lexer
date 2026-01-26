public protocol LexerProtocol {
    associatedtype TokenType: LexerProtocol
    associatedtype Source: LexerSource

    typealias TokenStream = [TokenType]

    // TODO: allow user to customize Error type
    typealias Error = any Swift.Error

    static func lex(_ lexer: inout LexerMachine<Self>) -> Result<Self, Self.Error>?
    static func lexer(source: Source) -> LexerMachine<Self>
}

public extension LexerProtocol {
    static func lexer(source: Source) -> LexerMachine<Self> {
        LexerMachine(source: source)
    }
}
