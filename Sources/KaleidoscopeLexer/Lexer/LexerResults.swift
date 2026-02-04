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

public protocol _SkipResultSource<Token> {
    associatedtype Token: LexerTokenProtocol

    func convert() -> _SkipResult<Token>
}

extension _SkipResult: _SkipResultSource {
    @inlinable
    public func convert() -> _SkipResult<Token> {
        self
    }

    @inlinable
    public func asCallbackResult() -> _CallbackResult<Token> {
        switch self {
        case .skip:
            .skip
        case let .error(error):
            .error(error)
        }
    }
}
