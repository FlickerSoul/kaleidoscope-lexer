//
//  Tokenizer.swift
//
//
//  Created by Larry Zeng on 12/18/23.
//

import Kaleidoscope

@kaleidoscope
enum Token {
    @regex("aa")
    case tokenAA

    @regex("bb")
    case tokenBB
}
