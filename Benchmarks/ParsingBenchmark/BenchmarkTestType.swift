//
//  Type.swift
//  Kaleidoscope
//
//  Created by Larry Zeng on 1/13/26.
//
import KaleidoscopeLexer

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
