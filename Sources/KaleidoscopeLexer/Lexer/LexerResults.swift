public enum _CallbackResult<Token: LexerTokenProtocol> {
    case emit(Token)
    case error(Token.UserError)
    case defaultError
    case skip
}

public enum _SkipResult<Token: LexerTokenProtocol> {
    public typealias CToken = Token

    case skip
    case error(Token.UserError)
}

public protocol _SkipResultSource<SToken> {
    associatedtype SToken: LexerTokenProtocol

    func convert() -> _SkipResult<SToken>
}

extension _SkipResult: _SkipResultSource {
    public typealias SToken = Token

    @inlinable
    public func convert() -> _SkipResult<Token> {
        self
    }
}
