//
//  CaseRegistryMacro.swift
//
//
//  Created by Larry Zeng on 11/26/23.
//

import Foundation
import KaleidoscopeMacroSupport
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: - Enum Case Token Registry

/// This macro is used for declaring @regex, @token, and @skip macros.
/// This peer macro is intended to be left blank and does not introduce any peers.
public struct EnumCaseRegistry: PeerMacro {
    public static func expansion(
        of _: SwiftSyntax.AttributeSyntax,
        providingPeersOf _: some SwiftSyntax.DeclSyntaxProtocol,
        in _: some SwiftSyntaxMacros.MacroExpansionContext,
    ) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}
