//
//  Ivar.swift
//  Jinx
//
//  Created by Lilliana on 21/03/2023.
//

import ObjectiveC

public struct Ivar {
    @inlinable
    public static func get<T>(
        _ name: String,
        for obj: AnyObject
    ) -> T? {
        if let ivar: OpaquePointer = class_getInstanceVariable(type(of: obj), name) {
            return Unmanaged.passUnretained(obj)
                .toOpaque()
                .advanced(by: ivar_getOffset(ivar))
                .assumingMemoryBound(to: T.self)
                .pointee
        }
        
        return nil
    }
    
    @inlinable
    public static func set<T>(
        _ name: String,
        for obj: AnyObject,
        to val: T
    ) {
        if let ivar: OpaquePointer = class_getInstanceVariable(type(of: obj), name) {
            Unmanaged.passUnretained(obj)
                .toOpaque()
                .advanced(by: ivar_getOffset(ivar))
                .assumingMemoryBound(to: T.self)
                .pointee = val
        }
    }
}
