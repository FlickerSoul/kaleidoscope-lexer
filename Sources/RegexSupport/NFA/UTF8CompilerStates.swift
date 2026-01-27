//
//  UTF8CompilerStates.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/19/26.
//

// FIXME: insufficient
/// Key for caching compiled UTF-8 suffixes
struct UTF8SuffixKey: Hashable {
    let transitions: [Transition]
}

/// Represents an uncompiled node in the UTF-8 automaton
struct UTF8Node {
    var trans: [Transition]
    var last: UTF8LastTransition?

    init(trans: [Transition] = [], last: UTF8LastTransition? = nil) {
        self.trans = trans
        self.last = last
    }

    mutating func setLastTransition(next: NFAStateID) {
        guard let last else { return }

        if let prev = trans.last,
           prev.next == next,
           prev.end.addingReportingOverflow(1).partialValue == last.start {
            trans[trans.count - 1] = Transition(
                start: prev.start,
                end: last.end,
                next: next,
            )
        } else {
            trans.append(
                Transition(start: last.start, end: last.end, next: next),
            )
        }

        self.last = nil
    }
}

/// Tracks the last transition added to a node (before freezing)
struct UTF8LastTransition {
    let start: UInt8
    let end: UInt8
}

/// State for compiling UTF-8 sequences
struct UTF8State {
    private let cacheLimit: Int
    var compiled: [UTF8SuffixKey: NFAStateID]
    var uncompiled: [UTF8Node]

    init(
        cacheLimit: Int = 10000,
        compiled: [UTF8SuffixKey: NFAStateID] = [:],
        uncompiled: [UTF8Node] = [],
    ) {
        self.cacheLimit = cacheLimit
        self.compiled = compiled
        self.uncompiled = uncompiled
    }

    mutating func clear() {
        compiled.removeAll(keepingCapacity: true)
        uncompiled.removeAll(keepingCapacity: true)
    }

    mutating func cacheGet(_ key: UTF8SuffixKey) -> NFAStateID? {
        compiled[key]
    }

    mutating func cacheSet(_ key: consuming UTF8SuffixKey, _ value: NFAStateID) {
        // Bounded cache - clear if exceeds limit
        if compiled.count >= cacheLimit {
            compiled.removeAll(keepingCapacity: true)
        }
        compiled[key] = value
    }
}
