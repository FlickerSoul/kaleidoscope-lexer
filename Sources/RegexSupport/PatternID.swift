public struct PatternID: Hashable, Sendable, ExpressibleByIntegerLiteral, CustomStringConvertible {
    public typealias IntegerLiteralType = UInt32

    public let id: UInt32

    public init(integerLiteral value: UInt32) {
        id = value
    }

    public init(_ id: UInt32) {
        self.id = id
    }

    public var description: String {
        "\(id)"
    }
}
