public protocol LexerProtocol {
    associatedtype TokenType: LexerProtocol
    associatedtype Source: LexerSource
    associatedtype UserError: Swift.Error = Never

    typealias TokenStream = [TokenType]

    // TODO: allow user to customize Error type
    typealias LexerError = KaleidoscopeError<UserError>

    static func lex(_ lexer: inout LexerMachine<Self>) -> Result<Self, Self.LexerError>?
    static func lexer(source: Source) -> LexerMachine<Self>
}

public extension LexerProtocol {
    static func lexer(source: Source) -> LexerMachine<Self> {
        LexerMachine(source: source)
    }
}
