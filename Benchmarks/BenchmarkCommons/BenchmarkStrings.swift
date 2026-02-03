///
///  BenchmarkStrings.swift
///  Kaleidoscope
///
///  Created by Larry Zeng on 1/13/26.
///
private let FUNCTIONS = """
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
foobar(protected primitive private instanceof in) { + ++ = == === => }
"""

private let FUNCTION_TOKENS: [BenchmarkTestType] = (0 ..< 30).flatMap { _ in
    [
        .identifier, .parenOpen, .protected, .primitive, .private,
        .instanceOf, .in, .parenClose,
        .braceOpen,
        .opAddition, .opIncrement, .opAssign, .opEquality,
        .opStrictEquality, .fatArrow,
        .braceClose,
    ]
}

private let IDENTIFIERS = """
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton \
It was the year when they finally immanentized the Eschaton
"""

private let IDENTIFIER_TOKENS: [BenchmarkTestType] = (0 ..< 13).flatMap { _ in
    [BenchmarkTestType](repeating: .identifier, count: 10)
}

private let STRINGS =
    #""tree" "to" "a" "graph" "that can" "more adequately represent" "loops and arbitrary state jumps" "with\"\"\"out" "the\n\n\n\n\n" "expl\"\"\"osive" "nature\"""of trying to build up all possible permutations in a tree." "tree" "to" "a" "graph" "that can" "more adequately represent" "loops and arbitrary state jumps" "with\"\"\"out" "the\n\n\n\n\n" "expl\"\"\"osive" "nature\"""of trying to build up all possible permutations in a tree." "tree" "to" "a" "graph" "that can" "more adequately represent" "loops and arbitrary state jumps" "with\"\"\"out" "the\n\n\n\n\n" "expl\"\"\"osive" "nature\"""of trying to build up all possible permutations in a tree." "tree" "to" "a" "graph" "that can" "more adequately represent" "loops and arbitrary state jumps" "with\"\"\"out" "the\n\n\n\n\n" "expl\"\"\"osive" "nature\"""of trying to build up all possible permutations in a tree.""#

private let STRING_TOKENS: [BenchmarkTestType] = (0 ..< 12 * 4).map { _ in .string }

public let benchmarkStrings = [
    "functions": FUNCTIONS,
    "identifiers": IDENTIFIERS,
    "string literals": STRINGS,
]

public let benchmarkTokens = [
    "functions": FUNCTION_TOKENS,
    "identifiers": IDENTIFIER_TOKENS,
    "string literals": STRING_TOKENS,
]
