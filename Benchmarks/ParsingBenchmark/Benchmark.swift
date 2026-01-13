//
//  Benchmark.swift
//  Kaleidoscope
//
//  Created by Larry Zeng on 1/13/26.
//
import Benchmark

let benchmarks = { @Sendable in
    Benchmark.defaultConfiguration = .init(
        metrics: [
            .wallClock,
            .cpuTotal,
            .throughput,
            .mallocCountTotal,
        ],
        warmupIterations: 100,
        scalingFactor: .kilo,
        maxDuration: .seconds(5),
        maxIterations: 1_000_000,
    )
    
    for (name, benchSource) in benchmarkStrings {
        Benchmark("Parsing \(name) Speed") { benchmark in
            for _ in benchmark.scaledIterations {
                blackHole(BenchmarkTestType.lexer(source: benchSource).map { try! $0.get() })
            }
        }
    }
}
