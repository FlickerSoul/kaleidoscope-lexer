//
//  Benchmark.swift
//  Kaleidoscope
//
//  Created by Larry Zeng on 1/13/26.
//
import Benchmark

// Custom metric to track bytes per iteration (multiply by throughput for bytes/sec)
extension BenchmarkMetric {
    static let bytesPerIteration: Self = .custom("Bytes", polarity: .prefersLarger, useScalingFactor: true)
}

let benchmarks = { @Sendable in
    Benchmark.defaultConfiguration = .init(
        metrics: [
            .wallClock,
            .cpuTotal,
            .throughput,
            .mallocCountTotal,
            .bytesPerIteration,
        ],
        warmupIterations: 100,
        scalingFactor: .kilo,
        maxDuration: .seconds(5),
        maxIterations: 1_000_000,
    )

    for (name, benchSource) in benchmarkStrings {
        let byteCount = benchSource.utf8.count
        Benchmark("Parsing \(name) Speed") { benchmark in
            benchmark.measurement(.bytesPerIteration, byteCount)
            for _ in benchmark.scaledIterations {
                blackHole(BenchmarkTestType.lexer(source: benchSource).map { try! $0.get() })
            }
        }
    }
}
