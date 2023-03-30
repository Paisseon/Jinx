//
//  Replace.swift
//  Jinx
//
//  Created by Lilliana on 22/03/2023.
//

import ObjectiveC.runtime

struct Replace {
    // MARK: Internal

    static func message(
        _ cls: AnyClass,
        _ sel: Selector,
        with replace: OpaquePointer,
        orig: inout OpaquePointer?
    ) -> Bool {
        if class_isMetaClass(cls) {
            return classMethod(cls, sel, with: replace, orig: &orig)
        }

        guard let method: Method = class_getInstanceMethod(cls, sel),
              let types: UnsafePointer<Int8> = method_getTypeEncoding(method)
        else {
            return false
        }

        lock.locked {
            orig = class_replaceMethod(object_getClass(cls), sel, replace, types)
        }

        return true
    }

    // MARK: Private

    private static let lock: Lock = .init()

    private static func classMethod(
        _ cls: AnyClass,
        _ sel: Selector,
        with replace: OpaquePointer,
        orig: inout OpaquePointer?
    ) -> Bool {
        let newSel: Selector = sel_registerName("Jinx_" + String(cString: sel_getName(sel)))

        guard let origMethod: Method = class_getClassMethod(cls, sel),
              let method: Method = class_getClassMethod(cls, sel),
              let types: UnsafePointer<Int8> = method_getTypeEncoding(method),
              class_addMethod(cls, newSel, replace, types),
              let newMethod: Method = class_getClassMethod(cls, newSel)
        else {
            return false
        }

        lock.locked {
            orig = method_getImplementation(origMethod)
            method_exchangeImplementations(origMethod, newMethod)
        }

        return true
    }
}
