public struct Char: Hashable, Sendable, Comparable, ExpressibleByStringLiteral {
    let scalar: UnicodeScalar

    public init(stringLiteral value: String) {
        precondition(value.count == 1, "Invalid string literal \(value.utf8.count)")
        self = .init(value.first!)
    }

    init(unchecked character: Character) {
        scalar = character.unicodeScalars.first!
    }

    init(_ character: Character) {
        precondition(character.unicodeScalars.count == 1, "Invalid character: \(character.utf8)")
        self = .init(unchecked: character)
    }

    init(_ scalar: UnicodeScalar) {
        self.scalar = scalar
    }

    public static func < (lhs: Char, rhs: Char) -> Bool {
        lhs.scalar.value < rhs.scalar.value
    }

    public var bytes: UnicodeScalar.UTF8View {
        scalar.utf8
    }

    public var asciiValue: UInt8? {
        scalar.isASCII ? UInt8(scalar.value) : nil
    }
}
