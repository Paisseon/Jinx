import Foundation

public struct Mouser {
    public static func setIvar<T>(
        _ name: String,
        for object: AnyObject,
        to val: T
    ) {
        if let ivar: Ivar = class_getInstanceVariable(type(of: object), name) {
            unsafeBitCast(object, to: UnsafeMutableRawPointer.self)
                .advanced(by: ivar_getOffset(ivar))
                .assumingMemoryBound(to: T.self)
                .pointee = val
        }
    }
}
