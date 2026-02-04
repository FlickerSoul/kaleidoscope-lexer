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

    @Test
    func `callback expansion`() {
        assertMacro {
            """
            @Kaleidoscope
            @skip(/[ ]/)
            @skip(/aaa/, callback: skipPrintCallback)
            private enum CallbackTest: Equatable {
                @regex(/[0-9]+?/, callback: intCallback)
                case number(Int)

                @token("ident", callback: printCallback)
                case ident

                @skip("skip", callback: skipPrintCallback)
                case skipped

                @skip("regular skip")
                case regularSkip
            }
            """
        } expansion: {
            #"""
            private enum CallbackTest: Equatable {
                case number(Int)
                case ident
                case skipped
                case regularSkip
            }

            extension CallbackTest: KaleidoscopeLexer.LexerTokenProtocol {
                public typealias Source = String
                public typealias UserError = Never
                public static func lex(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>) -> CallbackTest.LexerOutput? {
                    let __macro_local_5leaf0fMu_: Swift.Int = 0
                    let __macro_local_5leaf1fMu_: Swift.Int = 1
                    let __macro_local_5leaf2fMu_: Swift.Int = 2
                    let __macro_local_5leaf3fMu_: Swift.Int = 3
                    let __macro_local_5leaf4fMu_: Swift.Int = 4
                    let __macro_local_5leaf5fMu_: Swift.Int = 5
                    func __macro_local_11__getActionfMu_(lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, offset: Int, context: Swift.Int?) -> KaleidoscopeLexer._CallbackResult<CallbackTest> {
                        guard let context else  {
                            lexer.endToBoundary(offset: Swift.max(offset, lexer.offset() + 1))
                            return KaleidoscopeLexer._CallbackResult.defaultError
                        }
                        switch context {
                        case __macro_local_5leaf0fMu_:
                            return KaleidoscopeLexer._CallbackResult.skip
                        case __macro_local_5leaf1fMu_:
                            let cb = skipPrintCallback(&lexer) as any KaleidoscopeLexer._SkipResultSource<CallbackTest>
                            return cb.convert().asCallbackResult()
                        case __macro_local_5leaf2fMu_:
                            let cb = intCallback(&lexer)
                            return .emit(__apply(cb, on: CallbackTest.number))
                        case __macro_local_5leaf3fMu_:
                            let _: Void = printCallback(&lexer)
                            return .emit(CallbackTest.ident)
                        case __macro_local_5leaf4fMu_:
                            let cb = skipPrintCallback(&lexer) as any KaleidoscopeLexer._SkipResultSource<CallbackTest>
                            return cb.convert().asCallbackResult()
                        case __macro_local_5leaf5fMu_:
                            return KaleidoscopeLexer._CallbackResult.skip
                        default:
                            fatalError("Invalid leaf identifier. Unknown leaf \(context)")
                        }
                    }
                    let _TABLE_0: InlineArray<256, UInt8> = [0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0]
                    func jumpTo_0(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x20 ..< 0x21:
                                return jumpTo_1(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x62:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x69 ..< 0x6A:
                                return jumpTo_4(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x72 ..< 0x73:
                                return jumpTo_5(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x73 ..< 0x74:
                                return jumpTo_6(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_1(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
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
                    func jumpTo_2(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        func loopTest(_ byte: UInt8) -> Bool {
                            return (_TABLE_0[Int(byte)] & 0b1) == 0
                        }
                        outer: do {
                            while let buffer: InlineArray<8, UInt8> = lexer.read(offset: __macro_local_6offsetfMu_) {
                                if loopTest(buffer[0]) {
                                    __macro_local_6offsetfMu_ += 0
                                    break outer
                                }
                                if loopTest(buffer[1]) {
                                    __macro_local_6offsetfMu_ += 1
                                    break outer
                                }
                                if loopTest(buffer[2]) {
                                    __macro_local_6offsetfMu_ += 2
                                    break outer
                                }
                                if loopTest(buffer[3]) {
                                    __macro_local_6offsetfMu_ += 3
                                    break outer
                                }
                                if loopTest(buffer[4]) {
                                    __macro_local_6offsetfMu_ += 4
                                    break outer
                                }
                                if loopTest(buffer[5]) {
                                    __macro_local_6offsetfMu_ += 5
                                    break outer
                                }
                                if loopTest(buffer[6]) {
                                    __macro_local_6offsetfMu_ += 6
                                    break outer
                                }
                                if loopTest(buffer[7]) {
                                    __macro_local_6offsetfMu_ += 7
                                    break outer
                                }
                                __macro_local_6offsetfMu_ += 8
                            }
                            while let byte = lexer.read(offset: __macro_local_6offsetfMu_) {
                                if loopTest(byte) {
                                    break outer
                                }
                                __macro_local_6offsetfMu_ += 1
                            }
                        }
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
                    func jumpTo_3(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x61 ..< 0x62:
                                return jumpTo_7(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_4(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x64 ..< 0x65:
                                return jumpTo_8(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_5(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x65 ..< 0x66:
                                return jumpTo_9(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_6(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x6B ..< 0x6C:
                                return jumpTo_10(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_7(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x61 ..< 0x62:
                                return jumpTo_11(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_8(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x65 ..< 0x66:
                                return jumpTo_12(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_9(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x67 ..< 0x68:
                                return jumpTo_13(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_10(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x69 ..< 0x6A:
                                return jumpTo_14(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_11(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
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
                    func jumpTo_12(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x6E ..< 0x6F:
                                return jumpTo_15(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_13(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x75 ..< 0x76:
                                return jumpTo_16(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_14(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x70 ..< 0x71:
                                return jumpTo_17(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_15(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x74 ..< 0x75:
                                return jumpTo_18(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_16(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x6C ..< 0x6D:
                                return jumpTo_19(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_17(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf4fMu_
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
                    func jumpTo_18(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
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
                    func jumpTo_19(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x61 ..< 0x62:
                                return jumpTo_20(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_20(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x72 ..< 0x73:
                                return jumpTo_21(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_21(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x20 ..< 0x21:
                                return jumpTo_22(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_22(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x73 ..< 0x74:
                                return jumpTo_23(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_23(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x6B ..< 0x6C:
                                return jumpTo_24(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_24(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x69 ..< 0x6A:
                                return jumpTo_25(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_25(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x70 ..< 0x71:
                                return jumpTo_26(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            default:
                                break
                            }
                            __macro_local_6offsetfMu_ -= 1
                        } else {
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
                    func jumpTo_26(_ lexer: inout KaleidoscopeLexer.LexerMachine<CallbackTest>, _ offset: Int, _ context: Swift.Int?) -> Result<CallbackTest, CallbackTest.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf5fMu_
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
