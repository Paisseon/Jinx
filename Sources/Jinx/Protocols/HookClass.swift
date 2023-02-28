import ObjectiveC

public protocol HookClass {
    var `class`: AnyClass? { get }
    var hooks: [any Groupable] { get }
}

public extension HookClass {
    @discardableResult
    func hook(
        onlyIf condition: Bool = true
    ) -> [JinxResult] {
        guard condition else {
            return [.noClass]
        }
        
        var ret: [JinxResult] = []
        
        for i: Int in 0 ..< hooks.count {
            var hook: any Groupable = hooks[i]
            hook.id &= ObjectIdentifier(Self.self).hashValue
            
            PowPow.grupMap.set(hook, for: hook.id)
        }
        
        for hook: any Groupable in hooks {
            ret.append(hook.hook(`class`))
        }
        
        return ret
    }
    
    @discardableResult
    func unhook() -> [JinxResult] {
        var ret: [JinxResult] = []
        
        for hook: any Groupable in hooks {
            ret.append(hook.unhook(`class`))
        }
        
        return ret
    }
    
    static func orig<T>(
        for sel: Selector,
        type: T.Type
    ) -> T? {
        PowPow.grupMap.get(sel.hashValue & ObjectIdentifier(Self.self).hashValue)?.orig as? T
    }
}
