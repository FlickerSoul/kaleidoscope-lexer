# Kaleidoscope

This is a lexer for Swift inspired by [logos](https://github.com/maciejhirsz/logos). It utilizes swift macros to generate optimized lexer code in compile time. Please see [install section](#install) for installation instructions.

## Example

```swift
import Kaleidoscope

let lambda: (inout LexerMachine<Tokens>) -> Substring = { $0.slice }

@kaleidoscope(skip: " |\t|\n")
enum Tokens {
    @token("not")
    case Not

    @regex("very")
    case Very

    @token("tokenizer")
    case Tokenizer

    // you could feed a closure directly to `onMatch` but swift doesn't like it for some reason
    // seems to be a compiler bug (https://github.com/apple/swift/issues/70322)
    @regex("[a-zA-Z_][a-zA-Z1-9$_]*?", onMatch: lambda)
    case Identifier(Substring)
}


for token in Tokens.lexer(source: "not a very fast tokenizer").map({ try! $0.get() }) {
    print(token)
}
```

The output will be

```text
Not
Identifier("a")
Very
Identifier("fast")
Tokenizer
```

## Install

You can install Kaleidoscope via Swift Package Manager. Add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/FlickerSoul/kaleidoscope-lexer", from: "0.1.0")
]
```

and add `"Kaleidoscope"` to the dependencies of your target.

```swift
.product(name: "Kaleidoscope", package: "kaleidoscope-lexer")
```

## Project Version

Because the Kaleidoscope library is under active development, source-stability is only guaranteed within minor versions (e.g. between 0.0.3 and 0.0.4). If you don't want potentially source-breaking package updates, you can specify your package dependency using .upToNextMinorVersion(from: "0.0.1") instead.

When the package reaches a 1.0.0 release, the public API of the kaleidoscope-lexer package will consist of non-underscored declarations that are marked public. Interfaces that aren't part of the public API may continue to change in any release, including the package’s examples, tests, utilities, and documentation.

Future minor versions of the package may introduce changes to these rules as needed.

## Idea

The project is provides three macros: `@kaleidoscope`, `regex`, and `token`, and they work together to generate conformance to `LexerProtocol` for the decorated  enums. `regex` takes in a regex expression for matching and `token` takes a string for excat matching. In addition, they can take a `onMatch` callback and a `priority` integer. The callback has access to token string slice and can futher transform it to whatever type required by the enum case. The priority are calculated by from the expression by default. However, if two exprssions have the same weight, manual specification is required to resolve the conflict.

Internally, all regex expressions and token strings are converted into a single finite automata. The finite automata consumes one character from the input at a time, until it reaches an token match or an error. This machanism is simple but works slowly. Future improvements can be established on this issue.

## Roadmap

- [ ] replace string regex argument with builtin swift regex
- [ ] faster tokenization optimization
- [ ] improved interface
