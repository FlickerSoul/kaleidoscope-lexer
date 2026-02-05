# Kaleidoscope

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFlickerSoul%2Fkaleidoscope-lexer%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/FlickerSoul/kaleidoscope-lexer)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFlickerSoul%2Fkaleidoscope-lexer%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/FlickerSoul/kaleidoscope-lexer)

A high-performance lexer generator for Swift, inspired by [logos](https://github.com/maciejhirsz/logos). Kaleidoscope uses Swift macros to generate optimized lexer code at compile time, turning your token definitions into efficient finite automata.

## Features

- **Declarative token definitions** using Swift macros (`@Kaleidoscope`, `@regex`, `@token`, `@skip`)
- **Native Swift regex support** with Swift's `Regex` literals
- **Customizable callbacks** for token transformation and validation
- **Priority-based conflict resolution** for overlapping patterns
- **Skip patterns** for ignoring whitespace, comments, etc.
- **Two codegen strategies**: function-based (default) and state-machine-based
- **Type-safe** with full Swift 6 concurrency support

## Limitations

Kaleidoscope is experimental and has known limitations:

- **Incomplete Regex translation**: Not all regex features from Swift's `Regex` are supported. Complex patterns involving certain lookahead/lookbehind assertions, backreferences, or some character properties may not compile correctly or at all. Should any unsupported regex features be used, the macro will emit a compile-time error indicating the issue. If you'd like to see support for specific regex features, please open an issue or contribute a PR with the necessary NFA/DFA construction logic.
- **Possible state machine bugs**: The macro resolves regex patterns into NFA and DFA representations, but there are edge cases where the generated state machine may not correctly handle certain inputs or patterns, leading to incorrect tokenization or infinite loops. Please always test your lexer.

If you encounter issues, please report them on the [issue tracker](https://github.com/FlickerSoul/kaleidoscope-lexer/issues).

## Installation

Add Kaleidoscope to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/FlickerSoul/kaleidoscope-lexer", from: "0.1.0")
]
```

Then add `KaleidoscopeLexer` to your target's dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "KaleidoscopeLexer", package: "kaleidoscope-lexer")
    ]
)
```

**Requirements:** Swift 6.2+, macOS 26+ / iOS 26+ / tvOS 26+ / watchOS 26+

## Usage

### Basic Example

Define your tokens as an enum decorated with `@Kaleidoscope`:

```swift
import KaleidoscopeLexer

@Kaleidoscope
@skip(/[ \t\n]/)  // Skip whitespace
enum Token: Equatable {
    @token("private")
    case `private`

    @token("public")
    case `public`

    @regex(/[a-zA-Z_][a-zA-Z0-9_]*?/)
    case identifier

    @regex(/[0-9]+?/)
    case number

    @token(".")
    case dot

    @token("(")
    case parenOpen

    @token(")")
    case parenClose
}

// Tokenize a string
let source = "private foo(123)"
for result in Token.lexer(source: source) {
    switch result {
    case .success(let token):
        print(token)
    case .failure(let error):
        print("Error: \(error)")
    }
}
// Output: private, identifier, parenOpen, number, parenClose
```

### Token Definitions

Use `@token` for exact string matching and `@regex` for pattern matching:

```swift
@Kaleidoscope
enum Tokens {
    @token("==")       // Exact match
    case equals

    @token("===")      // Longer match takes precedence
    case strictEquals

    @regex(/[0-9]+?/)  // Regex pattern
    case number
}
```

### Callbacks for Token Transformation

Transform matched text into associated values using callbacks:

```swift
private let parseNumber = { @Sendable (machine: inout LexerMachine<Token>) -> Int in
    Int(machine.slice())!
}
private let printer = { @Sendable (machine: inout LexerMachine<Token>) -> Int in
    print(machine.slice())
}

@Kaleidoscope
@skip(/[ ]/)
enum Token: Equatable {
    @regex(/[0-9]+?/, callback: parseNumber) // Cannot be lined closure due to compiler limitations
    case number(Int)

    @token("hello", callback: printer) // Callback can be used for side effects without returning a value
    case hello
}

// "42 hello 123" produces: number(42), hello, number(123)
```

> Please not that callbacks cannot be inlined closures at the moment due to [Swift compiler limitations](https://github.com/apple/swift/issues/70322).

### Skip Patterns

Use `@skip` to ignore certain patterns (whitespace, comments, etc.):

```swift
@Kaleidoscope
@skip(/[ \t\n]/)              // Skip whitespace (enum-level)
enum Token {
    @regex(/\/\/.*?/)         // Match comments as tokens
    case comment

    @skip("/*...*/")          // Skip block comments (case-level)
    case blockComment

    @token("code")
    case code
}
```

Skip patterns can also have callbacks for side effects:

```swift
private let logSkip = { @Sendable (machine: inout LexerMachine<Token>) -> _SkipResult<Token> in
    print("Skipping: \(machine.slice())")
    return .skip
}

@Kaleidoscope
// @skip with callback could be used here but compiler complains about circular resolutions of types, so it's not possible currently
enum Token {
    @skip("ignore", callback: logSkip)
    case ignored
}
```

> Note that `@skip` macro with callback cannot be used on enum level since compiler complains about circular resolutions of types. You can only use it on case level for now.

### Priority Resolution

When patterns overlap and their implicit priorities (see below) conflict, use `priority` to resolve conflicts (higher priority wins):

```swift
@Kaleidoscope
enum Token {
    @token("fast")
    case fast

    @token("fast", priority: 10)  // Higher priority, this wins
    case faster
}

// "fast" produces: faster
```

#### Priority Calculation

Priorities are calculated in the same way as in logos. The rule of thumb is:

- Longer beats shorter.
- Specific beats generic.

Every consecutive, non-repeating single byte adds 2 to the priority, while every range or regex class adds 1. Loops or optional blocks are ignored, while alternations count the shortest alternative. For example:

- `[a-zA-Z]+` has a priority of 2 (lowest possible), because at minimum it can match a single byte to a class;
- `foobar` has a priority of 12;
- and `(foo|hello)(bar)?` has a priority of 6, foo being its shortest possible match.

### Codegen Strategies

Kaleidoscope supports two code generation strategies:

**Function-based (default):** Generates function calls for each token pattern.

```swift
@Kaleidoscope
enum Token { ... }
```

**State-machine-based:** Generates a state machine for potentially better performance with complex grammars.

```swift
@Kaleidoscope(useStateMachineCodegen: true)
enum Token { ... }
```

You can also enable state-machine codegen globally via the `StateMachineCodegen` package trait.

### Working with the Lexer

The lexer conforms to `Sequence` and `IteratorProtocol`:

```swift
let lexer = Token.lexer(source: "some input")

// Iterate with error handling
for result in lexer {
    switch result {
    case .success(let token):
        process(token)
    case .failure(let error):
        handleError(error)
    }
}

// Collect all tokens (throws on error)
let tokens = try lexer.map { try $0.get() }

// Get tokens with span information
for (result, span) in lexer.makeSpannedIterator() {
    print("Token at \(span): \(result)")
}
```

### Callback Types

```swift
// Standard callback - return value becomes associated value
typealias Callback<T: LexerTokenProtocol, R> = @Sendable (inout LexerMachine<T>) -> R

// Skip callback - can skip or emit error
typealias SkipCallback<T: LexerTokenProtocol, R: _SkipResultSource<T>> = @Sendable (inout LexerMachine<T>) -> R

// Skip result source - used for skip callbacks to determine whether to skip or emit an error
public protocol _SkipResultSource<Token> {
    associatedtype Token: LexerTokenProtocol

    func convert() -> _SkipResult<Token>
}

enum _SkipResult<Token>: _SkipResultSource<Token> {
    case skip
    case error(Token.UserError)
}
```

## Benchmark

To run benchmarks, install `jemalloc` as instructed by [package-benchmark](https://github.com/ordo-one/package-benchmark).

```bash
export ENABLE_BENCHMARK=1
swift package benchmark
```

## Version Stability

Kaleidoscope is under active development. Source stability is only guaranteed within minor versions. For stable dependencies, use:

```swift
.package(url: "...", .upToNextMinorVersion(from: "0.1.0"))
```

Public API consists of non-underscored `public` declarations. Internal interfaces may change in any release.

## Roadmap

- [ ] Formalize callback transformers
- [ ] Add support for more regex features (flags, etc.)

## How It Works

Kaleidoscope converts all regex patterns and token strings into a unified finite automaton at compile time. The automaton processes input one character at a time until it finds a token match or encounters an error. The macro system generates Swift code that implements this automaton, avoiding runtime regex compilation overhead.
