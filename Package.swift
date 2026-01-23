// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

import class Foundation.ProcessInfo

private let enableBenchmark = ProcessInfo.processInfo.environment["ENABLE_BENCHMARK"]

let package = Package(
    name: "kaleidoscope-lexer",
    platforms: [.macOS(.v13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Kaleidoscope",
            targets: ["Kaleidoscope"],
        ),
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
                "KaleidoscopeLexer",
                "KaleidoscopeMacroSupport",
            ],
        ),
        .target(name: "KaleidoscopeLexer"),
        .target(
            name: "Kaleidoscope",
            dependencies: [
                "KaleidoscopeMacros",
                "KaleidoscopeLexer",
                "KaleidoscopeMacroSupport",
            ],
        ),
        .target(
            name: "KaleidoscopeMacroSupport",
            dependencies: [
                .product(name: "_RegexParser", package: "swift-experimental-string-processing"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ],
        ),
        .target(
            name: "GraphExportSupport",
            dependencies: [],
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
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "DequeModule", package: "swift-collections"),
            ],
        ),
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
                "KaleidoscopeMacroSupport",
            ],
        ),
        .testTarget(
            name: "KaleidoscopeTests",
            dependencies: [
                "Kaleidoscope",
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
            name: "KaleidoscopeMacroSupportTest",
            dependencies: [
                "KaleidoscopeMacroSupport",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
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
        .executableTarget(name: "KaleidoscopeClient", dependencies: ["Kaleidoscope"]),
    ],
    swiftLanguageModes: [.v6],
)

// benchmarks

if enableBenchmark == "1" || enableBenchmark == "true" {
    package.dependencies.append(
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.29.7"))
    package.targets.append(
        .executableTarget(
            name: "ParsingBenchmark",
            dependencies: [
                "Kaleidoscope",
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "BenchmarkPlugin", package: "package-benchmark"),
            ],
            path: "Benchmarks/ParsingBenchmark",
        ),
    )
}
