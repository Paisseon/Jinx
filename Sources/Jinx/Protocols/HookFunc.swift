//
//  HookFunc.swift
//  Jinx
//
//  Created by Lilliana on 25/03/2023.
//

public protocol HookFunc {
    associatedtype T
    
    var name: String { get }
    var replace: T { get }
}

public extension HookFunc {
    private static var uuid: Int {
        Storage.getUUID(for: ObjectIdentifier(Self.self))
    }
    
    private static var _orig: UnsafeMutableRawPointer? {
        get { Storage.getOrigRaw(for: Self.uuid) }
        set { Storage.setOrigRaw(newValue, for: Self.uuid) }
    }
    
    static var orig: T {
        return unsafeBitCast(_orig, to: T.self)
    }
    
    @discardableResult
    func hook() -> Bool {
        var ret: Bool = true
        let replacePtr: UnsafeMutableRawPointer = unsafeBitCast(replace, to: UnsafeMutableRawPointer.self)
        
        withUnsafeMutablePointer(to: &Self._orig) { origPtr in
            let hook: RebindHook = .init(name: name, replace: replacePtr, orig: origPtr)
            
            if Rebind(hook: hook).rebind() {
                ret = true
            } else {
                ret = Substrate(hook: hook).hookFunc()
            }
        }
        
        return ret
    }
}
