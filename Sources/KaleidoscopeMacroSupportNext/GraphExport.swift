import GraphExportSupport
import RegexSupport

// MARK: - ByteClass Formatting

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
                Fmt.writeLink(&output, from: id, to: edgeId, label: nil)
                Fmt.writeLink(&output, from: edgeId, to: toId, label: nil)
            }
        }

        Fmt.writeFooter(&output)

        return output
    }
}
