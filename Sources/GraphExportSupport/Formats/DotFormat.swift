//
//  DotFormat.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/17/26.
//
import Foundation

public struct DotFormat: GraphExportFormatWriter {
    public static func writeHeader(_ output: inout String) {
        output += "digraph {\n"
        output += "node[shape=box];\n"
        output += "splines=ortho;\n"
    }

    public static func writeFooter(_ output: inout String) {
        output += "}\n"
    }

    public static func writeNode(
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

    public static func writeLink(_ output: inout String, from: String, to: String, label: String?) {
        if let label {
            output += "\(from)->\(to)[label=\"\(label)\"];\n"
        } else {
            output += "\(from)->\(to);\n"
        }
    }

    public static func escape(_ string: String) -> String {
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
