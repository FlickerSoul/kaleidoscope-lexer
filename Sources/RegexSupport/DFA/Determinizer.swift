//
//  Determinizer.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/20/26.
//

import Foundation

// MARK: - NFA State Set

/// Represents a set of NFA states that form a single DFA state.
///
/// During determinization, each DFA state is represented as a set of NFA states
/// that can be reached after consuming the same input prefix.
private struct NFAStateSet: Hashable {
    /// Ordered set of NFA state IDs (sorted for consistent hashing)
    private(set) var stateIDs: [NFAStateID]

    /// Pattern IDs that match in this set
    private(set) var matchPatterns: [PatternID]

    /// Initialize with states
    init(stateIDs: [NFAStateID] = [], matchPatterns: [PatternID] = []) {
        self.stateIDs = stateIDs
        self.matchPatterns = matchPatterns
    }

    /// Add a state to this set (maintains sorted order)
    mutating func insert(_ stateID: NFAStateID) {
        guard !stateIDs.contains(stateID) else { return }

        // Insert in sorted order for consistent hashing
        let insertIndex = stateIDs.firstIndex(where: { $0.id > stateID.id }) ?? stateIDs.endIndex
        stateIDs.insert(stateID, at: insertIndex)
    }

    /// Check if contains a state
    func contains(_ stateID: NFAStateID) -> Bool {
        stateIDs.contains(stateID)
    }

    /// Add a pattern to this set
    mutating func addPattern(_ pattern: PatternID) {
        guard !matchPatterns.contains(pattern) else { return }
        matchPatterns.append(pattern)
    }

    /// Clear the set
    mutating func clear() {
        stateIDs.removeAll()
        matchPatterns.removeAll()
    }

    /// Check if this set is empty
    var isEmpty: Bool {
        stateIDs.isEmpty
    }

    /// Hash using state IDs
    func hash(into hasher: inout Hasher) {
        hasher.combine(stateIDs)
    }

    /// Equality based on state IDs (match patterns don't affect equality for caching)
    static func == (lhs: NFAStateSet, rhs: NFAStateSet) -> Bool {
        lhs.stateIDs == rhs.stateIDs
    }
}

// MARK: - Determinizer

/// Converts an NFA to a DFA using powerset construction.
///
/// The determinizer implements the classical powerset construction algorithm where each DFA state
/// is represented as a set of NFA states. The algorithm:
/// 1. Compute epsilon closures to find all NFA states reachable without consuming input
/// 2. For each DFA state and input byte, compute the next set of reachable NFA states
/// 3. Use a cache to avoid creating duplicate DFA states
public struct Determinizer {
    private let nfa: NFA

    /// Cache: NFA state set -> DFA state ID (avoid duplicate DFA states)
    private var stateCache: [NFAStateSet: DFAStateID] = [:]

    /// DFA being built
    private var dfa: DFA

    /// Queue of DFA states that need transitions computed
    private var workQueue: [DFAStateID] = []

    /// Byte classes for alphabet reduction
    private let byteClasses: ByteClasses

    /// Working set for epsilon closure computation
    private var workStack: [NFAStateID] = []

    /// Temporary set for state operations
    private var tempSet: Set<NFAStateID> = []

    /// Main entry point: build DFA from NFA
    public static func buildDFA(from nfa: NFA) throws -> DFA {
        var determinizer = Determinizer(nfa: nfa)
        try determinizer.determinize()
        return determinizer.dfa
    }

    /// Initialize a determinizer
    private init(nfa: NFA) {
        self.nfa = nfa
        dfa = DFA()
        byteClasses = ByteClasses.fromNFA(nfa)
    }

    /// Core determinization algorithm
    private mutating func determinize() throws(DFAConversionError) {
        // Start with the NFA's starting state
        var startSet = NFAStateSet()
        startSet.insert(nfa.start)

        // Compute epsilon closure of the start state
        let startClosure = epsilonClosure(of: startSet)

        // Extract starting DFA state
        let (startDFAID, _) = try getOrCreateDFAState(for: startClosure)
        dfa.setStartState(startDFAID)

        // Add start state to work queue
        workQueue.append(startDFAID)

        // Main loop: process all uncompiled DFA states
        while !workQueue.isEmpty {
            let currentDFAID = workQueue.removeFirst()

            // Get the NFA state set corresponding to this DFA state
            guard let currentNFASet = stateCache.first(where: { $0.value == currentDFAID })?.key else {
                continue
            }

            // For each byte class representative
            for representative in byteClasses.representatives() {
                // Compute the next NFA state set
                let nextNFASet = nextNFAStateSet(from: currentNFASet, byte: representative)

                // Get or create DFA state for this NFA state set
                let nextDFAID: DFAStateID
                let isNew: Bool

                if nextNFASet.isEmpty {
                    nextDFAID = .dead
                    isNew = false
                } else {
                    (nextDFAID, isNew) = try getOrCreateDFAState(for: nextNFASet)
                }

                // Set transitions for ALL bytes in this equivalence class
                for byte in byteClasses.bytesInClass(for: representative) {
                    dfa.setTransition(for: currentDFAID, byte: byte, to: nextDFAID)
                }

                // If new state, add to work queue
                if isNew {
                    workQueue.append(nextDFAID)
                }
            }
        }

        // Set pattern IDs from NFA
        let allPatterns = nfa.states.compactMap { state -> PatternID? in
            if case let .match(patternID) = state {
                return patternID
            }
            return nil
        }

        var uniquePatterns: [PatternID] = []
        var seenPatterns = Set<UInt32>()
        for pattern in allPatterns {
            if !seenPatterns.contains(pattern.id) {
                seenPatterns.insert(pattern.id)
                uniquePatterns.append(pattern)
            }
        }

        dfa.setPatternIDs(uniquePatterns)

        // Prune unreachable states
        pruneUnreachable()
    }

    /// Remove unreachable states from the DFA.
    ///
    /// Some states created during determinization may never be reached from the start state.
    /// This phase removes them, reducing memory usage.
    private mutating func pruneUnreachable() {
        // Mark all reachable states via BFS from start state
        var reachable = Set<DFAStateID>()
        var queue: [DFAStateID] = [dfa.start]

        while !queue.isEmpty {
            let stateID = queue.removeFirst()

            guard !reachable.contains(stateID) else { continue }
            reachable.insert(stateID)

            // Add all states reachable from this state
            let state = dfa.state(stateID)
            for nextID in state.transitions {
                if !reachable.contains(nextID) {
                    queue.append(nextID)
                }
            }
        }

        // Dead state is always considered reachable (even if not explicitly reached)
        reachable.insert(.dead)

        // If all states are reachable, no pruning needed
        if reachable.count == dfa.states.count {
            return
        }

        // Create mapping from old state IDs to new compacted IDs
        var oldToNew: [DFAStateID: DFAStateID] = [:]
        var newStates: [DFAState] = []

        // Process states in order to maintain dead state at index 0
        for stateID in 0 ..< UInt32(dfa.states.count) {
            let id = DFAStateID(stateID)
            if reachable.contains(id) {
                oldToNew[id] = DFAStateID(UInt32(newStates.count))
                newStates.append(dfa.state(id))
            }
        }

        // Rebuild transitions with remapped state IDs
        for i in 0 ..< newStates.count {
            for byte: UInt8 in 0 ... 255 {
                let oldNext = newStates[i].transition(for: byte)
                if let newNext = oldToNew[oldNext] {
                    newStates[i].setTransition(for: byte, to: newNext)
                } else {
                    // If the next state was pruned, point to dead
                    newStates[i].setTransition(for: byte, to: .dead)
                }
            }
        }

        // Update DFA with pruned states
        if let newStart = oldToNew[dfa.start] {
            dfa = DFA(
                states: newStates,
                start: newStart,
                patternIDs: dfa.patternIDs,
            )
        }
    }

    /// Compute epsilon closure of NFA states.
    ///
    /// The epsilon closure includes all NFA states reachable from the given states
    /// without consuming any input.
    private mutating func epsilonClosure(of states: borrowing NFAStateSet) -> NFAStateSet {
        var result = NFAStateSet()
        workStack.removeAll()
        tempSet.removeAll()

        // Initialize work stack and result with input states
        for stateID in states.stateIDs {
            workStack.append(stateID)
            tempSet.insert(stateID)
            result.insert(stateID)
        }

        // Add patterns from input states
        for pattern in states.matchPatterns {
            result.addPattern(pattern)
        }

        // DFS to find all epsilon-reachable states
        while let stateID = workStack.popLast() {
            let nfaState = nfa[stateID]

            switch nfaState {
            case let .union(alternatives):
                // Union states are epsilon transitions
                for altID in alternatives {
                    if !tempSet.contains(altID) {
                        tempSet.insert(altID)
                        workStack.append(altID)
                        result.insert(altID)
                    }
                }

            case let .binaryUnion(alt1, alt2):
                // Binary union is two epsilon transitions
                for altID in [alt1, alt2] {
                    if !tempSet.contains(altID) {
                        tempSet.insert(altID)
                        workStack.append(altID)
                        result.insert(altID)
                    }
                }

            case let .match(patternID):
                // Match states contribute their pattern
                result.addPattern(patternID)

            case .byteRange, .sparse, .fail:
                // No epsilon transitions for these
                break
            }
        }

        return result
    }

    /// Compute next NFA state set given current set and input byte.
    ///
    /// This computes all NFA states reachable after consuming a single byte,
    /// including epsilon closures.
    private mutating func nextNFAStateSet(from current: NFAStateSet, byte: UInt8) -> NFAStateSet {
        var result = NFAStateSet()

        // For each NFA state in the current set, find transitions for this byte
        for stateID in current.stateIDs {
            let nfaState = nfa[stateID]

            switch nfaState {
            case let .byteRange(transition):
                if transition.matches(byte) {
                    result.insert(transition.next)
                }

            case let .sparse(transitions):
                for transition in transitions {
                    if transition.matches(byte) {
                        result.insert(transition.next)
                    }
                }

            case .union, .binaryUnion:
                // Epsilon transitions are handled by epsilon closure
                break

            case .match, .fail:
                // No byte transitions from match or fail states
                break
            }
        }

        // Compute epsilon closure of the result
        if !result.isEmpty {
            result = epsilonClosure(of: result)
        }

        return result
    }

    /// Get or create a DFA state for an NFA state set.
    ///
    /// If the NFA state set already exists in the cache, returns its DFA state ID.
    /// Otherwise, creates a new DFA state and caches it.
    ///
    /// Returns (DFA state ID, whether it's newly created)
    private mutating func getOrCreateDFAState(
        for nfaStates: NFAStateSet,
    ) throws(DFAConversionError) -> (DFAStateID, Bool) {
        // Check cache first
        if let cachedID = stateCache[nfaStates] {
            return (cachedID, false)
        }

        // Create new DFA state
        let dfaState = DFAState(
            transitions: Array(repeating: .dead, count: 256),
            matchPatternIDs: nfaStates.matchPatterns,
        )
        let dfa_id = try dfa.addState(dfaState)

        // Cache it
        stateCache[nfaStates] = dfa_id

        return (dfa_id, true)
    }
}
