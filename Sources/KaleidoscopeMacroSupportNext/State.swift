public struct State: Hashable, Sendable, Comparable, Strideable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public let id: Int

    init(_ id: Int) {
        self.id = id
    }

    public init(integerLiteral value: Int) {
        id = value
    }

    public static func < (lhs: State, rhs: State) -> Bool {
        lhs.id < rhs.id
    }

    public func distance(to other: State) -> Int {
        other.id - id
    }

    public func advanced(by n: Int) -> State {
        State(id + n)
    }
}
