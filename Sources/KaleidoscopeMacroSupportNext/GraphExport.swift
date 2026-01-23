import RegexSupport

// MARK: - Graph Export Protocol

protocol GraphExportFormatWriter {
    static func writeHeader(_ output: inout String)
    static func writeFooter(_ output: inout String)
    static func writeNode(
        _ output: inout String,
        id: String,
        label: String,
        color: GraphNodeColor,
        shape: GraphNodeShape,
    )
    static func writeLink(_ output: inout String, from: String, to: String)
    static func escape(_ string: String) -> String
}

// MARK: - Node Styling

enum GraphNodeColor {
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

enum GraphNodeShape {
    case rectangle
    case rhombus
}

// MARK: - Dot Format

struct DotFormat: GraphExportFormatWriter {
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
        color: GraphNodeColor,
        shape: GraphNodeShape,
    ) {
        let shapeStr =
            switch shape {
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

private extension ByteClass {
    func formatDescription() -> String {
        if ranges.isEmpty {
            return "<empty>"
        }

        return ranges.map { range -> String in
            let lower = range.lowerBound
            let upper = range.upperBound

            if lower == upper {
                return formatByte(lower)
            } else {
                return "\(formatByte(lower))..=\(formatByte(upper))"
            }
        }.joined(separator: ", ")
    }
}

private func formatByte(_ byte: UInt8) -> String {
    let ascii = Int(byte)
    if ascii >= 32, ascii < 127, let scalar = UnicodeScalar(ascii) {
        let char = Character(scalar)
        if char == "\"" || char == "\\" {
            return "\\\(char)"
        }
        return String(char)
    }

    switch byte {
    case 10: return "\\n"
    case 13: return "\\r"
    case 9: return "\\t"
    default:
        return String(format: "\\x%02X", byte)
    }
}

// MARK: - Mermaid Format

struct MermaidFormat: GraphExportFormatWriter {
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
        color: GraphNodeColor,
        shape: GraphNodeShape,
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

// MARK: - Graph Export

public extension Graph {
    /// Exports the graph to a DOT format string.
    func exportDot() -> String {
        exportGraph(DotFormat.self)
    }

    /// Exports the graph to a Mermaid format string.
    func exportMermaid() -> String {
        exportGraph(MermaidFormat.self)
    }

    private func exportGraph<Fmt: GraphExportFormatWriter>(_: Fmt.Type) -> String {
        var output = ""

        let shapeIds = states().map { state in
            "n\(state.id)"
        }

        let shapeNames = states().map { state in
            let stateId = state.id
            let stateData = getStateData(state)
            let rendered = if let earlyLeafId = stateData.type.early {
                "State \(stateId)\nearly(\(earlyLeafId.id))"
            } else if let acceptLeafId = stateData.type.accept {
                "State \(stateId)\nlate(\(acceptLeafId.id))"
            } else {
                "State \(stateId)"
            }

            return Fmt.escape(rendered)
        }

        Fmt.writeHeader(&output)

        for state in states() {
            let data = getStateData(state)

            let id = shapeIds[state.id]
            let label = shapeNames[state.id]
            let color: GraphNodeColor = data.type.earlyOrAccept != nil ? .green : .black

            Fmt.writeNode(&output, id: id, label: label, color: color, shape: .rectangle)

            for normal in data.normal {
                let byteClassLabel = Fmt.escape(normal.byteClass.formatDescription())
                let toId = shapeIds[normal.state.id]
                let edgeId = "e\(id)\(toId)"

                Fmt.writeNode(
                    &output, id: edgeId, label: byteClassLabel, color: .black, shape: .rhombus,
                )
                Fmt.writeLink(&output, from: id, to: edgeId)
                Fmt.writeLink(&output, from: edgeId, to: toId)
            }
        }

        Fmt.writeFooter(&output)

        return output
    }
}
