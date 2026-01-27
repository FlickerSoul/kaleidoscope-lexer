//
//  ByteClasses.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/20/26.
//

import Foundation

// MARK: - Byte Classes

/// Maps bytes to equivalence classes for alphabet reduction.
///
/// Byte classes group bytes that always transition to the same state in the DFA.
/// This reduces the alphabet size and thus the number of transitions that need to be computed.
struct ByteClasses: Sendable {
    /// Buffer type for byte-to-class mapping. Could be replaced by `InlineArray<UInt8, 256>` for optimization
    typealias BufferType = [UInt8]
    /// Map from byte (0-255) to class ID
    private var byteToClass: BufferType

    /// Initialize with singleton classes (one per byte, for debugging)
    init() {
        // Identity mapping: byte i maps to class i
        self = .init(byteToClass: .init(0 ... 0xFF))
    }

    /// Initialize with specific byte-to-class mapping
    init(byteToClass: [UInt8]) {
        assert(byteToClass.count == 256)
        self.byteToClass = byteToClass
    }

    /// Get the equivalence class for a byte
    func classFor(byte: UInt8) -> UInt8 {
        byteToClass[Int(byte)]
    }

    /// Get representative bytes for each equivalence class
    func representatives() -> [UInt8] {
        var seen = Set<UInt8>()
        var reps: [UInt8] = []

        for byte in UInt8.min ... UInt8.max {
            let classID = classFor(byte: byte)
            if !seen.contains(classID) {
                seen.insert(classID)
                reps.append(byte)
            }
        }

        return reps
    }

    /// Get all bytes belonging to the same equivalence class as the given representative byte
    func bytesInClass(for representative: UInt8) -> [UInt8] {
        let classID = classFor(byte: representative)
        return (UInt8.min ... UInt8.max).filter { byte in
            classFor(byte: byte) == classID
        }
    }

    /// Build byte classes from an NFA by analyzing transition ranges
    ///
    /// This analyzes which bytes can be distinguished in the NFA and groups
    /// indistinguishable bytes into the same equivalence class.
    static func fromNFA(_ nfa: NFA) -> ByteClasses {
        // Build a set of all byte boundaries where transitions change
        var boundaries = Set<UInt8>()
        boundaries.insert(0) // Always include 0
        boundaries.insert(0xFF) // Always include 255

        // Scan all NFA states for byte ranges
        for nfaState in nfa.states {
            switch nfaState {
            case let .byteRange(transition):
                // Add boundaries around this transition
                boundaries.insert(transition.start)
                if transition.end < UInt.max {
                    boundaries.insert(transition.end &+ 1)
                }

            case let .sparse(transitions):
                // Add boundaries around all transitions
                for transition in transitions {
                    boundaries.insert(transition.start)
                    if transition.end < UInt.max {
                        boundaries.insert(transition.end &+ 1)
                    }
                }

            case .union, .binaryUnion, .match, .fail:
                // These don't have byte transitions
                break
            }
        }

        // Sort boundaries for processing
        let sortedBoundaries = boundaries.sorted()

        // Assign classes: each range between boundaries gets a unique class
        var byteToClass = [UInt8](repeating: 0, count: 256)
        var currentClass: UInt8 = 0

        var boundaryIndex = 0
        for byte in UInt8.min ... UInt8.max {
            // Check if we've passed the next boundary
            while boundaryIndex < sortedBoundaries.count, byte >= sortedBoundaries[boundaryIndex] {
                currentClass = UInt8(min(UInt16(currentClass) + 1, 0xFF))
                boundaryIndex += 1
            }
            byteToClass[Int(byte)] = currentClass
        }

        return ByteClasses(byteToClass: byteToClass)
    }
}
