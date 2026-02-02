// The Swift Programming Language
// https://docs.swift.org/swift-book

// MARK: - New macros

/// Kaleidoscope lexer definition macro
///
/// - Parameter: useStateMachineCodegen: Enable state machine based code generation if true, otherwise use the default
/// backtracking based code generation.
///
/// - Note: use `StateMachineCodegen` trait to modify the default behavior.
@attached(extension, conformances: LexerTokenProtocol, names: arbitrary)
public macro Kaleidoscope(useStateMachineCodegen: Bool? = nil) = #externalMacro(
    module: "KaleidoscopeMacros",
    type: "KaleidoscopeBuilderNext",
)

public typealias Callback<T: LexerTokenProtocol, R> = @Sendable (inout LexerMachine<T>) -> R

@attached(peer)
public macro regex<T: LexerTokenProtocol, R, S>(
    _ value: Regex<S>,
    priority: UInt? = nil,
    callback: @escaping Callback<T, R>,
) = #externalMacro(module: "KaleidoscopeMacros", type: "EnumCaseRegistry")

@attached(peer)
public macro regex<S>(
    _ value: Regex<S>,
    priority: UInt? = nil,
) = #externalMacro(module: "KaleidoscopeMacros", type: "EnumCaseRegistry")

@attached(peer)
public macro token<T: LexerTokenProtocol, R>(
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
