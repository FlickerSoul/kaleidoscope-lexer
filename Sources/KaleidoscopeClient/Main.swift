import KaleidoscopeLexer

private let parseNumber = { @Sendable (machine: inout LexerMachine<Token>) -> Int in
    Int(machine.slice())!
}

private let parseIdentifier = { @Sendable (machine: inout LexerMachine<Token>) -> String in
    String(machine.slice())
}

private let printer = { @Sendable (machine: inout LexerMachine<Token>) in
    print(machine.slice())
}

@Kaleidoscope
@skip(/[ \t\n]/) // Skip whitespace
enum Token: Equatable {
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

@main
enum Tokenizer {
    static func main() {
        // Tokenize a string
        let source = "private foo(123)"
        for result in Token.lexer(source: source) {
            switch result {
            case let .success(token):
                print(token)
            case let .failure(error):
                print("Error: \(error)")
            }
        }
    }
}
