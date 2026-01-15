//
//  RangeSetBound.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//

/// A protocol for types that can be used as bounds in a RangeSet.
/// Provides the ability to get adjacent values (increment/decrement)
/// and the min/max values of the domain.
public protocol RangeSetBound: Comparable {
    /// The minimum value in this type's domain
    static var minValue: Self { get }
    /// The maximum value in this type's domain
    static var maxValue: Self { get }
    /// Returns the next value after this one, or nil if this is maxValue
    func increment() -> Self?
    /// Returns the previous value before this one, or nil if this is minValue
    func decrement() -> Self?
}

/// - SeeAlso: https://github.com/rust-lang/regex/blob/5ea3eb1e95f0338e283f5f0b4681f0891a1cd836/regex-syntax/src/hir/interval.rs#L538
extension Character: RangeSetBound {
    public static var minValue: Character { "\u{0000}" }
    public static var maxValue: Character { "\u{10FFFF}" }

    public func increment() -> Character? {
        guard let scalar = unicodeScalars.first else { return nil }
        let value = scalar.value
        // Handle surrogate gap: D800-DFFF are not valid scalar values
        let nextValue: UInt32
        if value == 0xD7FF {
            nextValue = 0xE000
        } else if value >= 0x10FFFF {
            return nil
        } else {
            nextValue = value + 1
        }
        guard let nextScalar = Unicode.Scalar(nextValue) else { return nil }
        return Character(nextScalar)
    }

    public func decrement() -> Character? {
        guard let scalar = unicodeScalars.first else { return nil }
        let value = scalar.value
        // Handle surrogate gap: D800-DFFF are not valid scalar values
        let prevValue: UInt32
        if value == 0xE000 {
            prevValue = 0xD7FF
        } else if value == 0 {
            return nil
        } else {
            prevValue = value - 1
        }
        guard let prevScalar = Unicode.Scalar(prevValue) else { return nil }
        return Character(prevScalar)
    }
}
