//
//  Replace.swift
//  Jinx
//
//  Created by Lilliana on 22/03/2023.
//

import ObjectiveC.runtime

struct Replace {
    static func message(
        _ cls: AnyClass,
        _ sel: Selector,
        with replacement: OpaquePointer,
        orig: inout OpaquePointer?
    ) -> Bool {
        let getMethod = class_isMetaClass(cls) ? class_getClassMethod : class_getInstanceMethod
        
        guard let method: Method = getMethod(cls, sel),
              let types: UnsafePointer<Int8> = method_getTypeEncoding(method)
        else {
            return false
        }
        
        let lock: Lock = .init()
        
        lock.locked {
            let _orig: OpaquePointer = class_addMethod(cls, sel, replacement, types) ?
            method_getImplementation(method) :
            method_setImplementation(method, replacement)
            
            orig = _orig
        }
        
        return true
    }
}
