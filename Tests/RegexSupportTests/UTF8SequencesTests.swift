//
//  UTF8SequencesTests.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/16/26.
//
@testable import RegexSupport
import Testing

// MARK: - Helper Functions

/// Encodes a surrogate codepoint (0xD800-0xDFFF) as if it were valid UTF-8.
/// This produces invalid UTF-8, which is used to test that sequences
/// correctly reject surrogate codepoints.
private func encodeSurrogate(_ codePoint: UInt32) -> [UInt8] {
    precondition(codePoint >= 0xD800 && codePoint < 0xE000, "Not a surrogate codepoint")
    let tagCont: UInt8 = 0b1000_0000
    let tagThreeB: UInt8 = 0b1110_0000
    return [
        UInt8(codePoint >> 12 & 0x0F) | tagThreeB,
        UInt8(codePoint >> 6 & 0x3F) | tagCont,
        UInt8(codePoint & 0x3F) | tagCont,
    ]
}

/// Tests that no sequence produced for the given range accepts any
/// surrogate codepoint encoding.
private func neverAcceptsSurrogateCodepoints(start: Unicode.Scalar, end: Unicode.Scalar) {
    for codePoint: UInt32 in 0xD800 ..< 0xE000 {
        let buf = encodeSurrogate(codePoint)
        for seq in UTF8Sequences(start: start, end: end) where seq.matches(buf) {
            Issue.record(
                """
                Sequence (\(String(start.value, radix: 16, uppercase: true)), \
                \(String(end.value, radix: 16, uppercase: true))) contains range \(seq), \
                which matches surrogate code point \(String(codePoint, radix: 16, uppercase: true)) \
                with encoded bytes \(buf)
                """,
            )
        }
    }
}

private func matches(seqs: [UTF8Sequence], bytes: [UInt8]) -> Bool {
    for range in seqs where range.matches(bytes) {
        return true
    }
    return false
}

// MARK: - Tests

@Suite("UTF8Sequences Tests")
struct UTF8SequencesTests {
    @Test
    func `ASCII character produces single sequence`() throws {
        let sequences = Array(UTF8Sequences(character: "a"))

        #expect(sequences.count == 1)
        #expect(sequences[0].ranges == [.init(start: 0x61, end: 0x61)])
    }

    @Test
    func `two-byte character produces single sequence`() throws {
        let sequences = Array(UTF8Sequences(character: "é"))

        #expect(sequences.count == 1)
        #expect(
            sequences[0].ranges == [
                .init(start: 0xC3, end: 0xC3),
                .init(start: 0xA9, end: 0xA9),
            ],
        )
    }

    @Test
    func `ASCII range produces single sequence`() throws {
        let sequences = Array(UTF8Sequences(range: "a" ... "z"))

        #expect(sequences.count == 1)
        #expect(sequences[0].ranges == [.init(start: 0x61, end: 0x7A)])
    }

    @Test
    func `range spanning UTF8 lengths produces multiple sequences`() throws {
        // Range from 'a' (U+0061) to 'é' (U+00E9) spans:
        // - ASCII: U+0061 to U+007F (1 byte)
        // - 2-byte: U+0080 to U+00E9
        let sequences = Array(UTF8Sequences(range: "a" ... "é"))

        // Should produce 3 sequences:
        // 1. ASCII part: 0x61-0x7F
        // 2. 2-byte part 1: 0xC2 0x80-0xBF (U+0080 to U+00BF)
        // 3. 2-byte part 2: 0xC3 0x80-0xA9 (U+00C0 to U+00E9)
        #expect(sequences.count == 3)
        #expect(sequences[0].ranges == [.init(start: 0x61, end: 0x7F)])
        #expect(sequences[1].ranges == [.init(start: 0xC2, end: 0xC2), .init(start: 0x80, end: 0xBF)])
        #expect(sequences[2].ranges == [.init(start: 0xC3, end: 0xC3), .init(start: 0x80, end: 0xA9)])
    }

    @Test
    func `full UTF8 range`() throws {
        let sequences = Array(UTF8Sequences(range: "\u{0000}" ... "\u{FFFF}"))

        // UTF-8 encoding of 'a'.
        #expect(matches(seqs: sequences, bytes: [0x61]))
        // UTF-8 encoding of '☃' (`\u{2603}`).
        #expect(matches(seqs: sequences, bytes: [0xE2, 0x98, 0x83]))
        // UTF-8 encoding of `\u{10348}` (outside the BMP).
        #expect(!matches(seqs: sequences, bytes: [0xF0, 0x90, 0x8D, 0x88]))
        // Tries to match against a UTF-8 encoding of a surrogate codepoint,
        // which is invalid UTF-8, and therefore fails, despite the fact that
        // the corresponding codepoint (0xD800) falls in the range given.
        #expect(!matches(seqs: sequences, bytes: [0xED, 0xA0, 0x80]))
        // And fails against plain old invalid UTF-8.
        #expect(!matches(seqs: sequences, bytes: [0xFF, 0xFF]))
    }

    /// Tests that no sequence accepts surrogate codepoints
    @Test
    func `codepoints no surrogates`() throws {
        neverAcceptsSurrogateCodepoints(start: "\u{0}", end: "\u{FFFF}")
        neverAcceptsSurrogateCodepoints(start: "\u{0}", end: "\u{10FFFF}")
        neverAcceptsSurrogateCodepoints(start: "\u{0}", end: "\u{10FFFE}")
        neverAcceptsSurrogateCodepoints(start: "\u{80}", end: "\u{10FFFF}")
        neverAcceptsSurrogateCodepoints(start: "\u{D7FF}", end: "\u{E000}")
    }

    /// Tests that every range of scalar values that contains a single
    /// scalar value is recognized by one sequence of byte ranges.
    @Test
    func `single codepoint one sequence`() throws {
        for i: UInt32 in 0x0 ... 0x0010_FFFF {
            guard let scalar = Unicode.Scalar(i) else { continue }
            let seqs = Array(UTF8Sequences(start: scalar, end: scalar))
            #expect(
                seqs.count == 1,
                "Scalar \(String(i, radix: 16)) should produce exactly 1 sequence, got \(seqs.count)",
            )
        }
    }

    /// Tests the exact sequences produced for the Basic Multilingual Plane (BMP)
    @Test
    func `basic multilingual plane`() throws {
        let seqs = Array(UTF8Sequences(start: "\u{0}", end: "\u{FFFF}"))

        let expected: [UTF8Sequence] = [
            // ASCII: [0x00-0x7F]
            UTF8Sequence(ranges: [UTF8ByteRange(start: 0x0, end: 0x7F)]),
            // 2-byte: [0xC2-0xDF][0x80-0xBF]
            UTF8Sequence(ranges: [UTF8ByteRange(start: 0xC2, end: 0xDF), UTF8ByteRange(start: 0x80, end: 0xBF)]),
            // 3-byte starting with 0xE0: [0xE0][0xA0-0xBF][0x80-0xBF]
            UTF8Sequence(ranges: [
                UTF8ByteRange(start: 0xE0, end: 0xE0),
                UTF8ByteRange(start: 0xA0, end: 0xBF),
                UTF8ByteRange(start: 0x80, end: 0xBF),
            ]),
            // 3-byte: [0xE1-0xEC][0x80-0xBF][0x80-0xBF]
            UTF8Sequence(ranges: [
                UTF8ByteRange(start: 0xE1, end: 0xEC),
                UTF8ByteRange(start: 0x80, end: 0xBF),
                UTF8ByteRange(start: 0x80, end: 0xBF),
            ]),
            // 3-byte before surrogates: [0xED][0x80-0x9F][0x80-0xBF]
            UTF8Sequence(ranges: [
                UTF8ByteRange(start: 0xED, end: 0xED),
                UTF8ByteRange(start: 0x80, end: 0x9F),
                UTF8ByteRange(start: 0x80, end: 0xBF),
            ]),
            // 3-byte after surrogates: [0xEE-0xEF][0x80-0xBF][0x80-0xBF]
            UTF8Sequence(ranges: [
                UTF8ByteRange(start: 0xEE, end: 0xEF),
                UTF8ByteRange(start: 0x80, end: 0xBF),
                UTF8ByteRange(start: 0x80, end: 0xBF),
            ]),
        ]

        #expect(seqs == expected)
    }

    /// Tests the reverse method on UTF8Sequence
    @Test(
        arguments: [
            (
                // One byte - reversing doesn't change anything
                [UTF8ByteRange(start: 0xA, end: 0xB)],
                [UTF8ByteRange(start: 0xA, end: 0xB)],
            ),
            (
                // Two bytes
                [UTF8ByteRange(start: 0xA, end: 0xB), UTF8ByteRange(start: 0xB, end: 0xC)],
                [UTF8ByteRange(start: 0xB, end: 0xC), UTF8ByteRange(start: 0xA, end: 0xB)],
            ),
            (
                // Three bytes
                [
                    UTF8ByteRange(start: 0xA, end: 0xB),
                    UTF8ByteRange(start: 0xB, end: 0xC),
                    UTF8ByteRange(start: 0xC, end: 0xD),
                ],
                [
                    UTF8ByteRange(start: 0xC, end: 0xD),
                    UTF8ByteRange(start: 0xB, end: 0xC),
                    UTF8ByteRange(start: 0xA, end: 0xB),
                ],
            ),
            (
                // Four bytes
                [
                    UTF8ByteRange(start: 0xA, end: 0xB),
                    UTF8ByteRange(start: 0xB, end: 0xC),
                    UTF8ByteRange(start: 0xC, end: 0xD),
                    UTF8ByteRange(start: 0xD, end: 0xE),
                ],
                [
                    UTF8ByteRange(start: 0xD, end: 0xE),
                    UTF8ByteRange(start: 0xC, end: 0xD),
                    UTF8ByteRange(start: 0xB, end: 0xC),
                    UTF8ByteRange(start: 0xA, end: 0xB),
                ],
            ),
        ],
    )
    func reverse(input: [UTF8ByteRange], expected: [UTF8ByteRange]) throws {
        var sequence = UTF8Sequence(ranges: input)
        sequence.reverse()
        #expect(sequence.ranges == expected)
    }
}
