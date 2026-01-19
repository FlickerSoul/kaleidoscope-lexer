//
//  UTF8Sequences.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//
//  This implements UTF-8 sequence generation for Unicode scalar ranges,
//  similar to Rust's utf8-ranges crate.
//

// MARK: - UTF-8 Byte Range

/// A range of bytes [start, end] inclusive
public struct UTF8ByteRange: Equatable, Sendable {
    public let start: UInt8
    public let end: UInt8

    public init(start: UInt8, end: UInt8) {
        self.start = start
        self.end = end
    }

    public init(_ byte: UInt8) {
        start = byte
        end = byte
    }

    public func matches(_ byte: UInt8) -> Bool {
        byte >= start && byte <= end
    }
}

// MARK: - UTF-8 Sequence

/// A sequence of byte ranges that represents valid UTF-8 encodings
/// for a contiguous range of Unicode scalar values.
///
/// Each byte range in the sequence corresponds to a position in the
/// UTF-8 encoding. For example, a 2-byte UTF-8 sequence has two ranges:
/// one for the first byte and one for the second byte.
public struct UTF8Sequence: Equatable, Sendable {
    public private(set) var ranges: [UTF8ByteRange]

    public init(ranges: [UTF8ByteRange]) {
        self.ranges = ranges
    }

    public var length: Int {
        ranges.count
    }

    public func matches(_ bytes: [UInt8]) -> Bool {
        if bytes.count < ranges.count {
            return false
        }

        for (byte, range) in zip(bytes, ranges) where !range.matches(byte) {
            return false
        }

        return true
    }

    /// Reverses the ranges in this sequence.
    ///
    /// For example, if this corresponds to the following sequence:
    /// `[D0-D3][80-BF]`
    /// Then after reversal, it will be:
    /// `[80-BF][D0-D3]`
    ///
    /// This is useful when constructing a UTF-8 automaton to match
    /// character classes in reverse.
    public mutating func reverse() {
        ranges.reverse()
    }

    /// Returns a new sequence with the ranges reversed.
    public func reversed() -> UTF8Sequence {
        UTF8Sequence(ranges: ranges.reversed())
    }
}

// MARK: - Scalar Range (internal helper)

/// A range of scalar values for processing.
private struct ScalarRange {
    var start: UInt32
    var end: UInt32

    /// Returns true if start <= end
    var isValid: Bool { start <= end }

    /// Splits this range if it overlaps with surrogate codepoints (0xD800-0xDFFF).
    /// Returns nil if no split is needed.
    func split() -> (ScalarRange, ScalarRange)? {
        if start < 0xE000, end > 0xD7FF {
            return (
                ScalarRange(start: start, end: 0xD7FF),
                ScalarRange(start: 0xE000, end: end),
            )
        }
        return nil
    }

    /// Returns this range as an ASCII UTF8Range if all scalars fit in a single byte.
    func asAscii() -> UTF8ByteRange? {
        guard isValid, end <= 0x7F else { return nil }
        return UTF8ByteRange(start: UInt8(start), end: UInt8(end))
    }

    /// Encodes the start and end scalars as UTF-8 and returns the byte arrays.
    func encode() -> ([UInt8], [UInt8]) {
        (encodeUTF8(start), encodeUTF8(end))
    }
}

/// Encodes a scalar as UTF-8 bytes.
private func encodeUTF8(_ scalar: UInt32) -> [UInt8] {
    if scalar <= 0x7F {
        [UInt8(scalar)]
    } else if scalar <= 0x7FF {
        [
            UInt8(0xC0 | (scalar >> 6)),
            UInt8(0x80 | (scalar & 0x3F)),
        ]
    } else if scalar <= 0xFFFF {
        [
            UInt8(0xE0 | (scalar >> 12)),
            UInt8(0x80 | ((scalar >> 6) & 0x3F)),
            UInt8(0x80 | (scalar & 0x3F)),
        ]
    } else {
        [
            UInt8(0xF0 | (scalar >> 18)),
            UInt8(0x80 | ((scalar >> 12) & 0x3F)),
            UInt8(0x80 | ((scalar >> 6) & 0x3F)),
            UInt8(0x80 | (scalar & 0x3F)),
        ]
    }
}

/// Returns the maximum scalar value for a given UTF-8 byte length.
private func maxScalarValue(nbytes: Int) -> UInt32 {
    switch nbytes {
    case 1: 0x007F
    case 2: 0x07FF
    case 3: 0xFFFF
    case 4: 0x0010_FFFF
    default: fatalError("Invalid UTF-8 byte sequence size.This shouldn't be reachable.")
    }
}

private let MAX_UTF8_BYTES = 4

// MARK: - UTF-8 Sequences Iterator

/// Generates all UTF-8 byte sequences that can match a range of Unicode scalars.
///
/// Given a start and end Unicode scalar, this generates a series of `UTF8Sequence`
/// values that, when combined, match exactly the UTF-8 encodings of all scalars
/// in the range [start, end].
///
/// This implementation follows the algorithm from Rust's regex-syntax crate,
/// which properly handles:
/// - Surrogate codepoint exclusion (0xD800-0xDFFF)
/// - UTF-8 byte length boundaries
/// - Byte alignment for valid ranges
///
/// For example, the range 'a'...'é' (U+0061...U+00E9) generates:
/// - `[0x61-0x7F]` for ASCII characters 'a' through DEL
/// - `[0xC2][0x80-0xBF]` for U+0080...U+00BF
/// - `[0xC3][0x80-0xA9]` for U+00C0...U+00E9
public struct UTF8Sequences: Sequence, IteratorProtocol {
    private var rangeStack: [ScalarRange]

    public init(start: Unicode.Scalar, end: Unicode.Scalar) {
        rangeStack = [ScalarRange(start: start.value, end: end.value)]
    }

    public mutating func next() -> UTF8Sequence? {
        while let popedRange = rangeStack.popLast() {
            var range = popedRange

            innerLoop: while true {
                // Split if the range overlaps with surrogate codepoints
                if let (lhs, rhs) = range.split() {
                    rangeStack.append(rhs)
                    range = lhs
                    continue innerLoop
                }

                // Skip invalid ranges
                guard range.isValid else {
                    break innerLoop
                }

                // Split at UTF-8 byte length boundaries
                for i in 1 ..< MAX_UTF8_BYTES {
                    let max = maxScalarValue(nbytes: i)
                    if range.start <= max, max < range.end {
                        rangeStack.append(ScalarRange(start: max + 1, end: range.end))
                        range.end = max
                        continue innerLoop
                    }
                }

                // Handle ASCII range
                if let asciiRange = range.asAscii() {
                    return UTF8Sequence(ranges: [asciiRange])
                }

                // Split based on byte alignment
                // This ensures we generate proper byte ranges
                for i in 1 ..< MAX_UTF8_BYTES {
                    let mask: UInt32 = (1 << (6 * i)) - 1
                    if (range.start & ~mask) != (range.end & ~mask) {
                        if (range.start & mask) != 0 {
                            rangeStack.append(ScalarRange(start: (range.start | mask) + 1, end: range.end))
                            range.end = range.start | mask
                            continue innerLoop
                        }
                        if (range.end & mask) != mask {
                            rangeStack.append(ScalarRange(start: range.end & ~mask, end: range.end))
                            range.end = (range.end & ~mask) - 1
                            continue innerLoop
                        }
                    }
                }

                // Now we can encode the range directly
                let (startBytes, endBytes) = range.encode()
                assert(startBytes.count == endBytes.count, "UTF-8 byte lengths must match")

                let ranges = zip(startBytes, endBytes).map { start, end in
                    UTF8ByteRange(start: start, end: end)
                }

                return UTF8Sequence(ranges: ranges)
            }
        }

        return nil
    }
}

// MARK: - Convenience Extensions

public extension UTF8Sequences {
    /// Creates sequences for a single character
    init(character: Character) {
        if let scalar = character.unicodeScalars.first {
            self.init(start: scalar, end: scalar)
        } else {
            // Empty character - will produce no sequences
            self.init(start: Unicode.Scalar(0), end: Unicode.Scalar(0))
        }
    }

    /// Creates sequences for a character range
    init(range: ClosedRange<Character>) {
        if let startScalar = range.lowerBound.unicodeScalars.first,
           let endScalar = range.upperBound.unicodeScalars.first {
            self.init(start: startScalar, end: endScalar)
        } else {
            self.init(start: Unicode.Scalar(0), end: Unicode.Scalar(0))
        }
    }
}
