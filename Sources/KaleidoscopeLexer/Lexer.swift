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

public protocol Into<IntoType> {
    associatedtype IntoType

    func into() -> IntoType
}

public protocol LexerProtocol {
    associatedtype TokenType: LexerProtocol
    associatedtype RawSource: BidirectionalCollection & Into<Source>

    typealias Source = [UInt32]
    typealias Slice = Source.SubSequence
    typealias TokenStream = [TokenType]

    static func lex(_ lexer: inout LexerMachine<Self>) throws
    static func lexer(source: RawSource) -> LexerMachine<Self>
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
    let rawSource: Token.RawSource
    @usableFromInline
    let source: Token.Source
    @usableFromInline
    var token: TokenResult<Token>?
    @usableFromInline
    var tokenStart: Int
    @usableFromInline
    var tokenEnd: Int
    @usableFromInline
    var failed: Bool

    public init(raw: Token.RawSource, token: TokenResult<Token>? = nil, tokenStart: Int = 0, tokenEnd: Int = 0) {
        rawSource = raw
        source = raw.into()
        self.token = token
        self.tokenStart = tokenStart
        self.tokenEnd = tokenEnd
        failed = false
    }

    @inlinable
    public var boundary: Int {
        source.count
    }

    @inlinable
    public var span: Range<Int> {
        tokenStart ..< tokenEnd
    }

    @inlinable
    public var rawSlice: Token.RawSource.SubSequence {
        let start = rawSource.startIndex
        let range = rawSource.index(start, offsetBy: tokenStart) ..< rawSource.index(start, offsetBy: tokenEnd)
        return rawSource[range]
    }

    @inlinable
    public var rawRemainder: Token.RawSource.SubSequence {
        let start = rawSource.startIndex
        let range = rawSource.index(start, offsetBy: tokenEnd) ..< rawSource.index(start, offsetBy: boundary)

        return rawSource[range]
    }

    @inlinable
    public mutating func bump(by count: Int) throws {
        tokenEnd += count
        if tokenEnd > boundary {
            throw LexerError.sourceBoundExceeded
        }
    }

    @inlinable
    public mutating func bump() throws {
        try bump(by: 1)
    }

    @inlinable
    public mutating func reset() {
        tokenStart = tokenEnd
    }

    @inlinable
    mutating func take() throws -> TokenResult<Token> {
        switch token {
        case .none:
            throw LexerError.emptyToken
        case let .some(result):
            token = nil
            return result
        }
    }

    @inlinable
    public var spanned: SpannedLexerIter<Token> {
        .init(lexer: self)
    }

    @inlinable
    public var sliced: SlicedLexerIter<Token> {
        .init(lexer: self)
    }

    @inlinable
    public var spannedAndSliced: SpannedSlicedLexerIter<Token> {
        .init(lexer: self)
    }

    @inlinable
    public mutating func setToken(_ token: any Into<TokenResult<Token>>) throws {
        guard self.token == nil || self.token?.isSkip == true else {
            throw LexerError.duplicatedToken
        }
        self.token = token.into()
    }

    @inlinable
    public mutating func error() throws {
        throw LexerError.notMatch
    }

    @inlinable
    public mutating func skip() throws {
        if tokenStart == tokenEnd {
            tokenEnd += 1
            tokenStart = tokenEnd
        } else {
            reset()
        }

        token = .skipped

        if tokenEnd < boundary {
            try Token.lex(&self)
        }
    }

    public func toArray() -> [Result<Token, Error>] {
        Array(self)
    }

    public func toUnwrappedArray() throws -> [Token] {
        try map { try $0.get() }
    }
}

extension LexerMachine: Sequence, IteratorProtocol {
    public mutating func next() -> Result<Token, Error>? {
        tokenStart = tokenEnd

        if tokenEnd == boundary || failed {
            return nil
        }

        do {
            try Token.lex(&self)
            switch try take() {
            case let .result(token):
                return .success(token)
            case .skipped:
                return next()
            }
        } catch {
            failed = true
            return .failure(error)
        }
    }
}

public struct SpannedLexerIter<Token: LexerProtocol>: Sequence, IteratorProtocol {
    var lexer: LexerMachine<Token>

    @usableFromInline
    init(lexer: LexerMachine<Token>) {
        self.lexer = lexer
    }

    public mutating func next() -> (Result<Token, Error>, Range<Int>)? {
        if let token = lexer.next() {
            (token, lexer.span)
        } else {
            nil
        }
    }
}

public struct SlicedLexerIter<Token: LexerProtocol>: Sequence, IteratorProtocol {
    public typealias Element = (Result<Token, Error>, Token.RawSource.SubSequence)

    var lexer: LexerMachine<Token>

    @usableFromInline
    init(lexer: LexerMachine<Token>) {
        self.lexer = lexer
    }

    public mutating func next() -> Element? {
        if let token = lexer.next() {
            (token, lexer.rawSlice)
        } else {
            nil
        }
    }
}

public struct SpannedSlicedLexerIter<Token: LexerProtocol>: Sequence, IteratorProtocol {
    public typealias Element = (Result<Token, Error>, Range<Int>, Token.RawSource.SubSequence)

    var lexer: LexerMachine<Token>

    @usableFromInline
    init(lexer: LexerMachine<Token>) {
        self.lexer = lexer
    }

    public mutating func next() -> Element? {
        if let token = lexer.next() {
            (token, lexer.span, lexer.rawSlice)
        } else {
            nil
        }
    }
}

public extension LexerMachine {
    @inlinable
    func peak() -> Token.Source.Element? {
        peak(at: tokenEnd)
    }

    @inlinable
    func peak(at index: Int) -> Token.Source.Element? {
        if index >= boundary {
            return nil
        }

        return source[index]
    }

    @inlinable
    func peak(for len: Int) -> Token.Source.SubSequence? {
        peak(at: tokenEnd, for: len)
    }

    @inlinable
    func peak(at index: Int, for len: Int) -> Token.Source.SubSequence? {
        peak(from: index, to: index + len)
    }

    @inlinable
    func peak(from start: Int, to end: Int) -> Token.Source.SubSequence? {
        if end > boundary {
            return nil
        }

        return source[start ..< end]
    }
}
