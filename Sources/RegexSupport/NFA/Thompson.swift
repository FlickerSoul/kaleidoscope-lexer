//
//  Thompson.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//
import CasePaths

// MARK: - State ID

/// A unique identifier for an NFA state
public struct NFAStateID: Hashable, Equatable, Sendable, CustomStringConvertible, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt32

    public let id: UInt32

    public init(_ id: UInt32) {
        self.id = id
    }

    public init(integerLiteral value: UInt32) {
        id = value
    }

    public var description: String {
        "\(id)"
    }

    var asIndex: Int {
        Int(id)
    }

    /// A sentinel value representing an invalid/unset state
    public static let none = NFAStateID(UInt32.max)
}

// MARK: - Byte Range Transition

/// A transition because of a contiguous range of bytes
public struct Transition: Equatable, Sendable {
    /// The inclusive start of the byte range
    public let start: UInt8
    /// The inclusive end of the byte range
    public let end: UInt8
    /// The target state ID
    public var next: NFAStateID

    public init(start: UInt8, end: UInt8, next: NFAStateID) {
        self.start = start
        self.end = end
        self.next = next
    }

    /// Creates a transition for a single byte
    public init(byte: UInt8, next: NFAStateID) {
        start = byte
        end = byte
        self.next = next
    }

    /// Returns true if the given byte matches this transition
    public func matches(_ byte: UInt8) -> Bool {
        start <= byte && byte <= end
    }
}

// MARK: - NFA State

/// Represents a state in the NFA
///
/// Similar to Rust's regex-automata, each state represents an instruction
/// in a virtual machine that processes input bytes.
@CasePathable
public enum NFAState: Equatable, Sendable {
    /// A state with a single byte range transition.
    /// Matches if the current input byte falls within [start, end].
    case byteRange(Transition)

    /// A state with multiple non-overlapping byte range transitions.
    /// Used for character classes that span multiple ranges.
    case sparse([Transition])

    /// A union of states - tries each alternative in order.
    /// First alternative has priority (for greedy matching).
    case union([NFAStateID])

    /// A special case of union with exactly two alternatives.
    case binaryUnion(NFAStateID, NFAStateID)

    /// A match/accept state. Reached when the pattern successfully matches.
    case match(PatternID)

    /// A fail/dead state. Represents an impossible transition.
    case fail

    func remap(_ map: borrowing [NFAStateID]) -> NFAState {
        switch self {
        case var .byteRange(transition):
            transition.next = map[transition.next.asIndex]
            return .byteRange(transition)
        case var .sparse(transitions):
            for index in 0 ..< transitions.count {
                var transition = transitions[index]
                transition.next = map[transition.next.asIndex]
                transitions[index] = transition
            }

            return .sparse(transitions)
        case var .union(alternatives):
            for index in 0 ..< alternatives.count {
                alternatives[index] = map[alternatives[index].asIndex]
            }
            return .union(alternatives)
        case let .binaryUnion(alt1, alt2):
            return .binaryUnion(
                map[alt1.asIndex],
                map[alt2.asIndex],
            )
        case let .match(patternId):
            return .match(patternId)
        case .fail:
            return .fail
        }
    }
}

public enum NFABuilderState: Equatable, Sendable {
    /// A state with a single byte range transition.
    /// Matches if the current input byte falls within [start, end].
    case byteRange(Transition)

    /// A state with multiple non-overlapping byte range transitions.
    /// Used for character classes that span multiple ranges.
    case sparse([Transition])

    /// An unconditional epsilon transition to another state.
    /// Used internally during construction, typically eliminated in optimization.
    case epsilon(NFAStateID)

    /// A union of states - tries each alternative in order.
    /// First alternative has priority (for greedy matching).
    case union([NFAStateID])

    /// A union of states in reverse order - tries each alternative in reverse order.
    case unionReverse([NFAStateID])

    /// A match/accept state. Reached when the pattern successfully matches.
    case match(PatternID)

    /// A fail/dead state. Represents an impossible transition.
    case fail

    func goTo() -> NFAStateID? {
        switch self {
        case let .epsilon(next):
            next
        case let .union(unions) where unions.count == 1:
            unions[0]
        case let .unionReverse(unions) where unions.count == 1:
            unions[0]
        case .byteRange, .sparse, .union, .unionReverse, .match, .fail:
            nil
        }
    }
}

// MARK: - NFA

/// A byte-oriented Non-deterministic Finite Automaton built using Thompson's construction.
///
/// This NFA operates on individual bytes, with Unicode characters encoded as UTF-8 sequences.
/// For example, the character 'é' (U+00E9) becomes a two-state sequence matching bytes 0xC3 0xA9.
public struct NFA: Equatable, Sendable {
    /// All states in the NFA, indexed by NFAStateID
    public private(set) var states: [NFAState]

    /// The starting state of the NFA
    public let start: NFAStateID

    public init(states: [NFAState], start: NFAStateID) {
        self.states = states
        self.start = start
    }

    /// Returns the state at the given ID
    public subscript(id: NFAStateID) -> NFAState {
        states[Int(id.id)]
    }

    /// The number of states in the NFA
    public var stateCount: Int {
        states.count
    }
}

// MARK: - NFA Fragment

/// A fragment of an NFA with a single entry point and single exit point.
/// Used during Thompson construction to build larger NFAs from smaller pieces.
struct NFAFragment {
    /// The entry state of this fragment
    let start: NFAStateID
    /// The exit state of this fragment (to be patched later)
    let end: NFAStateID
}

// MARK: - NFA Construction Error

public enum NFAConstructionError: Error {
    case stateLimitExceeded
    case patternLimitExceeded
    case invalidOperation(description: String)
}

public struct PatternID: Hashable, Sendable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt32

    let id: UInt32

    public init(integerLiteral value: UInt32) {
        id = value
    }

    init(_ id: UInt32) {
        self.id = id
    }
}

// MARK: - Thompson Builder

/// Builder for constructing NFAs using Thompson's construction algorithm.
///
/// The builder provides a two-phase construction:
/// 1. Add states and transitions, using placeholder StateIDs where needed
/// 2. Patch placeholders and finalize the NFA
public struct ThompsonBuilder {
    /// The id of the pattern we are currently building.
    ///
    /// Each pattern is referring to a different regex expr.
    private(set) var patternID: PatternID?

    /// The mapping from pattern ID to state start IDs
    ///
    /// This indicates the starting state of each individual pattern.
    private(set) var patternStarts: [NFAStateID] = []

    /// States accumulated during construction
    private var states: [NFABuilderState] = []

    /// Pattern start state (set when building begins)
    private var patternStart: NFAStateID = .none

    public init() {}

    // MARK: - Pattern handling

    mutating func startPattern() throws(NFAConstructionError) -> PatternID {
        precondition(patternID == nil, "Please finalize the previous pattern before starting a new one.")

        let nextPatternID = patternStarts.count
        if nextPatternID > Int(PatternID.IntegerLiteralType.max) {
            throw NFAConstructionError.patternLimitExceeded
        }

        let patternID = PatternID(.init(nextPatternID))
        self.patternID = patternID
        patternStarts.append(.none)

        return patternID
    }

    mutating func endPattern(with stateId: NFAStateID) throws(NFAConstructionError) {
        guard let currentPatternID = patternID else {
            throw .invalidOperation(description: "Ending a pattern but no pattern is currently being built.")
        }
        patternStarts[Int(currentPatternID.id)] = stateId
        patternID = nil
    }

    // MARK: - NFAState Creation

    /// Allocates a new state ID without adding a state
    private mutating func allocate() throws(NFAConstructionError) -> NFAStateID {
        if states.count >= Int(UInt32.max) {
            throw .stateLimitExceeded
        }
        let id = NFAStateID(UInt32(states.count))

        return id
    }

    /// Adds a union state and returns its ID
    public mutating func addUnion(_ alternatives: [NFAStateID]? = nil) throws(NFAConstructionError) -> NFAStateID {
        let id = try allocate()
        states.append(.union(alternatives ?? []))
        return id
    }

    public mutating func addUnionReverse(
        _ alternatives: [NFAStateID]? = nil,
    ) throws(NFAConstructionError) -> NFAStateID {
        let id = try allocate()
        states.append(.unionReverse(alternatives ?? []))
        return id
    }

    // MARK: - Patch

    mutating func patch(from: NFAStateID, to: NFAStateID) throws(NFAConstructionError) {
        let fromState = states[from.asIndex]
        let newState: NFABuilderState

        switch fromState {
        case var .byteRange(transition):
            transition.next = to
            newState = .byteRange(transition)
        case .sparse:
            throw NFAConstructionError.invalidOperation(description: "Cannot patch sparse state directly.")
        case .epsilon:
            newState = .epsilon(to)
        case var .union(unions):
            unions.append(to)
            newState = .union(unions)
        case var .unionReverse(unions):
            unions.append(to)
            newState = .unionReverse(unions)
        case let .match(next):
            newState = .match(next)
        case .fail:
            newState = .fail
        }

        states[from.asIndex] = newState
    }

    /// Adds a byte range state and returns its ID
    public mutating func addByteRange(_ transition: Transition) throws(NFAConstructionError) -> NFAStateID {
        let id = try allocate()
        states.append(.byteRange(transition))
        return id
    }

    /// Adds a sparse (multiple byte ranges) state and returns its ID
    public mutating func addSparse(_ transitions: [Transition]) throws(NFAConstructionError) -> NFAStateID {
        let id = try allocate()
        states.append(.sparse(transitions))
        return id
    }

    /// Adds an epsilon state and returns its ID
    public mutating func addEpsilon() throws(NFAConstructionError) -> NFAStateID {
        let id = try allocate()
        states.append(.epsilon(.none))
        return id
    }

    /// Adds a match state and returns its ID
    public mutating func addMatch() throws(NFAConstructionError) -> NFAStateID {
        guard let currentPatternID = patternID else {
            throw NFAConstructionError
                .invalidOperation(description: "Cannot add match state without an active pattern.")
        }

        let id = try allocate()
        states.append(.match(currentPatternID))
        return id
    }

    /// Adds a fail state and returns its ID
    public mutating func addFail() throws(NFAConstructionError) -> NFAStateID {
        let id = try allocate()
        states.append(.fail)
        return id
    }

    // MARK: - NFAState Patching

    /// Patches the target of a byte range transition
    public mutating func patchByteRange(_ stateID: NFAStateID, next: NFAStateID) {
        guard case var .byteRange(trans) = states[Int(stateID.id)] else {
            return
        }
        trans.next = next
        states[Int(stateID.id)] = .byteRange(trans)
    }

    /// Patches all transitions in a sparse state
    public mutating func patchSparse(_ stateID: NFAStateID, next: NFAStateID) {
        switch states[Int(stateID.id)] {
        case var .byteRange(trans):
            trans.next = next
            states[Int(stateID.id)] = .byteRange(trans)
        case var .sparse(transitions):
            for i in transitions.indices {
                transitions[i].next = next
            }
            states[Int(stateID.id)] = .sparse(transitions)
        default:
            break
        }
    }

    /// Patches an epsilon state's target
    public mutating func patchEpsilon(_ stateID: NFAStateID, next: NFAStateID) {
        states[Int(stateID.id)] = .epsilon(next)
    }

    // MARK: - Building

    /// Builds the final NFA from accumulated states
    public func build(start: NFAStateID) throws(NFAConstructionError) -> NFA {
        var epsilons: [(from: NFAStateID, to: NFAStateID)] = []
        var remap: [NFAStateID] = .init(repeating: .none, count: states.count)
        var nfaProxy = NFAProxy(
            start: start,
            patternStarts: patternStarts,
        )

        for (sidIndex, state) in states.enumerated() {
            let sid = NFAStateID(UInt32(sidIndex))

            switch state {
            case let .byteRange(transition):
                remap[sid.asIndex] = nfaProxy.add(state: .byteRange(transition))
            case let .sparse(transitions):
                switch transitions.count {
                case 0: throw .invalidOperation(description: "Sparse state with no transitions.")
                case 1: remap[sid.asIndex] = nfaProxy.add(state: .byteRange(transitions[0]))
                default: remap[sid.asIndex] = nfaProxy.add(state: .sparse(transitions))
                }
            case let .epsilon(next):
                epsilons.append((sid, next))
            case let .union(unions):
                switch unions.count {
                case 0:
                    remap[sid.asIndex] = nfaProxy.add(state: .fail)
                case 1:
                    epsilons.append((sid, unions[0]))
                    remap[sid.asIndex] = unions[0]
                case 2:
                    remap[sid.asIndex] = nfaProxy.add(
                        state: .binaryUnion(
                            unions[0],
                            unions[1],
                        ),
                    )
                default:
                    remap[sid.asIndex] = nfaProxy.add(
                        state: .union(unions),
                    )
                }
            case let .unionReverse(unions):
                switch unions.count {
                case 0:
                    remap[sid.asIndex] = nfaProxy.add(state: .fail)
                case 1:
                    epsilons.append((sid, unions[0]))
                    remap[sid.asIndex] = unions[0]
                case 2:
                    remap[sid.asIndex] = nfaProxy.add(
                        state: .binaryUnion(
                            unions[1],
                            unions[0],
                        ),
                    )
                default:
                    remap[sid.asIndex] = nfaProxy.add(
                        state: .union(unions.reversed()),
                    )
                }
            case let .match(patternId):
                remap[sid.asIndex] = nfaProxy.add(state: .match(patternId))
            case .fail:
                remap[sid.asIndex] = nfaProxy.add(state: .fail)
            }
        }
        var remapped: [Bool] = .init(repeating: false, count: states.count)
        for (from, to) in epsilons {
            if remapped[from.asIndex] {
                continue
            }

            var new_next = to
            while let next = states[new_next.asIndex].goTo() {
                new_next = next
            }

            remap[from.asIndex] = remap[new_next.asIndex]
            remapped[from.asIndex] = true

            var next2 = to
            while let next = states[next2.asIndex].goTo() {
                remap[next2.asIndex] = remap[new_next.asIndex]
                remapped[next2.asIndex] = true
                next2 = next
            }
        }

        nfaProxy.remap(remap)
        // FIXME: implement final shrinking

        return NFA(states: nfaProxy.states, start: nfaProxy.start)
    }
}

struct NFAProxy {
    /// Collected final NFA states
    var states: [NFAState]

    /// Anchored start
    var start: NFAStateID

    /// PatternID to StateID mapping
    var patternStarts: [NFAStateID]

    init(states: [NFAState] = [], start: NFAStateID, patternStarts: [NFAStateID]) {
        self.states = states
        self.start = start
        self.patternStarts = patternStarts
    }

    mutating func add(state: NFAState) -> NFAStateID {
        let stateID = NFAStateID(UInt32(states.count))
        states.append(state)
        return stateID
    }

    mutating func remap(_ map: borrowing [NFAStateID]) {
        for stateIndex in 0 ..< states.count {
            states[stateIndex] = states[stateIndex].remap(map)
        }

        start = map[start.asIndex]

        for patternIndex in 0 ..< patternStarts.count {
            patternStarts[patternIndex] = map[patternStarts[patternIndex].asIndex]
        }
    }
}

// MARK: - Thompson Construction

/// Thompson's construction algorithm for converting HIR to byte-based NFA.
public struct ThompsonConstruction {
    private var builder: ThompsonBuilder

    public init() {
        builder = ThompsonBuilder()
    }

    public mutating func build(from hirs: [HIRKind]) throws(NFAConstructionError) -> NFA {
        // assume all HIRs are anchored
        let fragments = try hirs.map { hir throws(NFAConstructionError) in
            _ = try builder.startPattern()
            let fragment = try compile(hir)
            let match = try builder.addMatch()
            try builder.patch(from: fragment.end, to: match)
            try builder.endPattern(with: fragment.start)
            return NFAFragment(start: fragment.start, end: match)
        }

        let finalFragment = try compileFragments(fragments)

        return try builder.build(start: finalFragment.start)
    }

    /// Builds an NFA from the given HIR
    public mutating func build(from hir: HIRKind) throws(NFAConstructionError) -> NFA {
        try build(from: [hir])
    }

    // MARK: - HIR Compilation

    private mutating func compileFragments(_ fragments: [NFAFragment]) throws(NFAConstructionError) -> NFAFragment {
        var fragmentIterator = fragments.makeIterator()

        guard let firstFragment = fragmentIterator.next() else {
            let failStateId = try builder.addFail()
            return NFAFragment(start: failStateId, end: failStateId)
        }

        guard let secondFragment = fragmentIterator.next() else {
            return firstFragment
        }

        let union = try builder.addUnion([firstFragment.start, secondFragment.start])
        let end = try builder.addEpsilon()
        try builder.patch(from: firstFragment.end, to: end)
        try builder.patch(from: secondFragment.end, to: end)

        for fragment in fragmentIterator {
            try builder.patch(from: union, to: fragment.start)
            try builder.patch(from: fragment.end, to: end)
        }

        return NFAFragment(start: union, end: end)
    }

    private mutating func compile(_ hir: HIRKind) throws(NFAConstructionError) -> NFAFragment {
        switch hir {
        case .empty:
            try compileEmpty()
        case let .literal(chars):
            try compileLiteral(chars)
        case let .class(charClass):
            try compileClass(charClass)
        case let .concat(children):
            try compileConcat(children.map { child throws(NFAConstructionError) in
                try compile(child)
            })
        case let .alternation(alts):
            try compileAlternation(alts)
        case let .quantification(quant):
            try compileQuantification(quant)
        case let .group(group):
            try compile(group.child)
        }
    }
}

// MARK: - Basic Constructs

extension ThompsonConstruction {
    /// Compiles empty (epsilon) - matches empty string
    private mutating func compileEmpty() throws(NFAConstructionError) -> NFAFragment {
        // Create a placeholder epsilon state that will be patched
        let state = try builder.addEpsilon()
        return NFAFragment(start: state, end: state)
    }
}

extension ThompsonConstruction {
    /// Compiles a literal string by encoding each character as UTF-8 bytes
    private mutating func compileLiteral(_: [Character]) throws(NFAConstructionError) -> NFAFragment {
        // FIXME: literal
        fatalError()
    }
}

extension ThompsonConstruction {
    /// Compiles a character class to byte range transitions
    private mutating func compileClass(_ charClass: CharacterClass) throws(NFAConstructionError) -> NFAFragment {
        if charClass.isAllAscii() {
            try compileASCIIClass(charClass.ranges)
        } else {
            try compileUnicodeClass(charClass.ranges)
        }
    }

    /// Compiles an ASCII-only character class (all single-byte)
    private mutating func compileASCIIClass(
        _ ranges: [ClosedRange<Character>],
    ) throws(NFAConstructionError) -> NFAFragment {
        let end = try builder.addEpsilon()
        var transitions: [Transition] = []
        transitions.reserveCapacity(ranges.count)

        for range in ranges {
            guard let startByte = range.lowerBound.asciiValue,
                  let endByte = range.upperBound.asciiValue
            else {
                throw .invalidOperation(description: "Non-ASCII character found in ASCII class compilation.")
            }

            transitions.append(Transition(start: startByte, end: endByte, next: end))
        }

        let state = try builder.addSparse(transitions)
        return NFAFragment(start: state, end: end)
    }

    /// Compiles a Unicode character class using UTF-8 sequences
    private mutating func compileUnicodeClass(
        _: [ClosedRange<Character>],
    ) throws(NFAConstructionError) -> NFAFragment {
        // Do not compile for reverse and assume shrinked
        // FIXME: unicode class

        fatalError()
    }
}

// MARK: - Concat

extension ThompsonConstruction {
    /// Compiles concatenation
    private mutating func compileConcat(_ fragments: [NFAFragment]) throws(NFAConstructionError) -> NFAFragment {
        guard let firstFragment = fragments.first else {
            return try compileEmpty()
        }

        var end = firstFragment.end

        for fragment in fragments.dropFirst() {
            try builder.patch(from: end, to: fragment.start)
            end = fragment.end
        }

        return .init(
            start: firstFragment.start,
            end: end,
        )
    }
}

// MARK: - Alternation

extension ThompsonConstruction {
    /// Compiles alternation
    private mutating func compileAlternation(_ alternatives: [HIRKind]) throws(NFAConstructionError) -> NFAFragment {
        // let literalCount = alternatives.count { hir in
        //     switch hir {
        //     case .literal: true
        //     default: false
        //     }
        // }

        // TODO: Currently not doing all literal alternative optimization
        // if literalCount <= 1 || literalCount < alternatives.count {
        try compileFragments(
            alternatives.map { alternative throws(NFAConstructionError) in
                try compile(alternative)
            },
        )
        // }
    }
}

// MARK: - Quantification

extension ThompsonConstruction {
    /// Compiles quantification
    private mutating func compileQuantification(_ quant: Quantification) throws(NFAConstructionError) -> NFAFragment {
        let min = quant.min
        let max = quant.max
        let eager = quant.isEager

        switch (min, max) {
        case (0, 1):
            // ? (zero or one)
            return try compileOptional(quant.child, eager: eager)
        case (0, nil):
            // * (zero or more)
            return try compileKleeneStar(quant.child, eager: eager)
        case (1, nil):
            // + (one or more)
            return try compileKleenePlus(quant.child, eager: eager)
        case let (min, nil):
            // {n,} (n or more)
            return try compileAtLeast(quant.child, count: min, eager: eager)
        case let (min, max?) where min == max:
            // {n} (exactly n)
            return try compileExact(quant.child, count: min)
        case let (min, max?):
            // {n,m} (between n and m)
            return try compileRange(quant.child, min: min, max: max, eager: eager)
        }
    }

    /// Compiles optional (?)
    private mutating func compileOptional(_ child: HIRKind, eager: Bool) throws(NFAConstructionError) -> NFAFragment {
        let union = if eager {
            try builder.addUnion()
        } else {
            try builder.addUnionReverse()
        }

        let inner = try compile(child)
        let empty = try builder.addEpsilon()
        try builder.patch(from: union, to: inner.start)
        try builder.patch(from: union, to: empty)
        try builder.patch(from: inner.end, to: empty)

        return .init(
            start: union,
            end: empty,
        )
    }

    /// Compiles Kleene star (*)
    private mutating func compileKleeneStar(_ child: HIRKind, eager: Bool) throws(NFAConstructionError) -> NFAFragment {
        // TODO: compute if the child can match empty strings, optimize if it cannot

        // Special treatment for * that can match empty strings
        let inner = try compile(child)
        let plus = if eager {
            try builder.addUnion()
        } else {
            try builder.addUnionReverse()
        }

        try builder.patch(from: inner.end, to: plus)
        try builder.patch(from: plus, to: inner.start)

        let question = if eager {
            try builder.addUnion()
        } else {
            try builder.addUnionReverse()
        }

        let empty = try builder.addEpsilon()

        try builder.patch(from: question, to: inner.start)
        try builder.patch(from: question, to: empty)
        try builder.patch(from: plus, to: empty)
        return .init(
            start: question,
            end: empty,
        )
    }

    /// Compiles Kleene plus (+)
    private mutating func compileKleenePlus(_ child: HIRKind, eager: Bool) throws(NFAConstructionError) -> NFAFragment {
        let inner = try compile(child)

        let union: NFAStateID = if eager {
            try builder.addUnion()
        } else {
            try builder.addUnionReverse()
        }

        try builder.patch(from: inner.end, to: union)
        try builder.patch(from: union, to: inner.start)

        return .init(
            start: inner.start,
            end: union,
        )
    }

    /// Compiles exact repetition {n}
    private mutating func compileExact(_ child: HIRKind, count: UInt32) throws(NFAConstructionError) -> NFAFragment {
        if count == 0 {
            return try compileEmpty()
        }

        let fragments = try (0 ..< count).map { _ throws(NFAConstructionError) in
            try compile(child)
        }

        return try compileConcat(fragments)
    }

    /// Compiles at-least {n,}
    private mutating func compileAtLeast(
        _ child: HIRKind,
        count: UInt32,
        eager: Bool,
    ) throws(NFAConstructionError) -> NFAFragment {
        let prefix = try compileExact(
            child,
            count: count - 1,
        )
        let last = try compile(child)

        let union: NFAStateID = if eager {
            try builder.addUnion()
        } else {
            try builder.addUnionReverse()
        }

        try builder.patch(from: prefix.end, to: last.start)
        try builder.patch(from: last.end, to: union)
        try builder.patch(from: union, to: last.start)

        return .init(
            start: prefix.start,
            end: union,
        )
    }

    /// Compiles range {n,m}
    private mutating func compileRange(
        _ child: HIRKind,
        min: UInt32,
        max: UInt32,
        eager: Bool,
    ) throws(NFAConstructionError) -> NFAFragment {
        let prefix = try compileExact(child, count: min)
        if min == max {
            return prefix
        }

        let empty = try builder.addEpsilon()
        var previousEnd = prefix.end

        for _ in min ..< max {
            let union = if eager {
                try builder.addUnion()
            } else {
                try builder.addUnionReverse()
            }

            let inner = try compile(child)

            try builder.patch(from: previousEnd, to: union)
            try builder.patch(from: union, to: inner.start)
            try builder.patch(from: union, to: empty)
            previousEnd = inner.end
        }

        try builder.patch(from: previousEnd, to: empty)

        return .init(
            start: prefix.start,
            end: previousEnd,
        )
    }
}

// MARK: - NFA Convenience

public extension NFA {
    /// Builds an NFA from HIR using Thompson's construction
    static func build(from hir: HIRKind) throws(NFAConstructionError) -> NFA {
        var construction = ThompsonConstruction()
        return try construction.build(from: hir)
    }
}
