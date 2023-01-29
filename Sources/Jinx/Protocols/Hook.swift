import Foundation

public protocol Hook {
    associatedtype T
    
    var `class`: AnyClass? { get }
    var selector: Selector { get }
    var replacement: T { get }
}

public extension Hook {
    private static var _orig: OpaquePointer? {
        get {
            if case .opaque(let ptr) = PowPow.origMap.get(ObjectIdentifier(Self.self)) {
                return ptr
            }
            
            return nil
        }
        
        set {
            PowPow.origMap.set(Pointer.opaque(newValue!), for: ObjectIdentifier(Self.self))
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
              let `class`
        else {
            return .noClass
        }
        
        return PowPow.replace(`class`, selector, with: replacement, orig: &Self._orig)
    }
}
