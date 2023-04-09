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
    
    private static var _orig: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid) }
    }
    
    static var orig: T {
        let tPtr: UnsafePointer<T> = withUnsafePointer(to: _orig, { UnsafeRawPointer($0).bindMemory(to: T.self, capacity: 1) })
        return tPtr.pointee
    }
    
    @discardableResult
    func hook() -> Bool {
        guard let cls else {
            return false
        }
        
        return Replace.message(
            cls, sel,
            with: withUnsafePointer(to: replace) { UnsafeMutableRawPointer(mutating: $0).assumingMemoryBound(to: OpaquePointer.self).pointee },
            orig: &Self._orig
        )
    }
    
    @discardableResult
    func unhook() -> Bool {
        guard let cls else {
            return false
        }
        
        return Replace.message(cls, sel, with: Self._orig!, orig: &Self._orig)
    }
}
