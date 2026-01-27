public protocol LexerSource {
    associatedtype Slice
    typealias Chunk = ArraySlice<UInt8>

    var byteCount: Int { get }

    func read(offset: Int, length: Int) -> Chunk?
    func read(offset: Int) -> UInt8?
    func slice(range: Range<Int>) -> Slice?
    func slice(unchecked: Void, range: Range<Int>) -> Slice

    func findBoundary(index: Int) -> Int
    func isBoundary(index: Int) -> Bool
}

extension [UInt8]: LexerSource {
    public typealias Slice = ArraySlice<UInt8>

    public var byteCount: Int {
        count
    }

    public func read(offset: Int, length: Int) -> Chunk? {
        guard offset >= 0, length >= 0, offset + length <= count else {
            return nil
        }
        return self[offset ..< offset + length]
    }

    public func read(offset: Int) -> UInt8? {
        guard offset >= 0, offset < count else {
            return nil
        }
        return self[offset]
    }

    public func findBoundary(index: Int) -> Int {
        index
    }

    public func isBoundary(index: Int) -> Bool {
        index <= count
    }

    public func slice(range: Range<Int>) -> Slice? {
        guard range.startIndex >= 0,
              range.endIndex <= count,
              range.startIndex <= range.endIndex else {
            return nil
        }
        return self[range]
    }

    public func slice(unchecked _: Void, range: Range<Int>) -> Slice {
        assert(
            range.startIndex >= 0 && range.endIndex <= count,
            "out of bounds slice: \(range) not bounded by \(count)",
        )
        return self[range]
    }
}

extension String: LexerSource {
    public typealias Slice = String.SubSequence

    public var byteCount: Int {
        utf8.count
    }

    public func slice(range: Range<Int>) -> SubSequence? {
        let slice = utf8[integerRange: range]
        return slice.map(Slice.init)
    }

    // - Complexity: O(1)
    public func slice(unchecked _: Void, range: Range<Int>) -> SubSequence {
        assert(
            range.startIndex <= byteCount && range.endIndex <= byteCount,
            "out of bounds slice: \(range) not bounded by \(byteCount)",
        )
        let slice = utf8[unchecked: (), integerRange: range]
        return Slice(slice)
    }

    public func read(offset: Int, length: Int) -> Chunk? {
        utf8[integerRange: offset ..< offset + length]?.map(\.self)[0 ..< length]
    }

    public func read(offset: Int) -> UInt8? {
        let utf8View = utf8
        let index = utf8View.index(utf8.startIndex, offsetBy: offset)
        guard index < utf8View.endIndex else {
            return nil
        }
        return utf8View[index]
    }

    public func findBoundary(index: Int) -> Int {
        let utf8View = utf8
        var index = utf8View.index(utf8View.startIndex, offsetBy: index)

        while index < utf8View.endIndex {
            // Try to convert the UTF8 index to a character-aligned String.Index
            if let stringIndex = String.Index(index, within: self) {
                // This index is valid—convert back to UTF8View.Index
                let bounaryIndex = stringIndex.samePosition(in: utf8View)!
                return utf8View.distance(from: utf8View.startIndex, to: bounaryIndex)
            }
            // Index is mid-character; skip to next byte
            utf8View.formIndex(after: &index)
        }

        return utf8View.count
    }

    public func isBoundary(index: Int) -> Bool {
        let utf8View = utf8
        let utf8Index = utf8View.index(utf8View.startIndex, offsetBy: index)
        guard utf8Index < utf8View.endIndex else { return index == utf8View.count }

        let byte = utf8View[utf8Index]
        return (byte & 0xC0) != 0x80 // byte < 0x80 || byte >= 0xC0
    }
}

extension String.UTF8View {
    subscript(unchecked _: Void, integerRange range: Range<Int>) -> String.UTF8View.SubSequence {
        let left = index(startIndex, offsetBy: range.lowerBound)
        let right = index(startIndex, offsetBy: range.upperBound)
        return self[left ..< right]
    }

    subscript(integerRange range: Range<Int>) -> String.UTF8View.SubSequence? {
        let left = index(startIndex, offsetBy: range.lowerBound)
        let right = index(startIndex, offsetBy: range.upperBound)
        guard left <= right, right <= endIndex else {
            return nil
        }

        return self[left ..< right]
    }
}
