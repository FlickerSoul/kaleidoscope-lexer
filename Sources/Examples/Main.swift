@main
enum Main {
    static func main() {
        // Tokenize a string
        let source = "private foo(123)"
        for result in ExampleToken.lexer(source: source) {
            switch result {
            case let .success(token):
                print(token)
            case let .failure(error):
                print("Error: \(error)")
            }
        }
    }
}
