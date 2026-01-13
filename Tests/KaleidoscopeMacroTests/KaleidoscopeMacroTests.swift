//
//  KaleidoscopeMacroTests.swift
//  Kaleidoscope
//
//  Created by Larry Zeng on 1/13/26.
//
import MacroTesting
import Testing

extension KaleidoscopeMacroTests {
    @Test
    func `successful generation`() {
        assertMacro {
            """
            @kaleidoscope
            enum Test {
                @regex("a")
                case a

                @regex("b")
                case b
            }
            """
        }
    }
}
