//
//  CallbackType.swift
//  Kaleidoscope
//
//  Created by Larry Zeng on 1/13/26.
//

// MARK: - Callback Type

/// Types of callbacks, currently lambda is not usable due to swift compiler bug
public enum CallbackType: Hashable {
    /// A name reference of the callback
    case named(String)
    /// A lambda expression
    case lambda(String)
}

/// Types of tokens, based on how they are processed
public enum TokenType: Hashable {
    /// A token with a fill callback that transforms the token string slice into actual value
    case fillCallback(CallbackType)
    /// A token with a create callback that gives a into token type
    case createCallback(CallbackType)
    /// A token that does not carry any value
    case standalone
    /// A skip mark that signals the lexer to continue matching the next one
    case skip
}
