import ObjectiveC

public struct Mouser {
    public static func setIvar<T>(
        _ name: String,
        for object: AnyObject,
        to val: T
    ) {
        if let ivar: Ivar = class_getInstanceVariable(type(of: object), name) {
            Unmanaged.passUnretained(object)
                .toOpaque()
                .advanced(by: ivar_getOffset(ivar))
                .assumingMemoryBound(to: T.self)
                .pointee = val
        }
    }
    
    public static func getIvar<T>(
        _ name: String,
        for object: AnyObject
    ) -> T? {
        if let ivar: Ivar = class_getInstanceVariable(type(of: object), name) {
            return Unmanaged.passUnretained(object)
                .toOpaque()
                .advanced(by: ivar_getOffset(ivar))
                .assumingMemoryBound(to: T?.self)
                .pointee
        }
        
        return nil
    }
}
