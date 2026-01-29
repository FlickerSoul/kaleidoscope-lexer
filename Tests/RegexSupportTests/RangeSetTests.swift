//
//  RangeSetTests.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//

@testable import RegexSupport
import Testing

@Suite("RangeSet Tests")
struct RangeSetTests {
    // MARK: - Normalize Tests

    @Test(
        arguments: [
            // Empty set
            ([], []),
            // Single range
            (["a" ... "z"], ["a" ... "z"]),
            // Already normalized
            (["a" ... "c", "e" ... "g"], ["a" ... "c", "e" ... "g"]),
            // Overlapping ranges merge
            (["a" ... "e", "c" ... "g"], ["a" ... "g"]),
            // Adjacent ranges merge (b+1 = c)
            (["a" ... "b", "c" ... "d"], ["a" ... "d"]),
            // Unsorted ranges get sorted
            (["x" ... "z", "a" ... "c"], ["a" ... "c", "x" ... "z"]),
            // Multiple overlapping ranges
            (["a" ... "c", "b" ... "e", "d" ... "g"], ["a" ... "g"]),
        ] as [([ClosedRange<Character>], [ClosedRange<Character>])],
    )
    func `normalize merges and sorts ranges`(
        input: [ClosedRange<Character>],
        expected: [ClosedRange<Character>],
    ) {
        let rangeSet = RangeSet<Character>(ranges: input)
        #expect(rangeSet.ranges == expected)
    }

    // MARK: - Union Tests

    @Test(
        arguments: [
            // Union with empty
            (["a" ... "c"], [], ["a" ... "c"]),
            // Empty union with set
            ([], ["a" ... "c"], ["a" ... "c"]),
            // Non-overlapping union
            (["a" ... "c"], ["e" ... "g"], ["a" ... "c", "e" ... "g"]),
            // Overlapping union
            (["a" ... "e"], ["c" ... "g"], ["a" ... "g"]),
            // Adjacent union
            (["a" ... "c"], ["d" ... "f"], ["a" ... "f"]),
            // Same set union
            (["a" ... "c"], ["a" ... "c"], ["a" ... "c"]),
        ] as [([ClosedRange<Character>], [ClosedRange<Character>], [ClosedRange<Character>])],
    )
    func `union combines ranges`(
        first: [ClosedRange<Character>],
        second: [ClosedRange<Character>],
        expected: [ClosedRange<Character>],
    ) {
        var rangeSet = RangeSet<Character>(ranges: first)
        rangeSet.union(RangeSet(ranges: second))
        #expect(rangeSet.ranges == expected)
    }

    // MARK: - Intersection Tests

    @Test(
        arguments: [
            // Intersection with empty
            (["a" ... "c"], [], []),
            // Empty intersection
            ([], ["a" ... "c"], []),
            // No overlap
            (["a" ... "c"], ["e" ... "g"], []),
            // Partial overlap
            (["a" ... "e"], ["c" ... "g"], ["c" ... "e"]),
            // One contains the other
            (["a" ... "z"], ["c" ... "e"], ["c" ... "e"]),
            // Same set
            (["a" ... "c"], ["a" ... "c"], ["a" ... "c"]),
            // Multiple ranges intersection
            (["a" ... "e", "m" ... "q"], ["c" ... "o"], ["c" ... "e", "m" ... "o"]),
        ] as [([ClosedRange<Character>], [ClosedRange<Character>], [ClosedRange<Character>])],
    )
    func `intersection finds common ranges`(
        first: [ClosedRange<Character>],
        second: [ClosedRange<Character>],
        expected: [ClosedRange<Character>],
    ) {
        var rangeSet = RangeSet<Character>(ranges: first)
        rangeSet.intersection(RangeSet(ranges: second))
        #expect(rangeSet.ranges == expected)
    }

    // MARK: - Subtraction Tests

    @Test(
        arguments: [
            // Subtract empty (no change)
            (["a" ... "c"], [], ["a" ... "c"]),
            // Subtract from empty
            ([], ["a" ... "c"], []),
            // No overlap (no change)
            (["a" ... "c"], ["e" ... "g"], ["a" ... "c"]),
            // Complete subtraction
            (["a" ... "c"], ["a" ... "c"], []),
            // Subtract containing range
            (["c" ... "e"], ["a" ... "g"], []),
            // Subtract from start
            (["a" ... "e"], ["a" ... "c"], ["d" ... "e"]),
            // Subtract from end
            (["a" ... "e"], ["c" ... "e"], ["a" ... "b"]),
            // Subtract from middle (split)
            (["a" ... "g"], ["c" ... "e"], ["a" ... "b", "f" ... "g"]),
            // Multiple subtractions
            (["a" ... "z"], ["c" ... "e", "m" ... "o"], ["a" ... "b", "f" ... "l", "p" ... "z"]),
        ] as [([ClosedRange<Character>], [ClosedRange<Character>], [ClosedRange<Character>])],
    )
    func `subtraction removes ranges`(
        first: [ClosedRange<Character>],
        second: [ClosedRange<Character>],
        expected: [ClosedRange<Character>],
    ) {
        var rangeSet = RangeSet<Character>(ranges: first)
        rangeSet.subtraction(RangeSet(ranges: second))
        #expect(rangeSet.ranges == expected)
    }

    // MARK: - Symmetric Difference Tests

    @Test(
        arguments: [
            // Symmetric diff with empty
            (["a" ... "c"], [], ["a" ... "c"]),
            // Empty symmetric diff
            ([], ["a" ... "c"], ["a" ... "c"]),
            // No overlap (union)
            (["a" ... "c"], ["e" ... "g"], ["a" ... "c", "e" ... "g"]),
            // Same set (empty result)
            (["a" ... "c"], ["a" ... "c"], []),
            // Partial overlap
            (["a" ... "e"], ["c" ... "g"], ["a" ... "b", "f" ... "g"]),
        ] as [([ClosedRange<Character>], [ClosedRange<Character>], [ClosedRange<Character>])],
    )
    func `symmetric difference finds exclusive ranges`(
        first: [ClosedRange<Character>],
        second: [ClosedRange<Character>],
        expected: [ClosedRange<Character>],
    ) {
        var rangeSet = RangeSet<Character>(ranges: first)
        rangeSet.symmetricDifference(RangeSet(ranges: second))
        #expect(rangeSet.ranges == expected)
    }

    // MARK: - Invert Tests

    @Test
    func `invert empty set gives full range`() {
        var rangeSet = RangeSet<Character>(ranges: [])
        rangeSet.invert()
        #expect(rangeSet.ranges == [Character.min ... Character.max])
    }

    @Test
    func `invert full range gives empty set`() {
        var rangeSet = RangeSet<Character>(ranges: [Character.min ... Character.max])
        rangeSet.invert()
        #expect(rangeSet.ranges == [])
    }

    @Test
    func `invert middle range gives two ranges`() {
        var rangeSet = RangeSet<Character>(ranges: ["m" ... "p"])
        rangeSet.invert()
        #expect(rangeSet == .init(ranges: [Character.min ... "l", "q" ... Character.max]))
    }

    @Test
    func `double invert returns original`() {
        let original = RangeSet<Character>(ranges: ["a" ... "z"])
        var rangeSet = original
        rangeSet.invert()
        rangeSet.invert()
        #expect(rangeSet.ranges == original.ranges)
    }

    // MARK: - Edge Cases

    @Test
    func `single character range`() {
        let rangeSet = RangeSet<Character>(ranges: ["a" ... "a"])
        #expect(rangeSet.ranges == ["a" ... "a"])
    }

    @Test
    func `adjacent single characters merge`() {
        let rangeSet = RangeSet<Character>(ranges: ["a" ... "a", "b" ... "b", "c" ... "c"])
        #expect(rangeSet.ranges == ["a" ... "c"])
    }

    @Test
    func `subtract single character from range`() {
        var rangeSet = RangeSet<Character>(ranges: ["a" ... "e"])
        rangeSet.subtraction(RangeSet(ranges: ["c" ... "c"]))
        #expect(rangeSet.ranges == ["a" ... "b", "d" ... "e"])
    }
}
