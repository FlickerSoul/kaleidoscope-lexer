import MacroTesting
import Testing

extension `Function Based Macro Tests` {
    @Test
    func `function-based benchmark macro expansion`() {
        assertMacro {
            #"""
            @Kaleidoscope
            @skip(/\t| |\n/)
            enum BenchmarkTestType {
                @regex(/[a-zA-Z_$][a-zA-Z0-9_$]*?/)
                case identifier

                @regex(/"([^"\\]|\\t|\\u|\\n|\\")*?"/)
                case string

                @token(#"private"#)
                case `private`

                @token(#"primitive"#)
                case primitive

                @token(#"protected"#)
                case protected

                @token(#"in"#)
                case `in` // swiftlint:disable:this identifier_name

                @token(#"instanceof"#)
                case instanceOf

                @token(#"."#)
                case accessor

                @token(#"..."#)
                case ellipsis

                @token(#"("#)
                case parenOpen

                @token(#")"#)
                case parenClose

                @token(#"{"#)
                case braceOpen

                @token(#"}"#)
                case braceClose

                @token(#"+"#)
                case opAddition

                @token(#"++"#)
                case opIncrement

                @token(#"="#)
                case opAssign

                @token(#"=="#)
                case opEquality

                @token(#"==="#)
                case opStrictEquality

                @token(#"=>"#)
                case fatArrow
            }
            """#
        } expansion: {
            #"""
            enum BenchmarkTestType {
                case identifier
                case string
                case `private`
                case primitive
                case protected
                case `in` // swiftlint:disable:this identifier_name
                case instanceOf
                case accessor
                case ellipsis
                case parenOpen
                case parenClose
                case braceOpen
                case braceClose
                case opAddition
                case opIncrement
                case opAssign
                case opEquality
                case opStrictEquality
                case fatArrow
            }

            extension BenchmarkTestType: KaleidoscopeLexer.LexerTokenProtocol {
                public typealias Source = String
                public typealias UserError = Never
                public static func lex(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>) -> BenchmarkTestType.LexerOutput? {
                    let __macro_local_5leaf0fMu_: Swift.Int = 0
                    let __macro_local_5leaf1fMu_: Swift.Int = 1
                    let __macro_local_5leaf2fMu_: Swift.Int = 2
                    let __macro_local_5leaf3fMu_: Swift.Int = 3
                    let __macro_local_5leaf4fMu_: Swift.Int = 4
                    let __macro_local_5leaf5fMu_: Swift.Int = 5
                    let __macro_local_5leaf6fMu_: Swift.Int = 6
                    let __macro_local_5leaf7fMu_: Swift.Int = 7
                    let __macro_local_5leaf8fMu_: Swift.Int = 8
                    let __macro_local_5leaf9fMu_: Swift.Int = 9
                    let __macro_local_6leaf10fMu_: Swift.Int = 10
                    let __macro_local_6leaf11fMu_: Swift.Int = 11
                    let __macro_local_6leaf12fMu_: Swift.Int = 12
                    let __macro_local_6leaf13fMu_: Swift.Int = 13
                    let __macro_local_6leaf14fMu_: Swift.Int = 14
                    let __macro_local_6leaf15fMu_: Swift.Int = 15
                    let __macro_local_6leaf16fMu_: Swift.Int = 16
                    let __macro_local_6leaf17fMu_: Swift.Int = 17
                    let __macro_local_6leaf18fMu_: Swift.Int = 18
                    let __macro_local_6leaf19fMu_: Swift.Int = 19
                    func __macro_local_11__getActionfMu_(lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, offset: Int, context: Swift.Int?) -> KaleidoscopeLexer._CallbackResult<BenchmarkTestType> {
                        guard let context else  {
                            lexer.endToBoundary(offset: Swift.max(offset, lexer.offset() + 1))
                            return KaleidoscopeLexer._CallbackResult.defaultError
                        }
                        switch context {
                        case __macro_local_5leaf0fMu_:
                            return KaleidoscopeLexer._CallbackResult.skip
                        case __macro_local_5leaf1fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.identifier)
                        case __macro_local_5leaf2fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.string)
                        case __macro_local_5leaf3fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.`private`)
                        case __macro_local_5leaf4fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.primitive)
                        case __macro_local_5leaf5fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.protected)
                        case __macro_local_5leaf6fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.`in`)
                        case __macro_local_5leaf7fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.instanceOf)
                        case __macro_local_5leaf8fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.accessor)
                        case __macro_local_5leaf9fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.ellipsis)
                        case __macro_local_6leaf10fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.parenOpen)
                        case __macro_local_6leaf11fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.parenClose)
                        case __macro_local_6leaf12fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.braceOpen)
                        case __macro_local_6leaf13fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.braceClose)
                        case __macro_local_6leaf14fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opAddition)
                        case __macro_local_6leaf15fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opIncrement)
                        case __macro_local_6leaf16fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opAssign)
                        case __macro_local_6leaf17fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opEquality)
                        case __macro_local_6leaf18fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opStrictEquality)
                        case __macro_local_6leaf19fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.fatArrow)
                        default:
                            fatalError("Invalid leaf identifier. Unknown leaf \(context). This is a bug in Kaleidoscope.")
                        }
                    }
                    let _TABLE_0: InlineArray<256, UInt8> = [0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b0, 0b1, 0b11, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b1, 0b0, 0b1, 0b1, 0b11, 0b1, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b1, 0b1, 0b1, 0b1, 0b1, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0]
                    func jumpTo_0(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x9 ..< 0xB:
                                return jumpTo_1(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x20:
                                return jumpTo_1(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x22:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x28:
                                return jumpTo_4(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x29:
                                return jumpTo_5(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x2B:
                                return jumpTo_6(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x2E:
                                return jumpTo_7(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x3D:
                                return jumpTo_8(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x69:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x69:
                                return jumpTo_9(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6A ..< 0x70:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x70:
                                return jumpTo_10(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x71 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x7B:
                                return jumpTo_11(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x7D:
                                return jumpTo_12(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_1(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
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
                    func jumpTo_2(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
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
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x22:
                                return jumpTo_13(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5C:
                                return jumpTo_14(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0xC2 ..< 0xE0:
                                return jumpTo_15(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0xE0:
                                return jumpTo_16(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0xE1 ..< 0xED:
                                return jumpTo_17(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0xED:
                                return jumpTo_18(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0xEE ..< 0xF0:
                                return jumpTo_17(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0xF0:
                                return jumpTo_19(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0xF1 ..< 0xF4:
                                return jumpTo_20(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0xF4:
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
                    func jumpTo_3(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        func loopTest(_ byte: UInt8) -> Bool {
                            return (_TABLE_0[Int(byte)] & 0b10) == 0
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
                    func jumpTo_4(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf10fMu_
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
                    func jumpTo_5(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf11fMu_
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
                    func jumpTo_6(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf14fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x2B:
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
                    func jumpTo_7(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf8fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x2E:
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
                    func jumpTo_8(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf16fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x3D:
                                return jumpTo_24(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x3E:
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
                    func jumpTo_9(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x6E:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6E:
                                return jumpTo_26(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6F ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_10(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x72:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x72:
                                return jumpTo_27(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x73 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_11(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf12fMu_
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
                    func jumpTo_12(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf13fMu_
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
                    func jumpTo_13(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
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
                    func jumpTo_14(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x22:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6E:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x74 ..< 0x76:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_15(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x80 ..< 0xC0:
                                return jumpTo_2(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_16(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0xA0 ..< 0xC0:
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
                    func jumpTo_17(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x80 ..< 0xC0:
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
                    func jumpTo_18(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x80 ..< 0xA0:
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
                    func jumpTo_19(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x90 ..< 0xC0:
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
                    func jumpTo_20(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x80 ..< 0xC0:
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
                    func jumpTo_21(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x80 ..< 0x90:
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
                    func jumpTo_22(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf15fMu_
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
                    func jumpTo_23(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x2E:
                                return jumpTo_28(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_24(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf17fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x3D:
                                return jumpTo_29(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_25(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf19fMu_
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
                    func jumpTo_26(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf6fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x73:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x73:
                                return jumpTo_30(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x74 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_27(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x69:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x69:
                                return jumpTo_31(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6A ..< 0x6F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6F:
                                return jumpTo_32(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x70 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_28(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf9fMu_
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
                    func jumpTo_29(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_6leaf18fMu_
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
                    func jumpTo_30(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x74:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x74:
                                return jumpTo_33(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x75 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_31(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x6D:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6D:
                                return jumpTo_34(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6E ..< 0x76:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x76:
                                return jumpTo_35(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x77 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_32(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x74:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x74:
                                return jumpTo_36(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x75 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_33(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61:
                                return jumpTo_37(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x62 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_34(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x69:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x69:
                                return jumpTo_38(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6A ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_35(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61:
                                return jumpTo_39(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x62 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_36(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x65:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x65:
                                return jumpTo_40(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x66 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_37(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x6E:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6E:
                                return jumpTo_41(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6F ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_38(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x74:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x74:
                                return jumpTo_42(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x75 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_39(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x74:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x74:
                                return jumpTo_43(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x75 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_40(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x63:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x63:
                                return jumpTo_44(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x64 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_41(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x63:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x63:
                                return jumpTo_45(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x64 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_42(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x69:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x69:
                                return jumpTo_46(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6A ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_43(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x65:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x65:
                                return jumpTo_47(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x66 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_44(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x74:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x74:
                                return jumpTo_48(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x75 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_45(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x65:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x65:
                                return jumpTo_49(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x66 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_46(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x76:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x76:
                                return jumpTo_50(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x77 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_47(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf3fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_48(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x65:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x65:
                                return jumpTo_51(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x66 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_49(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x6F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x6F:
                                return jumpTo_52(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x70 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_50(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x65:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x65:
                                return jumpTo_53(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x66 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_51(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x64:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x64:
                                return jumpTo_54(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x65 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_52(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x66:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x66:
                                return jumpTo_55(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x67 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_53(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf4fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_54(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf5fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    func jumpTo_55(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, _ offset: Int, _ context: Swift.Int?) -> Result<BenchmarkTestType, BenchmarkTestType.LexerError>? {
                        var __macro_local_6offsetfMu_ = offset
                        var __macro_local_7contextfMu_ = context
                        lexer.end(at: __macro_local_6offsetfMu_)
                        __macro_local_7contextfMu_ = __macro_local_5leaf7fMu_
                        let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                        if let byte {
                            __macro_local_6offsetfMu_ += 1
                            switch byte {
                            case 0x24:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x30 ..< 0x3A:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x41 ..< 0x5B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x5F:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
                            case 0x61 ..< 0x7B:
                                return jumpTo_3(&lexer, __macro_local_6offsetfMu_, __macro_local_7contextfMu_)
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
                    return jumpTo_0(&lexer, lexer.offset(), nil)
                }
            }
            """#
        }
    }
}

extension `State Based Macro Tests` {
    @Test
    func `state-based benchmark macro expansion`() {
        assertMacro {
            #"""
            @Kaleidoscope(useStateMachineCodegen: true)
            @skip(/\t| |\n/)
            enum BenchmarkTestType {
                @regex(/[a-zA-Z_$][a-zA-Z0-9_$]*?/)
                case identifier

                @regex(/"([^"\\]|\\t|\\u|\\n|\\")*?"/)
                case string

                @token(#"private"#)
                case `private`

                @token(#"primitive"#)
                case primitive

                @token(#"protected"#)
                case protected

                @token(#"in"#)
                case `in` // swiftlint:disable:this identifier_name

                @token(#"instanceof"#)
                case instanceOf

                @token(#"."#)
                case accessor

                @token(#"..."#)
                case ellipsis

                @token(#"("#)
                case parenOpen

                @token(#")"#)
                case parenClose

                @token(#"{"#)
                case braceOpen

                @token(#"}"#)
                case braceClose

                @token(#"+"#)
                case opAddition

                @token(#"++"#)
                case opIncrement

                @token(#"="#)
                case opAssign

                @token(#"=="#)
                case opEquality

                @token(#"==="#)
                case opStrictEquality

                @token(#"=>"#)
                case fatArrow
            }
            """#
        } expansion: {
            #"""
            enum BenchmarkTestType {
                case identifier
                case string
                case `private`
                case primitive
                case protected
                case `in` // swiftlint:disable:this identifier_name
                case instanceOf
                case accessor
                case ellipsis
                case parenOpen
                case parenClose
                case braceOpen
                case braceClose
                case opAddition
                case opIncrement
                case opAssign
                case opEquality
                case opStrictEquality
                case fatArrow
            }

            extension BenchmarkTestType: KaleidoscopeLexer.LexerTokenProtocol {
                public typealias Source = String
                public typealias UserError = Never
                public static func lex(_ lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>) -> BenchmarkTestType.LexerOutput? {
                    let __macro_local_5leaf0fMu_: Swift.Int = 0
                    let __macro_local_5leaf1fMu_: Swift.Int = 1
                    let __macro_local_5leaf2fMu_: Swift.Int = 2
                    let __macro_local_5leaf3fMu_: Swift.Int = 3
                    let __macro_local_5leaf4fMu_: Swift.Int = 4
                    let __macro_local_5leaf5fMu_: Swift.Int = 5
                    let __macro_local_5leaf6fMu_: Swift.Int = 6
                    let __macro_local_5leaf7fMu_: Swift.Int = 7
                    let __macro_local_5leaf8fMu_: Swift.Int = 8
                    let __macro_local_5leaf9fMu_: Swift.Int = 9
                    let __macro_local_6leaf10fMu_: Swift.Int = 10
                    let __macro_local_6leaf11fMu_: Swift.Int = 11
                    let __macro_local_6leaf12fMu_: Swift.Int = 12
                    let __macro_local_6leaf13fMu_: Swift.Int = 13
                    let __macro_local_6leaf14fMu_: Swift.Int = 14
                    let __macro_local_6leaf15fMu_: Swift.Int = 15
                    let __macro_local_6leaf16fMu_: Swift.Int = 16
                    let __macro_local_6leaf17fMu_: Swift.Int = 17
                    let __macro_local_6leaf18fMu_: Swift.Int = 18
                    let __macro_local_6leaf19fMu_: Swift.Int = 19
                    func __macro_local_11__getActionfMu_(lexer: inout KaleidoscopeLexer.LexerMachine<BenchmarkTestType>, offset: Int, context: Swift.Int?) -> KaleidoscopeLexer._CallbackResult<BenchmarkTestType> {
                        guard let context else  {
                            lexer.endToBoundary(offset: Swift.max(offset, lexer.offset() + 1))
                            return KaleidoscopeLexer._CallbackResult.defaultError
                        }
                        switch context {
                        case __macro_local_5leaf0fMu_:
                            return KaleidoscopeLexer._CallbackResult.skip
                        case __macro_local_5leaf1fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.identifier)
                        case __macro_local_5leaf2fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.string)
                        case __macro_local_5leaf3fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.`private`)
                        case __macro_local_5leaf4fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.primitive)
                        case __macro_local_5leaf5fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.protected)
                        case __macro_local_5leaf6fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.`in`)
                        case __macro_local_5leaf7fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.instanceOf)
                        case __macro_local_5leaf8fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.accessor)
                        case __macro_local_5leaf9fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.ellipsis)
                        case __macro_local_6leaf10fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.parenOpen)
                        case __macro_local_6leaf11fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.parenClose)
                        case __macro_local_6leaf12fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.braceOpen)
                        case __macro_local_6leaf13fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.braceClose)
                        case __macro_local_6leaf14fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opAddition)
                        case __macro_local_6leaf15fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opIncrement)
                        case __macro_local_6leaf16fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opAssign)
                        case __macro_local_6leaf17fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opEquality)
                        case __macro_local_6leaf18fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.opStrictEquality)
                        case __macro_local_6leaf19fMu_:
                            return KaleidoscopeLexer._CallbackResult.emit(BenchmarkTestType.fatArrow)
                        default:
                            fatalError("Invalid leaf identifier. Unknown leaf \(context). This is a bug in Kaleidoscope.")
                        }
                    }
                    let _TABLE_0: InlineArray<256, UInt8> = [0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b0, 0b1, 0b11, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b1, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b1, 0b0, 0b1, 0b1, 0b11, 0b1, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b11, 0b1, 0b1, 0b1, 0b1, 0b1, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0, 0b0]
                    let state0: Swift.Int = 0
                    let state1: Swift.Int = 1
                    let state2: Swift.Int = 2
                    let state3: Swift.Int = 3
                    let state4: Swift.Int = 4
                    let state5: Swift.Int = 5
                    let state6: Swift.Int = 6
                    let state7: Swift.Int = 7
                    let state8: Swift.Int = 8
                    let state9: Swift.Int = 9
                    let state10: Swift.Int = 10
                    let state11: Swift.Int = 11
                    let state12: Swift.Int = 12
                    let state13: Swift.Int = 13
                    let state14: Swift.Int = 14
                    let state15: Swift.Int = 15
                    let state16: Swift.Int = 16
                    let state17: Swift.Int = 17
                    let state18: Swift.Int = 18
                    let state19: Swift.Int = 19
                    let state20: Swift.Int = 20
                    let state21: Swift.Int = 21
                    let state22: Swift.Int = 22
                    let state23: Swift.Int = 23
                    let state24: Swift.Int = 24
                    let state25: Swift.Int = 25
                    let state26: Swift.Int = 26
                    let state27: Swift.Int = 27
                    let state28: Swift.Int = 28
                    let state29: Swift.Int = 29
                    let state30: Swift.Int = 30
                    let state31: Swift.Int = 31
                    let state32: Swift.Int = 32
                    let state33: Swift.Int = 33
                    let state34: Swift.Int = 34
                    let state35: Swift.Int = 35
                    let state36: Swift.Int = 36
                    let state37: Swift.Int = 37
                    let state38: Swift.Int = 38
                    let state39: Swift.Int = 39
                    let state40: Swift.Int = 40
                    let state41: Swift.Int = 41
                    let state42: Swift.Int = 42
                    let state43: Swift.Int = 43
                    let state44: Swift.Int = 44
                    let state45: Swift.Int = 45
                    let state46: Swift.Int = 46
                    let state47: Swift.Int = 47
                    let state48: Swift.Int = 48
                    let state49: Swift.Int = 49
                    let state50: Swift.Int = 50
                    let state51: Swift.Int = 51
                    let state52: Swift.Int = 52
                    let state53: Swift.Int = 53
                    let state54: Swift.Int = 54
                    let state55: Swift.Int = 55
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
                                case 9 ..< 11:
                                    nextState = state1
                                case 32:
                                    nextState = state1
                                case 34:
                                    nextState = state2
                                case 36:
                                    nextState = state3
                                case 40:
                                    nextState = state4
                                case 41:
                                    nextState = state5
                                case 43:
                                    nextState = state6
                                case 46:
                                    nextState = state7
                                case 61:
                                    nextState = state8
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 105:
                                    nextState = state3
                                case 105:
                                    nextState = state9
                                case 106 ..< 112:
                                    nextState = state3
                                case 112:
                                    nextState = state10
                                case 113 ..< 123:
                                    nextState = state3
                                case 123:
                                    nextState = state11
                                case 125:
                                    nextState = state12
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
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 34:
                                    nextState = state13
                                case 92:
                                    nextState = state14
                                case 194 ..< 224:
                                    nextState = state15
                                case 224:
                                    nextState = state16
                                case 225 ..< 237:
                                    nextState = state17
                                case 237:
                                    nextState = state18
                                case 238 ..< 240:
                                    nextState = state17
                                case 240:
                                    nextState = state19
                                case 241 ..< 244:
                                    nextState = state20
                                case 244:
                                    nextState = state21
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state3:
                            func loopTest(_ byte: UInt8) -> Bool {
                                return (_TABLE_0[Int(byte)] & 0b10) == 0
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
                        case state4:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf10fMu_
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
                        case state5:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf11fMu_
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
                        case state6:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf14fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 43:
                                    nextState = state22
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state7:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf8fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 46:
                                    nextState = state23
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state8:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf16fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 61:
                                    nextState = state24
                                case 62:
                                    nextState = state25
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state9:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 110:
                                    nextState = state3
                                case 110:
                                    nextState = state26
                                case 111 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state10:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 114:
                                    nextState = state3
                                case 114:
                                    nextState = state27
                                case 115 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state11:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf12fMu_
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
                        case state12:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf13fMu_
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
                        case state13:
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
                        case state14:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 34:
                                    nextState = state2
                                case 110:
                                    nextState = state2
                                case 116 ..< 118:
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
                        case state15:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 128 ..< 192:
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
                        case state16:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 160 ..< 192:
                                    nextState = state15
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state17:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 128 ..< 192:
                                    nextState = state15
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state18:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 128 ..< 160:
                                    nextState = state15
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state19:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 144 ..< 192:
                                    nextState = state17
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state20:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 128 ..< 192:
                                    nextState = state17
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state21:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 128 ..< 144:
                                    nextState = state17
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state22:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf15fMu_
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
                        case state23:
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 46:
                                    nextState = state28
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state24:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf17fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 61:
                                    nextState = state29
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state25:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf19fMu_
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
                        case state26:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf6fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 115:
                                    nextState = state3
                                case 115:
                                    nextState = state30
                                case 116 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state27:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 105:
                                    nextState = state3
                                case 105:
                                    nextState = state31
                                case 106 ..< 111:
                                    nextState = state3
                                case 111:
                                    nextState = state32
                                case 112 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state28:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf9fMu_
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
                        case state29:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_6leaf18fMu_
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
                        case state30:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 116:
                                    nextState = state3
                                case 116:
                                    nextState = state33
                                case 117 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state31:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 109:
                                    nextState = state3
                                case 109:
                                    nextState = state34
                                case 110 ..< 118:
                                    nextState = state3
                                case 118:
                                    nextState = state35
                                case 119 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state32:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 116:
                                    nextState = state3
                                case 116:
                                    nextState = state36
                                case 117 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state33:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97:
                                    nextState = state37
                                case 98 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state34:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 105:
                                    nextState = state3
                                case 105:
                                    nextState = state38
                                case 106 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state35:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97:
                                    nextState = state39
                                case 98 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state36:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 101:
                                    nextState = state3
                                case 101:
                                    nextState = state40
                                case 102 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state37:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 110:
                                    nextState = state3
                                case 110:
                                    nextState = state41
                                case 111 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state38:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 116:
                                    nextState = state3
                                case 116:
                                    nextState = state42
                                case 117 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state39:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 116:
                                    nextState = state3
                                case 116:
                                    nextState = state43
                                case 117 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state40:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 99:
                                    nextState = state3
                                case 99:
                                    nextState = state44
                                case 100 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state41:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 99:
                                    nextState = state3
                                case 99:
                                    nextState = state45
                                case 100 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state42:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 105:
                                    nextState = state3
                                case 105:
                                    nextState = state46
                                case 106 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state43:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 101:
                                    nextState = state3
                                case 101:
                                    nextState = state47
                                case 102 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state44:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 116:
                                    nextState = state3
                                case 116:
                                    nextState = state48
                                case 117 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state45:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 101:
                                    nextState = state3
                                case 101:
                                    nextState = state49
                                case 102 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state46:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 118:
                                    nextState = state3
                                case 118:
                                    nextState = state50
                                case 119 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state47:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf3fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state48:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 101:
                                    nextState = state3
                                case 101:
                                    nextState = state51
                                case 102 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state49:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 111:
                                    nextState = state3
                                case 111:
                                    nextState = state52
                                case 112 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state50:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 101:
                                    nextState = state3
                                case 101:
                                    nextState = state53
                                case 102 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state51:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 100:
                                    nextState = state3
                                case 100:
                                    nextState = state54
                                case 101 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state52:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf1fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 102:
                                    nextState = state3
                                case 102:
                                    nextState = state55
                                case 103 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state53:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf4fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state54:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf5fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
                                __macro_local_5statefMu_ = state0
                                continue
                            case .error(let error):
                                return .failure(.userError(error))
                            case .defaultError:
                                return .failure(.lexerError)
                            }
                        case state55:
                            lexer.end(at: __macro_local_6offsetfMu_)
                            __macro_local_7contextfMu_ = __macro_local_5leaf7fMu_
                            let byte = lexer.read(offset: __macro_local_6offsetfMu_)
                            if let byte {
                                let nextState: Swift.Int?
                                switch byte {
                                case 36:
                                    nextState = state3
                                case 48 ..< 58:
                                    nextState = state3
                                case 65 ..< 91:
                                    nextState = state3
                                case 95:
                                    nextState = state3
                                case 97 ..< 123:
                                    nextState = state3
                                default:
                                    nextState = nil
                                }
                                if let nextState {
                                    __macro_local_6offsetfMu_ += 1
                                    __macro_local_5statefMu_ = nextState
                                    continue
                                }
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
