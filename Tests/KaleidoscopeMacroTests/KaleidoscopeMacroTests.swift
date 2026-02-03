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
            @skip(" ")
            @skip(/[\\n\\t]/)
            enum Test {
                @regex(/a/)
                case a

                @regex(/b/)
                case b
            }
            """#
        } expansion: {
            #"""
            enum Test {
                case a
                case b
            }

            extension Test: KaleidoscopeLexer.LexerTokenProtocol {
                public typealias Source = String
                public typealias UserError = Never
                public static func lex(_ lexer: inout KaleidoscopeLexer.LexerMachine<Test>) -> Test.LexerOutput? {
                    let __macro_local_5leaf0fMu_: Swift.Int = 0
                    let __macro_local_5leaf1fMu_: Swift.Int = 1
                    let __macro_local_5leaf2fMu_: Swift.Int = 2
                    let __macro_local_5leaf3fMu_: Swift.Int = 3
                    func __macro_local_11__getActionfMu_(lexer: inout KaleidoscopeLexer.LexerMachine<Test>, offset: Int, context: Swift.Int?) -> KaleidoscopeLexer._CallbackResult<Test> {
                        guard let context else  {
                            lexer.endToBoundary(offset: Swift.max(offset, lexer.offset() + 1))
                            return KaleidoscopeLexer._CallbackResult.defaultError
                        }
                        switch context {
                        case __macro_local_5leaf0fMu_:
                            return KaleidoscopeLexer._CallbackResult.skip
                        case __macro_local_5leaf1fMu_:
                            return KaleidoscopeLexer._CallbackResult.skip
                        case __macro_local_5leaf2fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(Test.a)
                        case __macro_local_5leaf3fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(Test.b)
                        default:
                            fatalError("Invalid leaf identifier. Unknown leaf \(context)")
                        }
                    }
                    func jumpTo_0(_ lexer: inout KaleidoscopeLexer.LexerMachine<Test>, _ offset: Int, _ context: Swift.Int?) -> Result<Test, Test.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x20 ..< 0x21:
                                return jumpTo_1(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5C ..< 0x5D:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x62:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x62 ..< 0x63:
                                return jumpTo_4(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6E ..< 0x6F:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x74 ..< 0x75:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
                            if lexer.offset() == __macro_local_6offsetfMu_ {
                                return nil
                            }
                        }
                        let action = __macro_local_11__getActionfMu_(lexer: &lexer, offset: __macro_local_6offsetfMu_, context: __macro_local_7contextfMu_)
                        switch action {
                        case .emit(let token):
                            return .success(token)
                        case .skip:
                            lexer.trivia()
                            __macro_local_6offsetfMu_ = lexer.offset()
                            __macro_local_7contextfMu_ = nil
                            return jumpTo_0(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                        case .error(let error):
                            return .failure(.userError(error))
                        case .defaultError:
                            return .failure(.lexerError)
                        }
                    }
                    func jumpTo_1(_ lexer: inout KaleidoscopeLexer.LexerMachine<Test>, _ offset: Int, _ context: Swift.Int?) -> Result<Test, Test.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf0fMu_
                        let action = __macro_local_11__getActionfMu_(lexer: &lexer, offset: __macro_local_6offsetfMu_, context: __macro_local_7contextfMu_)
                        switch action {
                        case .emit(let token):
                            return .success(token)
                        case .skip:
                            lexer.trivia()
                            __macro_local_6offsetfMu_ = lexer.offset()
                            __macro_local_7contextfMu_ = nil
                            return jumpTo_0(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                        case .error(let error):
                            return .failure(.userError(error))
                        case .defaultError:
                            return .failure(.lexerError)
                        }
                    }
                    func jumpTo_2(_ lexer: inout KaleidoscopeLexer.LexerMachine<Test>, _ offset: Int, _ context: Swift.Int?) -> Result<Test, Test.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let action = __macro_local_11__getActionfMu_(lexer: &lexer, offset: __macro_local_6offsetfMu_, context: __macro_local_7contextfMu_)
                        switch action {
                        case .emit(let token):
                            return .success(token)
                        case .skip:
                            lexer.trivia()
                            __macro_local_6offsetfMu_ = lexer.offset()
                            __macro_local_7contextfMu_ = nil
                            return jumpTo_0(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                        case .error(let error):
                            return .failure(.userError(error))
                        case .defaultError:
                            return .failure(.lexerError)
                        }
                    }
                    func jumpTo_3(_ lexer: inout KaleidoscopeLexer.LexerMachine<Test>, _ offset: Int, _ context: Swift.Int?) -> Result<Test, Test.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf2fMu_
                        let action = __macro_local_11__getActionfMu_(lexer: &lexer, offset: __macro_local_6offsetfMu_, context: __macro_local_7contextfMu_)
                        switch action {
                        case .emit(let token):
                            return .success(token)
                        case .skip:
                            lexer.trivia()
                            __macro_local_6offsetfMu_ = lexer.offset()
                            __macro_local_7contextfMu_ = nil
                            return jumpTo_0(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                        case .error(let error):
                            return .failure(.userError(error))
                        case .defaultError:
                            return .failure(.lexerError)
                        }
                    }
                    func jumpTo_4(_ lexer: inout KaleidoscopeLexer.LexerMachine<Test>, _ offset: Int, _ context: Swift.Int?) -> Result<Test, Test.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf3fMu_
                        let action = __macro_local_11__getActionfMu_(lexer: &lexer, offset: __macro_local_6offsetfMu_, context: __macro_local_7contextfMu_)
                        switch action {
                        case .emit(let token):
                            return .success(token)
                        case .skip:
                            lexer.trivia()
                            __macro_local_6offsetfMu_ = lexer.offset()
                            __macro_local_7contextfMu_ = nil
                            return jumpTo_0(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                        case .error(let error):
                            return .failure(.userError(error))
                        case .defaultError:
                            return .failure(.lexerError)
                        }
                    }
                    return jumpTo_0(&lexer, lexer.offset(), nil)
                }
            }
            """#
        }
    }
}
