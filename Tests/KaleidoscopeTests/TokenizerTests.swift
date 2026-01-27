//
//  TokenizerTests.swift
//
//
//  Created by Larry Zeng on 12/7/23.
//

import KaleidoscopeLexer
import Testing

@Kaleidoscope
enum Test {
    @regex(/a/)
    case a

    @regex(/b/)
    case b
}

// @kaleidoscope()
// enum PriorityTest: Equatable {
//     @token("fast")
//     case fast

//     @token("fast", priority: 10)
//     case faaaast
// }

// let convertInt: FillCallback<CallbackTest, Int> = { lexer in Int(lexer.rawSlice)! }

// let convertDouble: FillCallback<CallbackTest, Double> = { lexer in Double(lexer.rawSlice)! }

// let toSubstring: FillCallback<CallbackTest, Substring> = { lexer in lexer.rawSlice }

// let questionTokenGen: CreateCallback<CallbackTest, CallbackTest> = { lexer in
//     if lexer.rawSlice.count % 2 == 0 {
//         .question(0)
//     } else {
//         .question(lexer.rawSlice.count)
//     }
// }

// let excTokenGen: CreateCallback<CallbackTest, TokenResult<CallbackTest>> = { lexer in
//     if lexer.rawSlice.count % 2 == 0 {
//         CallbackTest.exc.into()
//     } else {
//         .skipped
//     }
// }

// @kaleidoscope(skip: " ")
// enum CallbackTest: Equatable {
//     @regex(#"[0-9]*?\.[0-9]+?"#, fillCallback: convertDouble)
//     case double(Double)

//     @regex("[0-9]+?", fillCallback: convertInt)
//     case number(Int)

//     @token("what", fillCallback: toSubstring)
//     case what(Substring)

//     @regex("//.*?", fillCallback: toSubstring)
//     case comment(Substring)

//     @token(".")
//     case dot

//     @regex(#"\?*?"#, createCallback: questionTokenGen)
//     case question(Int)

//     @regex(#"!*?"#, priority: 2, createCallback: excTokenGen)
//     case exc
// }

// @Suite
// struct TestTokenizer {
//     @Test
//     func testPriority() throws {
//         let actual = try PriorityTest.lexer(source: "fast").toUnwrappedArray()
//         #expect(actual == [PriorityTest.faaaast])
//     }

//     @Test
//     func callback() throws {
//         let actual = try CallbackTest.lexer(source: "100 1.5 .6 what . ? ??? ???? !! ! // this is a comment")
//             .toUnwrappedArray()
//         #expect(
//             actual == [
//                 .number(100),
//                 .double(1.5),
//                 .double(0.6),
//                 .what("what"),
//                 .dot,
//                 .question(1),
//                 .question(3),
//                 .question(0),
//                 .exc,
//                 .comment("// this is a comment"),
//             ],
//         )
//     }
// }
