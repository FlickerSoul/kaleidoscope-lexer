import BenchmarkCommons
import Testing

@Test(arguments: benchmarkStrings.keys)
func `successful parsing benchmark strings`(name: String) throws {
    let testString = try #require(benchmarkStrings[name])
    let lexer = BenchmarkTestType.lexer(source: testString)
    let tokens = try lexer.map { try $0.get() }
    let expected = try #require(benchmarkTokens[name])

    #expect(tokens == expected)
}
