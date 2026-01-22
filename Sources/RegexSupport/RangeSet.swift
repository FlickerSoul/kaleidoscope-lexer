//
//  RangeSet.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//

public struct RangeSet<T: RangeSetBound>: ExpressibleByArrayLiteral, Equatable {
    public typealias ArrayLiteralElement = ClosedRange<T>

    public var ranges: [ClosedRange<T>]

    public init(arrayLiteral elements: ClosedRange<T>...) {
        ranges = elements
        normalize()
    }

    public init(ranges: [ClosedRange<T>]) {
        self.ranges = ranges
        normalize()
    }

    public var isEmpty: Bool {
        ranges.isEmpty
    }

    // MARK: - Set Operations

    /// Takes the union of two RangeSets
    public mutating func union(_ other: RangeSet<T>) {
        if other.ranges.isEmpty || ranges == other.ranges {
            return
        }

        union(other.ranges)
    }

    mutating func union(_ other: any Sequence<ClosedRange<T>>) {
        if ranges.isEmpty {
            return
        }

        ranges.append(contentsOf: other)
        normalize()
    }

    mutating func union(_ other: ClosedRange<T>) {
        ranges.append(other)
        normalize()
    }

    /// Takes the intersection of two RangeSets
    public mutating func intersection(_ other: RangeSet<T>) {
        if ranges.isEmpty {
            return
        }
        if other.ranges.isEmpty {
            ranges.removeAll()
            return
        }

        // Append intersection results to the end, then drain original ranges
        let drainEnd = ranges.count

        var idxA = 0
        var idxB = 0

        while idxA < drainEnd, idxB < other.ranges.count {
            let rangeA = ranges[idxA]
            let rangeB = other.ranges[idxB]

            // Check for intersection
            let lower = Swift.max(rangeA.lowerBound, rangeB.lowerBound)
            let upper = Swift.min(rangeA.upperBound, rangeB.upperBound)
            if lower <= upper {
                ranges.append(lower ... upper)
            }

            // Advance the range with the smaller upper bound
            if rangeA.upperBound < rangeB.upperBound {
                idxA += 1
            } else {
                idxB += 1
            }
        }

        ranges.removeFirst(drainEnd)
    }

    /// Takes the subtraction of two RangeSets (self - other)
    public mutating func subtraction(_ other: RangeSet<T>) {
        if ranges.isEmpty || other.ranges.isEmpty {
            return
        }

        let drainEnd = ranges.count
        var idxA = 0
        var idxB = 0

        outer: while idxA < drainEnd, idxB < other.ranges.count {
            // If other range is entirely before current range, skip it
            if other.ranges[idxB].upperBound < ranges[idxA].lowerBound {
                idxB += 1
                continue
            }

            // If current range is entirely before other range, keep it as-is
            if ranges[idxA].upperBound < other.ranges[idxB].lowerBound {
                ranges.append(ranges[idxA])
                idxA += 1
                continue
            }

            // There is overlap - process this range against all overlapping other ranges
            var currentRange = ranges[idxA]
            while idxB < other.ranges.count,
                  !(other.ranges[idxB].lowerBound > currentRange.upperBound) {
                let subtractRange = other.ranges[idxB]

                let (left, right) = difference(currentRange, subtractRange)

                if let leftRange = left {
                    ranges.append(leftRange)
                }

                guard let rightRange = right else {
                    // No right part means currentRange is fully processed
                    idxA += 1
                    continue outer
                }

                currentRange = rightRange

                // If subtractRange extends beyond original range, don't advance idxB
                if subtractRange.upperBound > ranges[idxA].upperBound {
                    break
                }
                idxB += 1
            }

            // Append any remaining portion of currentRange
            ranges.append(currentRange)
            idxA += 1
        }

        // Add remaining ranges from self that weren't processed
        while idxA < drainEnd {
            ranges.append(ranges[idxA])
            idxA += 1
        }

        ranges.removeFirst(drainEnd)
    }

    /// Computes the difference of two ranges: range - subtract
    /// Returns (left part, right part) where either may be nil
    private func difference(
        _ range: ClosedRange<T>,
        _ subtract: ClosedRange<T>,
    ) -> (ClosedRange<T>?, ClosedRange<T>?) {
        // If no overlap, return range unchanged
        if subtract.upperBound < range.lowerBound || subtract.lowerBound > range.upperBound {
            return (range, nil)
        }

        // If subtract completely contains range
        if subtract.lowerBound <= range.lowerBound, range.upperBound <= subtract.upperBound {
            return (nil, nil)
        }

        var left: ClosedRange<T>?
        var right: ClosedRange<T>?

        // Left part: from range.lower to just before subtract.lower
        if range.lowerBound < subtract.lowerBound {
            if let upper = subtract.lowerBound.decrement() {
                left = range.lowerBound ... upper
            }
        }

        // Right part: from just after subtract.upper to range.upper
        if subtract.upperBound < range.upperBound {
            if let lower = subtract.upperBound.increment() {
                right = lower ... range.upperBound
            }
        }

        return (left, right)
    }

    /// Takes the symmetric difference of two RangeSets
    public mutating func symmetricDifference(_ other: RangeSet<T>) {
        // Symmetric difference = (self union other) - (self intersection other)
        var intersection = self
        intersection.intersection(other)

        union(other)
        subtraction(intersection)
    }

    /// Negates this interval set
    public mutating func invert() {
        if ranges.isEmpty {
            ranges = [T.minValue ... T.maxValue]
            return
        }

        let drainEnd = ranges.count

        // Add range before first interval if needed
        if ranges[0].lowerBound > T.minValue {
            if let upper = ranges[0].lowerBound.decrement() {
                ranges.append(T.minValue ... upper)
            }
        }

        // Add gaps between intervals
        for i in 1 ..< drainEnd {
            if let lower = ranges[i - 1].upperBound.increment(),
               let upper = ranges[i].lowerBound.decrement() {
                ranges.append(lower ... upper)
            }
        }

        // Add range after last interval if needed
        if ranges[drainEnd - 1].upperBound < T.maxValue {
            if let lower = ranges[drainEnd - 1].upperBound.increment() {
                ranges.append(lower ... T.maxValue)
            }
        }

        ranges.removeFirst(drainEnd)
    }

    /// Returns an inverted copy of this RangeSet
    public func inverting() -> RangeSet<T> {
        var copy = self
        copy.invert()
        return copy
    }

    // MARK: - Normalization

    /// Normalize the internal ranges
    /// After normalization, this guarantees that:
    /// 1. there are no overlapping ranges
    /// 2. ranges are sorted in ascending order
    /// 3. adjacent ranges are merged
    /// e.g. [1...3, 2...5, 7...9, 10...12] -> [1...5, 7...12]
    mutating func normalize() {
        guard !ranges.isEmpty else { return }

        // Sort ranges by lower bound
        ranges.sort { $0.lowerBound < $1.lowerBound }

        var merged: [ClosedRange<T>] = []
        var current = ranges[0]

        for range in ranges.dropFirst() {
            // Check if ranges overlap or are adjacent (contiguous)
            if isContiguous(current, range) {
                // Merge the ranges
                let newLower = Swift.min(current.lowerBound, range.lowerBound)
                let newUpper = Swift.max(current.upperBound, range.upperBound)
                current = newLower ... newUpper
            } else {
                merged.append(current)
                current = range
            }
        }
        merged.append(current)

        ranges = merged
    }

    /// Returns true if two ranges are contiguous (overlapping or adjacent)
    private func isContiguous(_ a: ClosedRange<T>, _ b: ClosedRange<T>) -> Bool {
        // Overlapping
        if a.overlaps(b) {
            return true
        }
        // Adjacent: a.upper + 1 == b.lower or b.upper + 1 == a.lower
        if let aUpperNext = a.upperBound.increment(), aUpperNext == b.lowerBound {
            return true
        }
        if let bUpperNext = b.upperBound.increment(), bUpperNext == a.lowerBound {
            return true
        }
        return false
    }

    public mutating func addSingle(_ byte: T) {
        union(byte ... byte)
    }
}

// MARK: - Sendable

extension RangeSet: Sendable where T: Sendable {}

// MARK: - Hashable

extension RangeSet: Hashable where T: Hashable {}
