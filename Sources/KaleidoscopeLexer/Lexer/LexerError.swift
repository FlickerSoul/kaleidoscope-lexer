public enum KaleidoscopeError<UserError: Error>: Error {
    case lexerError
    case userError(UserError)
}

extension KaleidoscopeError: Equatable where UserError: Equatable {}
extension KaleidoscopeError: Hashable where UserError: Hashable {}
extension KaleidoscopeError: Sendable where UserError: Sendable {}
