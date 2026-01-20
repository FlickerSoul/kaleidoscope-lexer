//
//  DotFormat.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/17/26.
//

// MARK: - Dot Format

struct DotFormat: GraphExportFormatWriter {
    static func writeHeader(_ output: inout String) {
        output += "digraph NFA {\n"
        output += "rankdir=LR;\n"
        output += "node[shape=circle];\n"
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
        let shapeStr = switch shape {
        case .rectangle: "box"
        case .rhombus: "diamond"
        case .ellipse: "ellipse"
        case .doubleCircle: "doublecircle"
        }
        output += "\(id)[label=\"\(label)\",color=\(color.dotValue),shape=\(shapeStr)];\n"
    }

    static func writeLink(_ output: inout String, from: String, to: String, label: String?) {
        if let label {
            output += "\(from)->\(to)[label=\"\(label)\"];\n"
        } else {
            output += "\(from)->\(to);\n"
        }
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
