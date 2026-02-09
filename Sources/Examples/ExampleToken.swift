import KaleidoscopeLexer

private typealias Lexer = LexerMachine<ExampleToken>

private let parseNumber = { @Sendable (machine: inout Lexer) -> Int in
    Int(machine.slice())!
}

private let parseIdentifier = { @Sendable (machine: inout Lexer) -> String in
    String(machine.slice())
}

private let printer = { @Sendable (machine: inout Lexer) in
    print(machine.slice())
}

@Kaleidoscope
@skip(/[ \t\n]/) // Skip whitespace
enum ExampleToken: Equatable {
    @token("invalid", callback: printer)
    case invalid

    @token("private")
    case `private`

    @token("public")
    case `public`

    @regex(/[a-zA-Z_][a-zA-Z0-9_]*?/, callback: parseIdentifier)
    case identifier(String)

    @regex(/[0-9]+?/, callback: parseNumber)
    case number(Int)

    @token(".")
    case dot

    @token("(")
    case parenOpen

    @token(")")
    case parenClose
}
