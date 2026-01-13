//
//  Errors.swift
//
//
//  Created by Larry Zeng on 11/25/23.
//

import Foundation

enum KaleidoscopeError: Error {
    case syntaxError
    case notAnEnum
    case multipleMacroDeclaration
    case parsingError
    case expectingString
    case expectingIntegerLiteral
    case onlyFillOrCreateCallbackIsAllowed
}
