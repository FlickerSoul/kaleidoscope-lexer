public enum KaleidoscopeError<UserError: Error>: Error {
    case lexerError
    case userError(UserError)
}
