//
//  Hook.swift
//  Jinx
//
//  Created by Lilliana on 25/03/2023.
//

import ObjectiveC

public protocol Hook {
    associatedtype T
    
    var cls: AnyClass? { get }
    var sel: Selector { get }
    var replace: T { get }
}

public extension Hook {
    private static var uuid: Int {
        Storage.getUUID(for: ObjectIdentifier(Self.self))
    }
    
    private static var _orig: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid) }
    }
    
    private static func opaquePointer<U>(
        from closure: U
    ) -> OpaquePointer {
        withUnsafePointer(to: closure) { UnsafeMutableRawPointer(mutating: $0).assumingMemoryBound(to: OpaquePointer.self).pointee }
    }
    
    private static func safeBitCast<U>(
        _ ptr: OpaquePointer?,
        to type: U.Type
    ) -> U {
        let tPtr: UnsafePointer<U> = withUnsafePointer(to: ptr, { UnsafeRawPointer($0).bindMemory(to: U.self, capacity: 1) })
        return tPtr.pointee
    }
    
    static var orig: T {
        safeBitCast(_orig, to: T.self)
    }
    
    @discardableResult
    func hook() -> Bool {
        guard let cls else {
            return false
        }
        
        return Replace.message(cls, sel, with: Self.opaquePointer(from: replace), orig: &Self._orig)
    }
}
