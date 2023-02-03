public protocol HookFunc {
    associatedtype T
    
    var function: String { get }
    var image: String? { get }
    var replacement: T { get }
}

public extension HookFunc {
    private static var _orig: Pointer? {
        get {
            PowPow.origMap.get(ObjectIdentifier(Self.self)) ?? nil
        }
        
        set {
            PowPow.origMap.set(newValue, for: ObjectIdentifier(Self.self))
        }
    }
    
    static var orig: T {
        if case .raw(let ptr) = _orig {
            return unsafeBitCast(ptr, to: T.self)
        }
        
        return unsafeBitCast(_orig, to: T.self)
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
        
        var tmp: UnsafeMutableRawPointer?
        let ret: JinxResult = PowPow.replaceFunc(function, in: image, with: replacementPtr, orig: &tmp)
        
        if let tmp {
            Self._orig = .raw(tmp)
        }
        
        return ret
    }
}
