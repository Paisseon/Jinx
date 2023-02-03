struct LHFunctionHookOptions {
    var options: UInt32
    var jmp_reg: Int32
}

struct LHFunctionHook {
    var function: UnsafeMutableRawPointer?
    var replacement: UnsafeMutableRawPointer?
    var oldptr: UnsafeMutableRawPointer?
    var options: UnsafeMutablePointer<LHFunctionHookOptions>?
}
