//
//  LexerMachine.swift
//
//
//  Created by Larry Zeng on 12/4/23.
//
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
    public mutating func next() -> Result<Token, Token.LexerError>? {
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

    public mutating func next() -> (Result<Token, Token.LexerError>, Span)? {
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
    func read(offset: Int) -> UInt8? {
        source.read(offset: offset)
    }

    @inlinable
    mutating func trivia() {
        tokenStart = tokenEnd
    }

    @inlinable
    mutating func endToBoundary(offset: Int) {
        tokenEnd = source.findBoundary(index: offset)
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
