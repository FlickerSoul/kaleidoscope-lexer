import KaleidoscopeLexer
import Testing

@Kaleidoscope(useStateMachineCodegen: true)
private enum PriorityTest: Equatable {
    @token("fast")
    case fast

    @token("fast", priority: 10)
    case faaaast
}

extension `State Based Tokenizer Tests` {
    @Test
    func `priority test`() {
        let actual = Array(PriorityTest.lexer(source: "fast"))
        #expect(actual == [.success(.faaaast)])
    }
}
