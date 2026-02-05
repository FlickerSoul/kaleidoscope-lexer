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

private let STRINGS =
    #""tree" "to" "a" "graph" "that can" "more adequately represent" "loops and arbitrary state jumps" "with\"\"\"out" "the\n\n\n\n\n" "expl\"\"\"osive" "nature\"""of trying to build up all possible permutations in a tree." "tree" "to" "a" "graph" "that can" "more adequately represent" "loops and arbitrary state jumps" "with\"\"\"out" "the\n\n\n\n\n" "expl\"\"\"osive" "nature\"""of trying to build up all possible permutations in a tree." "tree" "to" "a" "graph" "that can" "more adequately represent" "loops and arbitrary state jumps" "with\"\"\"out" "the\n\n\n\n\n" "expl\"\"\"osive" "nature\"""of trying to build up all possible permutations in a tree." "tree" "to" "a" "graph" "that can" "more adequately represent" "loops and arbitrary state jumps" "with\"\"\"out" "the\n\n\n\n\n" "expl\"\"\"osive" "nature\"""of trying to build up all possible permutations in a tree.""#

public let benchmarkStrings = [
    "functions": FUNCTIONS,
    "identifiers": IDENTIFIERS,
    "string literals": STRINGS,
]

public let functionBasedBenchmarkTokens = [
    "functions": (0 ..< 30).flatMap { _ in
        [
            BenchmarkFunctionBased.identifier, .parenOpen, .protected, .primitive, .private,
            .instanceOf, .in, .parenClose,
            .braceOpen,
            .opAddition, .opIncrement, .opAssign, .opEquality,
            .opStrictEquality, .fatArrow,
            .braceClose,
        ]
    },
    "identifiers": (0 ..< 13).flatMap { _ in
        [BenchmarkFunctionBased](repeating: .identifier, count: 10)
    },
    "string literals": (0 ..< 12 * 4).map { _ in BenchmarkFunctionBased.string },
]

public let stateBasedBenchmarkTokens = [
    "functions": (0 ..< 30).flatMap { _ in
        [
            BenchmarkStateBased.identifier, .parenOpen, .protected, .primitive, .private,
            .instanceOf, .in, .parenClose,
            .braceOpen,
            .opAddition, .opIncrement, .opAssign, .opEquality,
            .opStrictEquality, .fatArrow,
            .braceClose,
        ]
    },
    "identifiers": (0 ..< 13).flatMap { _ in
        [BenchmarkStateBased](repeating: .identifier, count: 10)
    },
    "string literals": (0 ..< 12 * 4).map { _ in BenchmarkStateBased.string },
]
