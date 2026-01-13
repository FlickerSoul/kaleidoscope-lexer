//
//  Type.swift
//  Kaleidoscope
//
//  Created by Larry Zeng on 1/13/26.
//
import Kaleidoscope

@kaleidoscope(skip: "\t| |\n")
enum BenchmarkTestType {
    @regex(#"[a-zA-Z_$][a-zA-Z0-9_$]*?"#)
    case Identifier
    
    @regex(#""([^"\\]|\\t|\\n|\\n|\\")*?""#)
    case String
    
    @token(#"private"#)
    case Private
    
    @token(#"primitive"#)
    case Primitive
    
    @token(#"protected"#)
    case Protected
    
    @token(#"in"#)
    case In
    
    @token(#"instanceof"#)
    case Instanceof
    
    @token(#"."#)
    case Accessor
    
    @token(#"..."#)
    case Ellipsis
    
    @token(#"("#)
    case ParenOpen
    
    @token(#")"#)
    case ParenClose
    
    @token(#"{"#)
    case BraceOpen
    
    @token(#"}"#)
    case BraceClose
    
    @token(#"+"#)
    case OpAddition
    
    @token(#"++"#)
    case OpIncrement
    
    @token(#"="#)
    case OpAssign
    
    @token(#"=="#)
    case OpEquality
    
    @token(#"==="#)
    case OpStrictEquality
    
    @token(#"=>"#)
    case FatArrow
}
