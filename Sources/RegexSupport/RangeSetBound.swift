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
    static var min: Self { get }
    /// The maximum value in this type's domain
    static var max: Self { get }
    /// Returns the next value after this one, or nil if this is ``.max``
    func increment() -> Self?
    /// Returns the previous value before this one, or nil if this is ``.min``
    func decrement() -> Self?
}

extension Character {
    static var min: Self {
        "\u{0000}"
    }

    static var max: Self {
        "\u{10FFFF}"
    }
}

/// - SeeAlso: https://github.com/rust-lang/regex/blob/5ea3eb1e95f0338e283f5f0b4681f0891a1cd836/regex-syntax/src/hir/interval.rs#L538
extension Char: RangeSetBound {
    public static var min: Char {
        Char(unchecked: Character.min)
    }

    public static var max: Char {
        Char(unchecked: Character.max)
    }

    public func increment() -> Char? {
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
        return Char(Character(nextScalar))
    }

    public func decrement() -> Char? {
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
        return Char(Character(prevScalar))
    }
}

extension UInt8: RangeSetBound {
    public func increment() -> UInt8? {
        self == UInt8.max ? nil : self + 1
    }

    public func decrement() -> UInt8? {
        self == UInt8.min ? nil : self - 1
    }
}
