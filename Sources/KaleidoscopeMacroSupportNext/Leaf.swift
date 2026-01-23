import RegexSupport
import SwiftSyntax

public enum PatternKind: Hashable, Sendable {
    case regex(String)
    case token(String)
}

public struct Pattern: Hashable, Sendable {
    public typealias HIR = RegexSupport.HIRKind
    public let source: PatternKind
    public let sourceLocation: SourceLocation
    public let hir: HIR
}

public enum LeafKind: Hashable, Sendable {
    case caseOnly(caseName: TokenSyntax)
    case associatedValues(caseName: TokenSyntax, parameters: EnumCaseParameterClauseSyntax)
    case skip
}

public enum CallbackKind: Hashable, Sendable {
    case named(callbackName: ExprSyntax)
    case lambda(closure: ClosureExprSyntax)
}

public struct Leaf: Hashable, Sendable {
    public let pattern: Pattern
    public let priority: UInt
    public let kind: LeafKind
    public let callback: CallbackKind?
}

public struct LeafID: Hashable, Sendable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public let id: IntegerLiteralType

    public init(integerLiteral value: IntegerLiteralType) {
        id = value
    }

    init(_ id: IntegerLiteralType) {
        self.id = id
    }
}
