//
//  GraphFormatWriter.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/17/26.
//

// MARK: - Export Format Protocol

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
    static func writeLink(_ output: inout String, from: String, to: String, label: String?)
    static func escape(_ string: String) -> String
}

// MARK: - Node Styling

enum GraphNodeColor {
    case black
    case green
    case red
    case blue

    var dotValue: String {
        switch self {
        case .black: "black"
        case .green: "green"
        case .red: "red"
        case .blue: "blue"
        }
    }

    var mermaidValue: String {
        switch self {
        case .black: "#000000"
        case .green: "#00C853"
        case .red: "#D50000"
        case .blue: "#2962FF"
        }
    }
}

enum GraphNodeShape {
    case rectangle
    case rhombus
    case ellipse
    case doubleCircle
}
