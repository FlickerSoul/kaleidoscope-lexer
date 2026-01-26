//
//  Lexer.swift
//
//
//  Created by Larry Zeng on 12/4/23.
//

public enum LexerError: Error {
    case sourceBoundExceeded
    case emptyToken
    case duplicatedToken
    case notMatch
}

public protocol LexerProtocol {
    associatedtype TokenType: LexerProtocol
    associatedtype Source: LexerSource

    typealias TokenStream = [TokenType]

    // TODO: allow user to customize Error type
    typealias Error = Swift.Error

    static func lex(_ lexer: inout LexerMachine<Self>) -> Result<Self, Self.Error>?
    static func lexer(source: Source) -> LexerMachine<Self>
}

public enum TokenResult<Token: LexerProtocol> {
    public typealias IntoType = Self

    case result(Token)
    case skipped

    public var isSkip: Bool {
        switch self {
        case .skipped: true
        default: false
        }
    }
}

extension TokenResult: Equatable where Token: Equatable {}

extension TokenResult: Into {
    public func into() -> TokenResult<Token> {
        self
    }
}

public struct LexerMachine<Token: LexerProtocol> {
    @usableFromInline
    let source: Token.Source
    @usableFromInline
    var tokenStart: Int
    @usableFromInline
    var tokenEnd: Int

    public init(source: Token.Source, tokenStart: Int = 0, tokenEnd: Int = 0) {
        self.source = source
        self.tokenStart = tokenStart
        self.tokenEnd = tokenEnd
    }

    @inlinable
    public var boundary: Int {
        source.byteCount
    }

    @inlinable
    public var span: Range<Int> {
        tokenStart ..< tokenEnd
    }

    @inlinable
    public func slice() -> Token.Source.Slice {
        // TODO: forbids unsafe?
        source.slice(unchecked: (), range: span)
    }

    @inlinable
    public func remainder() -> Token.Source.Slice {
        // TODO: forbids unsafe?
        source.slice(unchecked: (), range: tokenEnd ..< boundary)
    }

    @inlinable
    public mutating func bump(by count: Int) {
        tokenEnd += count

        assert(source.isBoundary(index: tokenEnd), "bump to non-boundary index")
    }

    @inlinable
    public var spanned: SpannedLexerIter<Token> {
        .init(lexer: self)
    }
}

extension LexerMachine: Sequence, IteratorProtocol {
    public mutating func next() -> Result<Token, Error>? {
        tokenStart = tokenEnd
        return Token.lex(&self)
    }
}

public struct SpannedLexerIter<Token: LexerProtocol>: Sequence, IteratorProtocol {
    public typealias Span = Range<Int>

    private(set) var lexer: LexerMachine<Token>

    @usableFromInline
    init(lexer: LexerMachine<Token>) {
        self.lexer = lexer
    }

    public mutating func next() -> (Result<Token, Error>, Span)? {
        lexer.next().map { token in
            (token, lexer.span)
        }
    }
}

public extension LexerMachine {
    @inlinable
    func read(offset: Int, length: Int) -> ArraySlice<UInt8>? {
        source.read(offset: offset, length: length)
    }

    @inlinable
    mutating func trivia() {
        tokenStart = tokenEnd
    }

    @inlinable
    func endToBoundary(offset: Int) -> Int {
        source.findBoundary(index: offset)
    }

    @inlinable
    mutating func end(at offset: Int) {
        tokenEnd = offset
    }

    @inlinable
    func offset() -> Int {
        tokenStart
    }
}
