//
//  Benchmark.swift
//  Kaleidoscope
//
//  Created by Larry Zeng on 1/13/26.
//
import Benchmark
import BenchmarkCommons

/// Custom metric to track bytes per iteration (multiply by throughput for bytes/sec)
extension BenchmarkMetric {
    static let bytesThroughput: Self = .custom(
        "Bytes Throughput (MB/s)",
        polarity: .prefersLarger,
        useScalingFactor: true,
    )
}

let benchmarks = { @Sendable in
    Benchmark.defaultConfiguration = .init(
        metrics: [
            .wallClock,
            .cpuTotal,
            .throughput,
            .mallocCountTotal,
            .bytesThroughput,
        ],
        units: [.bytesThroughput: .count],
        warmupIterations: 100,
        maxDuration: .seconds(5),
        maxIterations: 1_000_000,
    )

    for (name, benchSource) in benchmarkStrings {
        let byteCount = benchSource.utf8.count
        Benchmark("Function-based Parsing `\(name)` Speed") { benchmark in
            let start = BenchmarkClock.now
            for token in BenchmarkFunctionBased.lexer(source: benchSource) {
                try blackHole(token.get())
            }
            let end = BenchmarkClock.now

            benchmark.measurement(
                .bytesThroughput,
                Int(
                    Int64(byteCount) * 1000 // * 10^9 (nanoseconds -> seconds) / 10^6 (bytes -> MB)
                        / start.duration(to: end).nanoseconds(),
                ),
            )
        }
    }

    for (name, benchSource) in benchmarkStrings {
        let byteCount = benchSource.utf8.count
        Benchmark("State-based Parsing `\(name)` Speed") { benchmark in
            let start = BenchmarkClock.now
            for token in BenchmarkStateBased.lexer(source: benchSource) {
                try blackHole(token.get())
            }
            let end = BenchmarkClock.now

            benchmark.measurement(
                .bytesThroughput,
                Int(
                    Int64(byteCount) * 1000 // * 10^9 (nanoseconds -> seconds) / 10^6 (bytes -> MB)
                        / start.duration(to: end).nanoseconds(),
                ),
            )
        }
    }
}
