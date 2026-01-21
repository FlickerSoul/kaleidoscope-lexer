//
//  DFA.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/20/26.
//

import Foundation

// MARK: - State ID

/// A unique identifier for a DFA state
public struct DFAStateID: Hashable, Equatable, Sendable, CustomStringConvertible, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt32

    public let id: UInt32

    public init(_ id: UInt32) {
        self.id = id
    }

    public init(integerLiteral value: UInt32) {
        id = value
    }

    public var description: String {
        if self == .dead {
            "dead"
        } else if self == .none {
            "none"
        } else {
            "\(id)"
        }
    }

    var asIndex: Int {
        Int(id)
    }

    /// The dead/reject state ID (always 0)
    public static let dead = DFAStateID(0)

    /// A sentinel value representing an invalid/unset state
    public static let none = DFAStateID(UInt32.max)
}

// MARK: - DFA State

/// A single state in the DFA
public struct DFAState: Sendable, Equatable {
    /// Transitions indexed by byte value (0-255)
    /// Each transition maps a byte to the next DFA state ID
    public private(set) var transitions: [DFAStateID]

    /// Pattern IDs that match in this state (empty if not a match state)
    public private(set) var matchPatternIDs: [PatternID]

    /// Whether this is a match state
    public var isMatch: Bool {
        !matchPatternIDs.isEmpty
    }

    /// Initialize a DFA state with all transitions pointing to the dead state
    public init() {
        // Initialize all 256 byte transitions to dead state
        transitions = Array(repeating: .dead, count: 256)
        matchPatternIDs = []
    }

    /// Initialize a DFA state with explicit transitions and pattern IDs
    public init(transitions: [DFAStateID], matchPatternIDs: [PatternID]) {
        self.transitions = transitions
        self.matchPatternIDs = matchPatternIDs
    }

    init(deadExcept: [Int: DFAStateID], matchPatternIDs: [PatternID]) {
        self = .init()
        for (byte, state) in deadExcept {
            transitions[byte] = state
        }
        self.matchPatternIDs = matchPatternIDs
    }

    /// Set the transition for a given byte
    public mutating func setTransition(for byte: UInt8, to state: DFAStateID) {
        transitions[Int(byte)] = state
    }

    /// Get the transition for a given byte
    public func transition(for byte: UInt8) -> DFAStateID {
        transitions[Int(byte)]
    }
}

// MARK: - DFA

/// A deterministic finite automaton built from an NFA
///
/// Optimized for anchored searches only. Matches must begin at the starting position.
public struct DFA: Sendable, Equatable {
    /// All DFA states, indexed by DFAStateID
    private(set) var states: [DFAState]

    /// Starting state for the automaton
    public private(set) var start: DFAStateID

    /// Pattern IDs supported by this DFA
    public private(set) var patternIDs: [PatternID]

    /// Initialize an empty DFA with just a dead state
    public init() {
        // State 0 is always the dead state
        states = [DFAState()]
        start = .dead
        patternIDs = []
    }

    /// Initialize a DFA with states and start state
    public init(
        states: [DFAState],
        start: DFAStateID,
        patternIDs: [PatternID],
    ) {
        self.states = states
        self.start = start
        self.patternIDs = patternIDs
    }

    /// Get state by ID
    public func state(_ id: DFAStateID) -> DFAState {
        guard id != .dead, id.asIndex < states.count else {
            return DFAState()
        }
        return states[id.asIndex]
    }

    /// Get next state given current state and input byte
    public func nextState(_ current: DFAStateID, byte: UInt8) -> DFAStateID {
        guard current != .dead, current.asIndex < states.count else {
            return .dead
        }
        return states[current.asIndex].transition(for: byte)
    }

    /// Check if state is a match state
    public func isMatch(_ id: DFAStateID) -> Bool {
        guard id != .dead, id.asIndex < states.count else {
            return false
        }
        return states[id.asIndex].isMatch
    }

    /// Get matching pattern IDs for a match state
    public func matchingPatterns(_ id: DFAStateID) -> [PatternID] {
        guard id != .dead, id.asIndex < states.count else {
            return []
        }
        return states[id.asIndex].matchPatternIDs
    }

    /// Add a new state to the DFA and return its ID
    @discardableResult
    mutating func addState(_ state: DFAState) throws(DFAConversionError) -> DFAStateID {
        guard states.count < UInt32.max else {
            throw .stateLimitExceeded
        }

        let id = DFAStateID(UInt32(states.count))
        states.append(state)
        return id
    }

    /// Set the start state
    mutating func setStartState(_ state: DFAStateID) {
        start = state
    }

    /// Set the pattern IDs
    mutating func setPatternIDs(_ ids: [PatternID]) {
        patternIDs = ids
    }

    /// Set a transition in a DFA state
    mutating func setTransition(for stateID: DFAStateID, byte: UInt8, to nextState: DFAStateID) {
        guard stateID != .dead, stateID.asIndex < states.count else {
            return
        }
        states[stateID.asIndex].setTransition(for: byte, to: nextState)
    }

    /// Get the number of states
    public var stateCount: Int {
        states.count
    }

    /// Check if the DFA is empty (only dead state)
    public var isEmpty: Bool {
        states.count == 1
    }
}

enum DFAConversionError: Error, Equatable {
    case stateLimitExceeded
}
