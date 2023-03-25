//
//  Hook.swift
//  Jinx
//
//  Created by Lilliana on 25/03/2023.
//

import ObjectiveC.runtime

public protocol Hook {
    associatedtype T
    
    var cls: AnyClass? { get }
    var sel: Selector { get }
    var replace: T { get }
}

public extension Hook {
    private static var uuid: Int {
        ObjectIdentifier(Self.self).hashValue
    }
    
    private static var _orig: Pointer? {
        get { Storage.getOrig(for: Self.uuid) }
        set { Storage.setOrig(newValue, for: Self.uuid) }
    }
    
    static var orig: T {
        if case .opaque(let ptr) = _orig { return UnsafeRawPointer(ptr).bindMemory(to: T.self, capacity: 1).pointee }
        return unsafeBitCast(_orig, to: T.self)
    }
    
    @discardableResult
    func hook(
        onlyIf condition: Bool = true
    ) -> Bool {
        guard condition,
              let cls
        else {
            return false
        }
        
        return Replace.message(cls, sel, with: withUnsafePointer(to: replace, { OpaquePointer($0) }), orig: &Self._orig)
    }
    
    @discardableResult
    func unhook() -> Bool {
        guard let cls else {
            return false
        }
        
        return Replace.message(cls, sel, with: withUnsafePointer(to: Self.orig, { OpaquePointer($0) }), orig: &Self._orig)
    }
}
