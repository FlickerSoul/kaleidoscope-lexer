//
//  NFAGraphExport.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/16/26.
//

// MARK: - NFA Graph Export Extension

public extension NFA {
    /// Export the NFA to DOT format (Graphviz)
    func exportToDot() -> String {
        export(to: .dot)
    }

    /// Export the NFA to Mermaid format
    func exportToMermaid() -> String {
        export(to: .mermaid)
    }

    /// Export the NFA to the specified format
    func export(to format: GraphExportFormat) -> String {
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
            let stateId = NFAStateID(UInt32(index))
            let nodeId = "s\(index)"
            let isStart = stateId == start
            let (label, nodeColor, nodeShape) = nodeInfo(for: state, at: index, isStart: isStart, format: Format.self)

            Format.writeNode(&output, id: nodeId, label: label, color: nodeColor, shape: nodeShape)

            // Write edges based on state type
            writeEdges(for: state, from: nodeId, output: &output, format: Format.self)
        }

        Format.writeFooter(&output)
        return output
    }

    private func nodeInfo<Format: GraphExportFormatWriter>(
        for state: NFAState,
        at index: Int,
        isStart: Bool,
        format _: Format.Type,
    ) -> (String, GraphNodeColor, GraphNodeShape) {
        let prefix = isStart ? "START " : ""

        switch state {
        case .byteRange:
            let label = Format.escape("\(prefix)S\(index)")
            return (label, .black, .ellipse)

        case .sparse:
            let label = Format.escape("\(prefix)S\(index)")
            return (label, .black, .ellipse)

        case .union, .binaryUnion:
            let label = Format.escape("\(prefix)S\(index)")
            return (label, .blue, .rhombus)

        case .match:
            let label = Format.escape("\(prefix)S\(index) (match)")
            return (label, .green, .doubleCircle)

        case .fail:
            let label = Format.escape("\(prefix)S\(index) (fail)")
            return (label, .red, .rectangle)
        }
    }

    private func writeEdges<Format: GraphExportFormatWriter>(
        for state: NFAState,
        from nodeId: String,
        output: inout String,
        format _: Format.Type,
    ) {
        switch state {
        case let .byteRange(transition):
            let targetNodeId = "s\(transition.next.id)"
            let edgeLabel = Format.escape(formatTransition(transition))
            Format.writeLink(&output, from: nodeId, to: targetNodeId, label: edgeLabel)

        case let .sparse(transitions):
            for transition in transitions {
                let targetNodeId = "s\(transition.next.id)"
                let edgeLabel = Format.escape(formatTransition(transition))
                Format.writeLink(&output, from: nodeId, to: targetNodeId, label: edgeLabel)
            }

        case let .union(alternatives):
            for alt in alternatives {
                let targetNodeId = "s\(alt.id)"
                Format.writeLink(&output, from: nodeId, to: targetNodeId, label: nil)
            }

        case let .binaryUnion(first, second):
            let firstNodeId = "s\(first.id)"
            let secondNodeId = "s\(second.id)"
            Format.writeLink(&output, from: nodeId, to: firstNodeId, label: nil)
            Format.writeLink(&output, from: nodeId, to: secondNodeId, label: nil)

        case .match, .fail:
            // Terminal states have no outgoing edges
            break
        }
    }

    private func formatTransition(_ transition: Transition) -> String {
        if transition.start == transition.end {
            formatByte(transition.start)
        } else {
            "\(formatByte(transition.start))-\(formatByte(transition.end))"
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
