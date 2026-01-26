//
//  Misc.swift
//  Kaleidoscope
//
//  Created by Larry Zeng on 1/13/26.
//

@testable import KaleidoscopeMacros
import MacroTesting
import SwiftSyntaxMacros
import Testing

let macros: [String: Macro.Type] = [
    "kaleidoscope": KaleidoscopeBuilder.self,
    "Kaleidoscope": KaleidoscopeBuilderNext.self,
    "token": EnumCaseRegistry.self,
    "regex": EnumCaseRegistry.self,
]

@Suite(.macros(macros, record: .failed))
struct KaleidoscopeMacroTests {}
