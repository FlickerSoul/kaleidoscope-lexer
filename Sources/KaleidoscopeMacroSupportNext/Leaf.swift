import RegexSupport
import SwiftSyntax

public enum PatternKind: Hashable, Sendable {
    case regex(String)
    case token(String)
}

public struct Pattern: Hashable, Sendable {
    public typealias HIR = RegexSupport.HIRKind
    public let kind: PatternKind
    public let hir: HIR
    public let source: Syntax

    public init(kind: PatternKind, hir: HIR, source: Syntax) {
        self.kind = kind
        self.hir = hir
        self.source = source
    }
}

public enum LeafKind: Hashable, Sendable {
    case caseOnly(caseName: TokenSyntax)
    case associatedValues(caseName: TokenSyntax, parameters: EnumCaseParameterListSyntax)
    case skip
}

public enum CallbackKind: Hashable, Sendable {
    case named(callbackName: ExprSyntax)
    case lambda(closure: ClosureExprSyntax)
}

public struct Leaf: Hashable, Sendable {
    public let pattern: Pattern
    public let priority: Int
    public let kind: LeafKind
    public let callback: CallbackKind?

    public init(
        pattern: Pattern,
        priority: Int,
        kind: LeafKind,
        callback: CallbackKind? = nil,
    ) {
        self.pattern = pattern
        self.priority = priority
        self.kind = kind
        self.callback = callback
    }
}

public struct LeafID: Hashable, Sendable, ExpressibleByIntegerLiteral, Comparable {
    public typealias IntegerLiteralType = Int
    public let id: IntegerLiteralType

    public init(integerLiteral value: IntegerLiteralType) {
        id = value
    }

    init(_ id: IntegerLiteralType) {
        self.id = id
    }

    public static func < (lhs: LeafID, rhs: LeafID) -> Bool {
        lhs.id < rhs.id
    }
}
