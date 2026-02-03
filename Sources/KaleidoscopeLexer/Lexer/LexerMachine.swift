///
///  LexerMachine.swift
///
///
///  Created by Larry Zeng on 12/4/23.
///
public struct LexerMachine<Token: LexerTokenProtocol>: ~Copyable {
    public typealias Output = Result<Token, Token.LexerError>
    public typealias Span = Range<Int>

    @usableFromInline
    let source: Token.Source
    @usableFromInline
    private(set) var tokenStart: Int
    @usableFromInline
    private(set) var tokenEnd: Int

    @inlinable
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
    public var span: Span {
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
}

public extension LexerMachine {
    mutating func next() -> Output? {
        tokenStart = tokenEnd
        return Token.lex(&self)
    }
}

public extension LexerMachine {
    @inlinable
    func read<let length: Int>( // swiftformat:disable:this spaceAroundOperators
        offset: Int,
    ) -> InlineArray<length, UInt8>? {
        source.read(offset: offset)
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
