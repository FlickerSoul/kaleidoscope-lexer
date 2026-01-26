//
//  KaleidoscopeError.swift
//
//
//  Created by Larry Zeng on 11/25/23.
//

import Foundation
import SwiftDiagnostics

enum KaleidoscopeError: Error {
    case syntaxError
    case notAnEnum
    case multipleMacroDeclaration
    case parsingError
    case expectingString
    case expectingIntegerLiteral
    case onlyFillOrCreateCallbackIsAllowed

    // new cases
    case macroInfoError
    case graphCompositionError
}

extension KaleidoscopeError: DiagnosticMessage {
    var message: String {
        switch self {
        case .syntaxError: "Syntax error encountered."
        case .notAnEnum: "@kaleidoscope can only be applied to enums."
        case .multipleMacroDeclaration: "Multiple @kaleidoscope declarations found on the same enum."
        case .parsingError: "Error parsing macro arguments."
        case .expectingString: "Expected a string literal."
        case .expectingIntegerLiteral: "Expected an integer literal."
        case .onlyFillOrCreateCallbackIsAllowed: "Only 'fillCallback' or 'createCallback' options are allowed, not both."
        case .macroInfoError: "Error processing macro information. Please check specific error messages."
        case .graphCompositionError: "Error composing the lexer graph. Please check specific error messages."
        }
    }

    var diagnosticID: SwiftDiagnostics.MessageID {
        .init(domain: "observer.universe.kaleidoscope-lexer", id: "KaleidoscopeError")
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        .error
    }
}
