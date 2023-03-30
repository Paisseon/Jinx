//
//  LHFunctionHook.swift
//  Jinx
//
//  Created by Lilliana on 21/03/2023.
//

struct LHFunctionHookOptions {
    var options: UInt32
    var jmp_reg: Int32
}

struct LHFunctionHook {
    var function: UnsafeRawPointer?
    var replacement: UnsafeRawPointer?
    var oldptr: UnsafeMutableRawPointer?
    var options: UnsafeMutablePointer<LHFunctionHookOptions>?
}
