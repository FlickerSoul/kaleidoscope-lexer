
public enum _CallbackResult<Token: LexerProtocol> {
    case emit(Token)
    case error(Token.UserError)
    case defaultError
    case skip
}

public enum _SkipResult<Token: LexerProtocol> {
    public typealias CToken = Token

    case skip
    case error(Token.UserError)
}

public protocol SkipResultSource<SToken> {
    associatedtype SToken: LexerProtocol

    func convert() -> _SkipResult<SToken>
}

extension _SkipResult: SkipResultSource {
    public typealias SToken = Token

    public func convert() -> _SkipResult<Token> {
        self
    }
}
