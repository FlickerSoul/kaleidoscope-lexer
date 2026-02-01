public protocol LexerTokenProtocol {
    associatedtype Source: LexerSource
    associatedtype UserError: Swift.Error

    typealias LexerError = KaleidoscopeError<UserError>
    typealias LexerOutput = Result<Self, LexerError>

    static func lex(_ lexer: inout LexerMachine<Self>) -> LexerOutput?
    static func lexer(source: Source) -> LexerMachine<Self>
}

public extension LexerTokenProtocol {
    static func lexer(source: Source) -> LexerMachine<Self> {
        LexerMachine(source: source)
    }
}
