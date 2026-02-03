// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import class Foundation.ProcessInfo
import PackageDescription

private let enableBenchmark = ProcessInfo.processInfo.environment["ENABLE_BENCHMARK"]

let package = Package(
    name: "kaleidoscope-lexer",
    platforms: [.macOS(.v26), .iOS(.v26), .tvOS(.v26), .watchOS(.v26), .macCatalyst(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KaleidoscopeLexer",
            targets: ["KaleidoscopeLexer"],
        ),
    ],
    traits: [
        .trait(name: "StateMachineCodegen"),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.5"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/stackotter/swift-macro-toolkit.git", from: "0.8.0"),
        .package(
            url: "https://github.com/swiftlang/swift-experimental-string-processing",
            revision: "swift-6.1.1-RELEASE",
        ),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.4"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.12.0"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.7.2"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.3.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "KaleidoscopeMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
                "KaleidoscopeMacroSupportNext",
                "RegexSupport",
            ],
        ),
        .target(
            name: "KaleidoscopeLexer",
            dependencies: [
                "KaleidoscopeMacros",
            ],
        ),
        .target(
            name: "RegexSupport",
            dependencies: [
                "GraphExportSupport",
                .product(name: "_RegexParser", package: "swift-experimental-string-processing"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ],
        ),
        .target(
            name: "KaleidoscopeMacroSupportNext",
            dependencies: [
                "GraphExportSupport",
                "RegexSupport",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ],
        ),
        .target(name: "GraphExportSupport"),
        // tests
        .target(
            name: "TestUtils",
            dependencies: [
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ],
            path: "Tests/TestUtils",
        ),
        .testTarget(
            name: "KaleidoscopeMacroTests",
            dependencies: [
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                "KaleidoscopeMacros",
                "KaleidoscopeMacroSupportNext",
                "RegexSupport",
            ],
        ),
        .testTarget(
            name: "KaleidoscopeTests",
            dependencies: [
                "KaleidoscopeLexer",
                "KaleidoscopeMacroSupportNext",
                "RegexSupport",
            ],
        ),
        .testTarget(
            name: "KaleidoscopeMacroSupportNextTests",
            dependencies: [
                "KaleidoscopeMacroSupportNext",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "TestUtils",
            ],
            exclude: ["__Snapshots__"],
        ),
        .testTarget(
            name: "RegexSupportTests",
            dependencies: [
                "RegexSupport",
                "TestUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
        ),
        // example
        .executableTarget(name: "KaleidoscopeClient", dependencies: ["KaleidoscopeLexer"]),
        // benchmark support
        .target(
            name: "BenchmarkCommons",
            dependencies: [
                "KaleidoscopeLexer",
            ],
            path: "Benchmarks/BenchmarkCommons",
        ),
        .testTarget(
            name: "BenchmarkTests",
            dependencies: [
                "BenchmarkCommons",
                "RegexSupport",
                "KaleidoscopeMacroSupportNext",
            ],
            path: "Benchmarks/BenchmarkTests",
        ),
    ],
    swiftLanguageModes: [.v6],
)

// benchmarks

if enableBenchmark == "1" || enableBenchmark == "true" {
    package.dependencies.append(
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.29.10"),
    )
    package.targets.append(
        contentsOf: [
            .executableTarget(
                name: "ParsingBenchmark",
                dependencies: [
                    "BenchmarkCommons",
                    .product(name: "Benchmark", package: "package-benchmark"),
                    .product(name: "BenchmarkPlugin", package: "package-benchmark"),
                ],
                path: "Benchmarks/ParsingBenchmark",
            ),
        ],
    )
}
