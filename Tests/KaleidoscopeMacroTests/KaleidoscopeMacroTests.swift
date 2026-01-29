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
            #"""
            @Kaleidoscope
            enum Test {
                @regex(/a/)
                case a

                @regex(/b/)
                case b
            }
            """#
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
                    enum __KaleidoscopeLeaves: Int {
                        case leaf0 = 0
                        case leaf1 = 1
                    }
                    func __getAction(lexer: inout Kaleidoscope.LexerMachine<Test>, offset: Int, context: __KaleidoscopeLeaves?) -> Kaleidoscope._CallbackResult<Test> {
                        switch context {
                        case nil:
                            lexer.end_to_boundary(Swift.max(offset, lexer.offset() + 1))
                            return Kaleidoscope._CallbackResult.defaultError
                        case leaf0:
                            return .Kaleidoscope._CallbackResult.emit(Test.a)
                        case leaf1:
                            return .Kaleidoscope._CallbackResult.emit(Test.b)
                        }
                    }
                    func jumpTo_0(_ lexer: inout Kaleidoscope.LexerMachine<Test>, _ offset: Int, _ context: __KaleidoscopeLeaves?) throws {
                        var offset = offset
                        var context = context
                        let other = try lexer.read(offset: offset)
                        if let other {
                            enum NextState {
                                case jumpTo_1
                                case jumpTo_2
                                case __none
                            }
                            let nextState: NextState?
                            offset += 1
                            switch byte {
                            case 97:
                                nextState = jumpTo_1
                            case 98:
                                nextState = jumpTo_2
                            default:
                                nextState = nil
                            }
                            switch nextState {
                            case .jumpTo_1:
                                return try jumpTo_1(&lexer, offset, context)
                            case .jumpTo_2:
                                return try jumpTo_2(&lexer, offset, context)
                            case .__none
                                break
                            }
                            offset -= 1
                        } else {
                            if lexer.offset() == offset {
                                return nil
                            }
                        }
                        let action = __getAction(lexer: &lexer, offset: offset, context: context)
                        switch action {
                        case .emit(let token):
                            return .success(token)
                        case .skip:
                            lexer.trivia()
                            offset = lexer.offset()
                            context = nil
                            return jumpTo_0(lexer, offset, context)
                        case .error(let error):
                            return .failure(error)
                        case .defaultError:
                            return .failure(NSError(domain: "Kaleidoscope", code: -1, userInfo: nil))
                        }
                    }
                    func jumpTo_1(_ lexer: inout Kaleidoscope.LexerMachine<Test>, _ offset: Int, _ context: __KaleidoscopeLeaves?) throws {
                        var offset = offset
                        var context = context
                        lexer.end(at: offset - 1)
                        context = .leaf0
                        let other = try lexer.read(offset: offset)
                        if let other {
                            enum NextState {
                                case __none
                            }
                            let nextState: NextState?
                            offset += 1
                            switch byte {
                            default:
                                nextState = nil
                            }
                            switch nextState {
                            case .__none
                                break
                            }
                            offset -= 1
                        } else {
                        }
                        let action = __getAction(lexer: &lexer, offset: offset, context: context)
                        switch action {
                        case .emit(let token):
                            return .success(token)
                        case .skip:
                            lexer.trivia()
                            offset = lexer.offset()
                            context = nil
                            return jumpTo_0(lexer, offset, context)
                        case .error(let error):
                            return .failure(error)
                        case .defaultError:
                            return .failure(NSError(domain: "Kaleidoscope", code: -1, userInfo: nil))
                        }
                    }
                    func jumpTo_2(_ lexer: inout Kaleidoscope.LexerMachine<Test>, _ offset: Int, _ context: __KaleidoscopeLeaves?) throws {
                        var offset = offset
                        var context = context
                        lexer.end(at: offset - 1)
                        context = .leaf1
                        let other = try lexer.read(offset: offset)
                        if let other {
                            enum NextState {
                                case __none
                            }
                            let nextState: NextState?
                            offset += 1
                            switch byte {
                            default:
                                nextState = nil
                            }
                            switch nextState {
                            case .__none
                                break
                            }
                            offset -= 1
                        } else {
                        }
                        let action = __getAction(lexer: &lexer, offset: offset, context: context)
                        switch action {
                        case .emit(let token):
                            return .success(token)
                        case .skip:
                            lexer.trivia()
                            offset = lexer.offset()
                            context = nil
                            return jumpTo_0(lexer, offset, context)
                        case .error(let error):
                            return .failure(error)
                        case .defaultError:
                            return .failure(NSError(domain: "Kaleidoscope", code: -1, userInfo: nil))
                        }
                    }
                    try jumpTo_0(&lexer, lexer.offset(), nil)
                }
            }
            """
        }
    }
}
