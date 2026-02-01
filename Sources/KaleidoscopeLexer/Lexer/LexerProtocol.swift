public protocol LexerProtocol {
    associatedtype Source: LexerSource
    associatedtype UserError: Swift.Error

    typealias LexerError = KaleidoscopeError<UserError>
    typealias LexerOutput = Result<Self, LexerError>

    static func lex(_ lexer: inout LexerMachine<Self>) -> LexerOutput?
    static func lexer(source: Source) -> LexerMachine<Self>
}

public extension LexerProtocol {
    static func lexer(source: Source) -> LexerMachine<Self> {
        LexerMachine(source: source)
    }
}
