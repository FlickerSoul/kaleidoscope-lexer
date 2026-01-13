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
        } expansion: {
            """
            enum Test {
                case a
                case b
            }

            extension Test: Kaleidoscope.LexerProtocol {
                typealias TokenType = Self
                typealias RawSource = String
                public static func lex(_ lexer: inout Kaleidoscope.LexerMachine<Self>) throws {
                    func jumpTo_0(_ lexer: inout LexerMachine<Self>) throws {
                        guard let scalar = lexer.peak() else {
                            try lexer.error()
                            return
                        }
                        switch scalar {
                        case 98:
                            try lexer.bump()
                            try jumpTo_1(&lexer)
                        case 97:
                            try lexer.bump()
                            try jumpTo_2(&lexer)
                        case _:
                            try lexer.error()
                        }
                    }
                    func jumpTo_1(_ lexer: inout LexerMachine<Self>) throws {
                        try lexer.setToken(Test.b)
                    }
                    func jumpTo_2(_ lexer: inout LexerMachine<Self>) throws {
                        try lexer.setToken(Test.a)
                    }
                    try jumpTo_0(&lexer)
                }
                public static func lexer(source: RawSource) -> Kaleidoscope.LexerMachine<Self> {
                    return Kaleidoscope.LexerMachine(raw: source)
                }
            }

            extension Test: Kaleidoscope.Into {
                public typealias IntoType = Kaleidoscope.TokenResult<Test>
                public func into() -> IntoType {
                    return .result(self)
                }
            }
            """
        }
    }
}
