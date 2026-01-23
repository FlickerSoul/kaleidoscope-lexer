public enum GraphError: Error, Hashable, Sendable {
    case multipleLeavesWithSamePriority(Set<LeafID>, priority: UInt)
}
