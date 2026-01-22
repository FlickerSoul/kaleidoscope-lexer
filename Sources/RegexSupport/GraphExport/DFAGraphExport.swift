//
//  DFAGraphExport.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/17/26.
//

// MARK: - DFA Graph Export Extension

extension DFA {
    /// Export the DFA to DOT format (Graphviz)
    public func exportToDot() -> String {
        exportGraph(format: DotFormat.self)
    }

    /// Export the DFA to Mermaid format
    public func exportToMermaid() -> String {
        exportGraph(format: MermaidFormat.self)
    }

    /// Export the DFA to the specified format
    public func export(to format: GraphExportFormat) -> String {
        switch format {
        case .dot:
            exportToDot()
        case .mermaid:
            exportToMermaid()
        }
    }

    private func exportGraph<Format: GraphExportFormatWriter>(format _: Format.Type) -> String {
        var output = ""
        Format.writeHeader(&output)

        // Generate nodes and edges
        for (index, state) in states.enumerated() {
            let stateId = DFAStateID(UInt32(index))
            let nodeId = "d\(index)"
            let isStart = stateId == start
            let (label, nodeColor, nodeShape) = nodeInfo(
                for: state, at: index, isStart: isStart, format: Format.self,
            )

            Format.writeNode(&output, id: nodeId, label: label, color: nodeColor, shape: nodeShape)

            // Write edges based on transitions
            writeEdges(for: state, from: nodeId, output: &output, format: Format.self)
        }

        Format.writeFooter(&output)
        return output
    }

    private func nodeInfo<Format: GraphExportFormatWriter>(
        for state: DFAState,
        at index: Int,
        isStart: Bool,
        format _: Format.Type,
    ) -> (String, GraphNodeColor, GraphNodeShape) {
        let prefix = isStart ? "START " : ""

        if state.isMatch {
            let label = Format.escape("\(prefix)D\(index) (match)")
            return (label, .green, .doubleCircle)
        } else {
            let label = Format.escape("\(prefix)D\(index)")
            return (label, .black, .ellipse)
        }
    }

    private func writeEdges<Format: GraphExportFormatWriter>(
        for state: DFAState,
        from nodeId: String,
        output: inout String,
        format _: Format.Type,
    ) {
        // Group transitions by target state to reduce edge count
        let groupedTransitions = groupTransitions(state.transitions)

        for (targetId, ranges) in groupedTransitions {
            // Skip dead state transitions
            guard targetId != .dead else { continue }

            let targetNodeId = "d\(targetId.id)"
            let edgeLabel = Format.escape(formatRanges(ranges))
            Format.writeLink(&output, from: nodeId, to: targetNodeId, label: edgeLabel)
        }
    }

    /// Groups consecutive byte values that transition to the same state
    private func groupTransitions(_ transitions: [DFAStateID]) -> [(DFAStateID, [(UInt8, UInt8)])] {
        var result: [(DFAStateID, [(UInt8, UInt8)])] = []
        var currentTarget: DFAStateID?
        var rangeStart: UInt8 = 0
        var rangeEnd: UInt8 = 0
        var ranges: [(UInt8, UInt8)] = []

        for byte in 0 ..< 256 {
            let target = transitions[byte]

            if target == currentTarget {
                // Extend current range
                rangeEnd = UInt8(byte)
            } else {
                // Save previous range if exists
                if let current = currentTarget {
                    ranges.append((rangeStart, rangeEnd))
                    if target != current {
                        result.append((current, ranges))
                        ranges = []
                    }
                }

                // Start new range
                currentTarget = target
                rangeStart = UInt8(byte)
                rangeEnd = UInt8(byte)
            }
        }

        // Don't forget the last range
        if let current = currentTarget {
            ranges.append((rangeStart, rangeEnd))
            result.append((current, ranges))
        }

        return result
    }

    private func formatRanges(_ ranges: [(UInt8, UInt8)]) -> String {
        ranges.map { formatRange($0.0, $0.1) }.joined(separator: ", ")
    }

    private func formatRange(_ start: UInt8, _ end: UInt8) -> String {
        if start == end {
            formatByte(start)
        } else {
            "\(formatByte(start))-\(formatByte(end))"
        }
    }

    private func formatByte(_ byte: UInt8) -> String {
        if byte >= 0x20, byte < 0x7F {
            // Printable ASCII
            let scalar = Unicode.Scalar(byte)
            let char = Character(scalar)
            switch char {
            case "\"": return "\\\""
            case "\\": return "\\\\"
            case "-": return "\\-"
            default: return String(char)
            }
        } else {
            // Non-printable, use escape sequence
            switch byte {
            case 0x09: return "\\t"
            case 0x0A: return "\\n"
            case 0x0D: return "\\r"
            default: return String(format: "\\x%02X", byte)
            }
        }
    }
}
