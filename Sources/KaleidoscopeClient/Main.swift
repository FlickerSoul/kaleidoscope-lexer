import KaleidoscopeLexer

private let parseNumber = { @Sendable (machine: inout LexerMachine<Token>) -> Int in
    Int(machine.slice())!
}

@Kaleidoscope
@skip(/[ \t\n]/) // Skip whitespace
enum Token: Equatable {
    @token("private")
    case `private`

    @token("public")
    case `public`

    @regex(/[a-zA-Z_][a-zA-Z0-9_]*?/)
    case identifier

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
