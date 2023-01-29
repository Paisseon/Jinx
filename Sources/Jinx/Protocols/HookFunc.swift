public protocol HookFunc {
    associatedtype T
    
    var function: String { get }
    var image: String? { get }
    var replacement: T { get }
}

public extension HookFunc {
    private static var _orig: UnsafeMutableRawPointer? {
        get {
            if case .raw(let ptr) = PowPow.origMap.get(ObjectIdentifier(Self.self)) {
                return ptr
            }
            
            return nil
        }
        
        set {
            PowPow.origMap.set(Pointer.raw(newValue!), for: ObjectIdentifier(Self.self))
        }
    }
    
    static var orig: T {
        unsafeBitCast(_orig, to: T.self)
    }
    
    @discardableResult
    func hook(
        onlyIf condition: Bool = true
    ) -> JinxResult {
        guard condition,
              let replacementPtr: UnsafeMutableRawPointer = unsafeBitCast(replacement, to: UnsafeMutableRawPointer?.self)
        else {
            return .noFunction
        }
        
        var sss: UnsafeMutableRawPointer?
        
        return PowPow.replaceFunc(function, in: image, with: replacementPtr, orig: &sss)
    }
}
