import BenchmarkCommons
import Testing

@Test(arguments: benchmarkStrings.keys)
func `successful parsing function-based benchmark strings`(name: String) throws {
    let testString = try #require(benchmarkStrings[name])
    let lexer = BenchmarkFunctionBased.lexer(source: testString)
    let tokens = try lexer.map { try $0.get() }
    let expected = try #require(functionBasedBenchmarkTokens[name])

    #expect(tokens == expected)
}

@Test(arguments: benchmarkStrings.keys)
func `successful parsing state-based benchmark strings`(name: String) throws {
    let testString = try #require(benchmarkStrings[name])
    let lexer = BenchmarkStateBased.lexer(source: testString)
    let tokens = try lexer.map { try $0.get() }
    let expected = try #require(stateBasedBenchmarkTokens[name])

    #expect(tokens == expected)
}
