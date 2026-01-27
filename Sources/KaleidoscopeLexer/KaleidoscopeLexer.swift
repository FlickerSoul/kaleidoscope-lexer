// The Swift Programming Language
// https://docs.swift.org/swift-book

// MARK: - New macros

@attached(extension, conformances: LexerProtocol, names: arbitrary)
public macro Kaleidoscope() = #externalMacro(
    module: "KaleidoscopeMacros",
    type: "KaleidoscopeBuilderNext",
)

public typealias Callback<T: LexerProtocol, R> = @Sendable (inout LexerMachine<T>) -> R

@attached(peer)
public macro regex<T: LexerProtocol, R>(
    _ value: Regex<Substring>,
    priority: UInt? = nil,
    callback: @escaping Callback<T, R>,
) = #externalMacro(module: "KaleidoscopeMacros", type: "EnumCaseRegistry")

@attached(peer)
public macro regex(
    _ value: Regex<Substring>,
    priority: UInt? = nil,
) = #externalMacro(module: "KaleidoscopeMacros", type: "EnumCaseRegistry")

@attached(peer)
public macro token<T: LexerProtocol, R>(
    _ value: String,
    priority: UInt? = nil,
    callback: @escaping Callback<T, R>,
) = #externalMacro(module: "KaleidoscopeMacros", type: "EnumCaseRegistry")

@attached(peer)
public macro token(
    _ value: String,
    priority: UInt? = nil,
) = #externalMacro(module: "KaleidoscopeMacros", type: "EnumCaseRegistry")

/// Mark a regex pattern to be skipped by the lexer
///
/// - SeeAlso: ``skip(_:priority:)``
@attached(peer)
public macro skip(
    _ value: Regex<Substring>,
    priority: UInt? = nil,
) = #externalMacro(module: "KaleidoscopeMacros", type: "EnumCaseRegistry")

/// Mark a string to be skipped by the lexer
///
/// - SeeAlso: ``skip(_:priority:)``
@attached(peer)
public macro skip(
    _ value: String,
    priority: UInt? = nil,
) = #externalMacro(module: "KaleidoscopeMacros", type: "EnumCaseRegistry")
