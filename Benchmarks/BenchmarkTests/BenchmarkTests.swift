import BenchmarkCommons
import Testing

@Test(arguments: benchmarkStrings.keys)
func `successful parsing benchmark strings`(name: String) throws {
    let testString = try #require(benchmarkStrings[name])
    let lexer = BenchmarkTestType.lexer(source: testString)
    for token in lexer {
        _ = try token.get()
    }
}
