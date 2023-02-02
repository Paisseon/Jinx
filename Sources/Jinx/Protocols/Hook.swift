import ObjectiveC

public protocol Hook {
    associatedtype T
    
    var `class`: AnyClass? { get }
    var selector: Selector { get }
    var replacement: T { get }
}

public extension Hook {
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
        
        if case .opaque(let ptr) = _orig {
            return unsafeBitCast(ptr, to: T.self)
        }
        
        return unsafeBitCast(_orig, to: T.self)
    }
    
    @discardableResult
    func hook(
        onlyIf condition: Bool = true
    ) -> JinxResult {
        guard condition,
              let `class`
        else {
            return .noClass
        }
        
        return PowPow.replace(`class`, selector, with: replacement, orig: &Self._orig)
    }
}
