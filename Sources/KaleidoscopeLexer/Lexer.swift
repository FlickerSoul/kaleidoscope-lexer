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

    var isSkip: Bool {
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
    let rawSource: Token.RawSource
    let source: Token.Source
    var token: TokenResult<Token>?
    var tokenStart: Int
    var tokenEnd: Int
    var failed: Bool

    public init(raw: Token.RawSource, token: TokenResult<Token>? = nil, tokenStart: Int = 0, tokenEnd: Int = 0) {
        rawSource = raw
        source = raw.into()
        self.token = token
        self.tokenStart = tokenStart
        self.tokenEnd = tokenEnd
        failed = false
    }

    @inline(__always)
    public var boundary: Int {
        source.count
    }

    @inline(__always)
    public var span: Range<Int> {
        tokenStart ..< tokenEnd
    }

    @inline(__always)
    public var rawSlice: Token.RawSource.SubSequence {
        let start = rawSource.startIndex
        let range = rawSource.index(start, offsetBy: tokenStart) ..< rawSource.index(start, offsetBy: tokenEnd)
        return rawSource[range]
    }

    @inline(__always)
    public var rawRemainder: Token.RawSource.SubSequence {
        let start = rawSource.startIndex
        let range = rawSource.index(start, offsetBy: tokenEnd) ..< rawSource.index(start, offsetBy: boundary)

        return rawSource[range]
    }

    @inline(__always)
    public mutating func bump(by count: Int) throws {
        tokenEnd += count
        if tokenEnd > boundary {
            throw LexerError.sourceBoundExceeded
        }
    }

    @inline(__always)
    public mutating func bump() throws {
        try bump(by: 1)
    }

    @inline(__always)
    public mutating func reset() {
        tokenStart = tokenEnd
    }

    @inline(__always)
    mutating func take() throws -> TokenResult<Token> {
        switch token {
        case .none:
            throw LexerError.emptyToken
        case let .some(result):
            token = nil
            return result
        }
    }

    @inline(__always)
    public var spanned: SpannedLexerIter<Token> {
        .init(lexer: self)
    }

    @inline(__always)
    public var sliced: SlicedLexerIter<Token> {
        .init(lexer: self)
    }

    @inline(__always)
    public var spannedAndSliced: SpannedSlicedLexerIter<Token> {
        .init(lexer: self)
    }

    @inline(__always)
    public mutating func setToken(_ token: any Into<TokenResult<Token>>) throws {
        guard self.token == nil || self.token?.isSkip == true else {
            throw LexerError.duplicatedToken
        }
        self.token = token.into()
    }

    @inline(__always)
    public mutating func error() throws {
        throw LexerError.notMatch
    }

    @inline(__always)
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

    public mutating func next() -> Element? {
        if let token = lexer.next() {
            (token, lexer.span, lexer.rawSlice)
        } else {
            nil
        }
    }
}

public extension LexerMachine {
    @inline(__always)
    func peak() -> Token.Source.Element? {
        peak(at: tokenEnd)
    }

    @inline(__always)
    func peak(at index: Int) -> Token.Source.Element? {
        if index >= boundary {
            return nil
        }

        return source[index]
    }

    @inline(__always)
    func peak(for len: Int) -> Token.Source.SubSequence? {
        peak(at: tokenEnd, for: len)
    }

    @inline(__always)
    func peak(at index: Int, for len: Int) -> Token.Source.SubSequence? {
        peak(from: index, to: index + len)
    }

    @inline(__always)
    func peak(from start: Int, to end: Int) -> Token.Source.SubSequence? {
        if end > boundary {
            return nil
        }

        return source[start ..< end]
    }
}
