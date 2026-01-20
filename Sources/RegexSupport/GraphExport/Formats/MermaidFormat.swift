//
//  MermaidFormat.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/17/26.
//

// MARK: - Mermaid Format

struct MermaidFormat: GraphExportFormatWriter {
    static func writeHeader(_ output: inout String) {
        output += "flowchart LR\n"
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
        case .ellipse:
            output += "\(id)([\"\(label)\"])\n"
        case .doubleCircle:
            output += "\(id)(((\"\(label)\")))\n"
        }
        output += "style \(id) stroke:\(color.mermaidValue)\n"
    }

    static func writeLink(_ output: inout String, from: String, to: String, label: String?) {
        if let label {
            output += "\(from)-->|\"\(label)\"|\(to)\n"
        } else {
            output += "\(from)-->\(to)\n"
        }
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
