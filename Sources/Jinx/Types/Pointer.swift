enum Pointer {
    case opaque(OpaquePointer)
    case raw(UnsafeMutableRawPointer)
    case rawConst(UnsafeRawPointer)
}
