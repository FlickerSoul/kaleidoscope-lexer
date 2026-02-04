import KaleidoscopeLexer

@Kaleidoscope(useStateMachineCodegen: true)
@skip(/\t| |\n/)
public enum BenchmarkStateBased: Sendable {
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
    case `in`

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
