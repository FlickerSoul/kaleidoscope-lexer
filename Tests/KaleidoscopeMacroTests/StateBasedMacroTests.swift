import MacroTesting
import Testing

extension `State Based Macro Tests` {
    @Test
    func `successful generation`() {
        assertMacro {
            #"""
            @Kaleidoscope(useStateMachineCodegen: true)
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
                            fatalError("Invalid leaf identifier. Unknown leaf \(context). This is a bug in Kaleidoscope.")
                        }
                    }
                    let state0: Swift.Int = 0
                    let state1: Swift.Int = 1
                    let state2: Swift.Int = 2
                    let state3: Swift.Int = 3
                    let state4: Swift.Int = 4
                    var __macro_local_5statefMu_ = state0
                    var __macro_local_6offsetfMu_ = lexer.offset()
                    var __macro_local_7contextfMu_: Swift.Int? = nil
                    while true {
                        switch __macro_local_5statefMu_ {
                        case state0:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 32:
                                    nextState = state1
                                case 92:
                                    nextState = state2
                                case 97:
                                    nextState = state3
                                case 98:
                                    nextState = state4
                                case 110:
                                    nextState = state2
                                case 116:
                                    nextState = state2
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state1:
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state2:
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state3:
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state4:
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        default:
                            fatalError("Invalid state \(__macro_local_5statefMu_) encountered. This is a bug in Keleidoscope.")
                        }
                    }
                }
            }
            """#
        }
    }
}
