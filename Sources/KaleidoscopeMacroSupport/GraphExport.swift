//
//  GraphExport.swift
//
//
//  Created by Larry Zeng on 1/14/26.
//

// MARK: - Export Format

/// Output format for graph export
public enum GraphExportFormat: Sendable {
    case dot
    case mermaid
}

// MARK: - Node Styling

private enum NodeColor {
    case black
    case green

    var dotValue: String {
        switch self {
        case .black: "black"
        case .green: "green"
        }
    }

    var mermaidValue: String {
        switch self {
        case .black: "#000000"
        case .green: "#00C853"
        }
    }
}

private enum NodeShape {
    case rectangle
    case rhombus
}

// MARK: - Export Format Protocol

private protocol ExportFormatWriter {
    static func writeHeader(_ output: inout String)
    static func writeFooter(_ output: inout String)
    static func writeNode(
        _ output: inout String,
        id: String,
        label: String,
        color: NodeColor,
        shape: NodeShape,
    )
    static func writeLink(_ output: inout String, from: String, to: String)
    static func escape(_ string: String) -> String
}

// MARK: - Dot Format

private struct DotFormat: ExportFormatWriter {
    static func writeHeader(_ output: inout String) {
        output += "digraph {\n"
        output += "node[shape=box];\n"
        output += "splines=ortho;\n"
    }

    static func writeFooter(_ output: inout String) {
        output += "}\n"
    }

    static func writeNode(
        _ output: inout String,
        id: String,
        label: String,
        color: NodeColor,
        shape: NodeShape,
    ) {
        let shapeStr = switch shape {
        case .rectangle: "box"
        case .rhombus: "diamond"
        }
        output += "\(id)[label=\"\(label)\",color=\(color.dotValue),shape=\(shapeStr)];\n"
    }

    static func writeLink(_ output: inout String, from: String, to: String) {
        output += "\(from)->\(to);\n"
    }

    static func escape(_ string: String) -> String {
        var result = ""
        for char in string {
            switch char {
            case "\"": result += "\\\""
            case "\\": result += "\\\\"
            case "\n": result += "\\n"
            case "\r": result += "\\r"
            case "\t": result += "\\t"
            default:
                if char.asciiValue == nil || !char.isASCII {
                    for byte in String(char).utf8 {
                        result += String(format: "\\x%02X", byte)
                    }
                } else {
                    result.append(char)
                }
            }
        }
        return result
    }
}

// MARK: - Mermaid Format

private struct MermaidFormat: ExportFormatWriter {
    static func writeHeader(_ output: inout String) {
        output += "flowchart TB\n"
    }

    static func writeFooter(_: inout String) {
        // No footer needed for mermaid
    }

    static func writeNode(
        _ output: inout String,
        id: String,
        label: String,
        color: NodeColor,
        shape: NodeShape,
    ) {
        switch shape {
        case .rectangle:
            output += "\(id)[\"\(label)\"]\n"
        case .rhombus:
            output += "\(id){\"\(label)\"}\n"
        }
        output += "style \(id) stroke:\(color.mermaidValue)\n"
    }

    static func writeLink(_ output: inout String, from: String, to: String) {
        output += "\(from)-->\(to)\n"
    }

    static func escape(_ string: String) -> String {
        var result = ""
        for char in string {
            switch char {
            case "\"": result += "&quot;"
            case "\\": result += "\\\\"
            case "\n": result += "<br>"
            default:
                if char.asciiValue == nil || !char.isASCII {
                    for byte in String(char).utf8 {
                        result += String(format: "\\x%02X", byte)
                    }
                } else {
                    result.append(char)
                }
            }
        }
        return result
    }
}

// MARK: - Graph Export Extension

public extension Graph {
    /// Export the graph to DOT format (Graphviz)
    func exportToDot() -> String {
        exportGraph(format: DotFormat.self)
    }

    /// Export the graph to Mermaid format
    func exportToMermaid() -> String {
        exportGraph(format: MermaidFormat.self)
    }

    /// Export the graph to the specified format
    func export(to format: GraphExportFormat) -> String {
        switch format {
        case .dot:
            exportToDot()
        case .mermaid:
            exportToMermaid()
        }
    }

    private func exportGraph<Format: ExportFormatWriter>(format _: Format.Type) -> String {
        var output = ""
        Format.writeHeader(&output)

        // Generate node IDs and collect node info
        for (index, node) in nodes.enumerated() {
            guard let node else { continue }

            let nodeId = "n\(index)"
            let isRoot = rootId == NodeId(index)
            let (label, nodeColor) = nodeLabel(for: node, at: index, isRoot: isRoot, format: Format.self)

            Format.writeNode(&output, id: nodeId, label: label, color: nodeColor, shape: .rectangle)

            // Write edges based on node type
            writeEdges(for: node, from: nodeId, output: &output, format: Format.self)
        }

        Format.writeFooter(&output)
        return output
    }

    private func nodeLabel<Format: ExportFormatWriter>(
        for node: Node,
        at index: Int,
        isRoot: Bool,
        format _: Format.Type,
    ) -> (String, NodeColor) {
        let prefix = isRoot ? "Root " : ""
        switch node {
        case let .leaf(content):
            let input = inputs[content.endId]
            let label = Format.escape("\(prefix)Node \(index)<br/>leaf(\(input.token))")
            return (label, .green)
        case .branch:
            let label = Format.escape("\(prefix)Node \(index)")
            return (label, .black)
        case .seq:
            let label = Format.escape("\(prefix)Node \(index)")
            return (label, .black)
        }
    }

    private func writeEdges<Format: ExportFormatWriter>(
        for node: Node,
        from nodeId: String,
        output: inout String,
        format _: Format.Type,
    ) {
        switch node {
        case .leaf:
            // Leaf nodes have no outgoing edges
            break
        case let .branch(content):
            // Write branch edges
            for (range, targetId) in content.branches.sorted(by: { $0.key.lowerBound < $1.key.lowerBound }) {
                let targetNodeId = "n\(targetId)"
                let edgeId = "e\(nodeId)\(targetNodeId)_\(range.lowerBound)"
                let edgeLabel = Format.escape(formatRange(range))
                Format.writeNode(&output, id: edgeId, label: edgeLabel, color: .black, shape: .rhombus)
                Format.writeLink(&output, from: nodeId, to: edgeId)
                Format.writeLink(&output, from: edgeId, to: targetNodeId)
            }
            // Write miss edge if present
            if let missId = content.miss {
                let targetNodeId = "n\(missId)"
                let edgeId = "e\(nodeId)\(targetNodeId)_miss"
                Format.writeNode(&output, id: edgeId, label: "miss", color: .black, shape: .rhombus)
                Format.writeLink(&output, from: nodeId, to: edgeId)
                Format.writeLink(&output, from: edgeId, to: targetNodeId)
            }
        case let .seq(content):
            // Write sequence edge to then
            let targetNodeId = "n\(content.then)"
            let edgeId = "e\(nodeId)\(targetNodeId)"
            let seqStr = content.seq.map { formatByte($0) }.joined()
            let edgeLabel = Format.escape(seqStr)
            Format.writeNode(&output, id: edgeId, label: edgeLabel, color: .black, shape: .rhombus)
            Format.writeLink(&output, from: nodeId, to: edgeId)
            Format.writeLink(&output, from: edgeId, to: targetNodeId)
            // Write miss edge if present
            if let miss = content.miss {
                let missNodeId = "n\(miss.miss)"
                let missEdgeId = "e\(nodeId)\(missNodeId)_miss"
                let missLabel = switch miss {
                case .first: "miss(first)"
                case .anytime: "miss(any)"
                }
                Format.writeNode(&output, id: missEdgeId, label: missLabel, color: .black, shape: .rhombus)
                Format.writeLink(&output, from: nodeId, to: missEdgeId)
                Format.writeLink(&output, from: missEdgeId, to: missNodeId)
            }
        }
    }

    private func formatRange(_ range: HIR.ScalarByteRange) -> String {
        if range.lowerBound == range.upperBound {
            formatByte(range.lowerBound)
        } else {
            "\(formatByte(range.lowerBound))...\(formatByte(range.upperBound))"
        }
    }

    private func formatByte(_ byte: HIR.ScalarByte) -> String {
        if byte >= 0x20, byte < 0x7F {
            // Printable ASCII
            let scalar = Unicode.Scalar(byte)!
            let char = Character(scalar)
            switch char {
            case "\"": return "\\\""
            case "\\": return "\\\\"
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
