import KaleidoscopeLexer
import Testing

@Kaleidoscope(useStateMachineCodegen: true)
private enum FuncPriorityTest: Equatable {
    @token("fast")
    case fast

    @token("fast", priority: 10)
    case faaaast
}

extension `State Based Tokenizer Tests` {
    @Test
    func `priority test`() {
        let actual = Array(FuncPriorityTest.lexer(source: "fast"))
        #expect(actual == [.success(.faaaast)])
    }
}
