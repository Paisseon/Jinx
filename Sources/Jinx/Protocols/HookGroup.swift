//
//  HookGroup.swift
//  Jinx
//
//  Created by Lilliana on 25/03/2023.
//

import ObjectiveC.runtime

public typealias HookClass = HookGroup

// Quoth Kabir Oberai: "y u no variadic generics, swift :/"

public protocol HookGroup {
    associatedtype T0
    associatedtype T1 = Void
    associatedtype T2 = Void
    associatedtype T3 = Void
    associatedtype T4 = Void
    associatedtype T5 = Void
    associatedtype T6 = Void
    associatedtype T7 = Void
    associatedtype T8 = Void
    associatedtype T9 = Void

    var cls: AnyClass? { get }
    var sel0: Selector { get }
    var replace0: T0 { get }
}

public extension HookGroup {
    private static var uuid: Int {
        ObjectIdentifier(Self.self).hashValue
    }

    // Extra origs

    private static var _orig0: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid) }
    }

    private static var _orig1: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 1) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 1) }
    }

    private static var _orig2: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 2) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 2) }
    }

    private static var _orig3: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 3) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 3) }
    }

    private static var _orig4: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 4) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 4) }
    }

    private static var _orig5: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 5) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 5) }
    }

    private static var _orig6: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 6) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 6) }
    }

    private static var _orig7: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 7) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 7) }
    }

    private static var _orig8: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 8) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 8) }
    }

    private static var _orig9: OpaquePointer? {
        get { Storage.getOrigOpaque(for: Self.uuid + 9) }
        set { Storage.setOrigOpaque(newValue, for: Self.uuid + 9) }
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

    static var orig0: T0 { safeBitCast(_orig0, to: T0.self) }
    static var orig1: T1 { safeBitCast(_orig1, to: T1.self) }
    static var orig2: T2 { safeBitCast(_orig2, to: T2.self) }
    static var orig3: T3 { safeBitCast(_orig3, to: T3.self) }
    static var orig4: T4 { safeBitCast(_orig4, to: T4.self) }
    static var orig5: T5 { safeBitCast(_orig5, to: T5.self) }
    static var orig6: T6 { safeBitCast(_orig6, to: T6.self) }
    static var orig7: T7 { safeBitCast(_orig7, to: T7.self) }
    static var orig8: T8 { safeBitCast(_orig8, to: T8.self) }
    static var orig9: T9 { safeBitCast(_orig9, to: T9.self) }

    // Hooking

    @discardableResult
    func hook() -> [Bool] {
        var results: [Bool] = .init(repeating: false, count: 10)

        guard let cls else {
            return results
        }

        var sel1: Selector?
        var sel2: Selector?
        var sel3: Selector?
        var sel4: Selector?
        var sel5: Selector?
        var sel6: Selector?
        var sel7: Selector?
        var sel8: Selector?
        var sel9: Selector?

        var replace1: T1?
        var replace2: T2?
        var replace3: T3?
        var replace4: T4?
        var replace5: T5?
        var replace6: T6?
        var replace7: T7?
        var replace8: T8?
        var replace9: T9?

        let mirror: Mirror = .init(reflecting: self)

        for child: Mirror.Child in mirror.children {
            switch child.label {
                case "replace1":
                    replace1 = child.value as? T1
                case "replace2":
                    replace2 = child.value as? T2
                case "replace3":
                    replace3 = child.value as? T3
                case "replace4":
                    replace4 = child.value as? T4
                case "replace5":
                    replace5 = child.value as? T5
                case "replace6":
                    replace6 = child.value as? T6
                case "replace7":
                    replace7 = child.value as? T7
                case "replace8":
                    replace8 = child.value as? T8
                case "replace9":
                    replace9 = child.value as? T9
                case "sel1":
                    sel1 = child.value as? Selector
                case "sel2":
                    sel2 = child.value as? Selector
                case "sel3":
                    sel3 = child.value as? Selector
                case "sel4":
                    sel4 = child.value as? Selector
                case "sel5":
                    sel5 = child.value as? Selector
                case "sel6":
                    sel6 = child.value as? Selector
                case "sel7":
                    sel7 = child.value as? Selector
                case "sel8":
                    sel8 = child.value as? Selector
                case "sel9":
                    sel9 = child.value as? Selector
                default:
                    continue
            }
        }

        results[0] = Replace.message(cls, sel0, with: Self.opaquePointer(from: replace0), orig: &Self._orig0)

        if let replace1, let sel1 {
            results[1] = Replace.message(cls, sel1, with: Self.opaquePointer(from: replace1), orig: &Self._orig1)
        }

        if let replace2, let sel2 {
            results[2] = Replace.message(cls, sel2, with: Self.opaquePointer(from: replace2), orig: &Self._orig2)
        }
        
        if let replace3, let sel3 {
            results[3] = Replace.message(cls, sel3, with: Self.opaquePointer(from: replace3), orig: &Self._orig3)
        }
        
        if let replace4, let sel4 {
            results[4] = Replace.message(cls, sel4, with: Self.opaquePointer(from: replace4), orig: &Self._orig4)
        }
        
        if let replace5, let sel5 {
            results[5] = Replace.message(cls, sel5, with: Self.opaquePointer(from: replace5), orig: &Self._orig5)
        }
        
        if let replace6, let sel6 {
            results[6] = Replace.message(cls, sel6, with: Self.opaquePointer(from: replace6), orig: &Self._orig6)
        }
        
        if let replace7, let sel7 {
            results[7] = Replace.message(cls, sel7, with: Self.opaquePointer(from: replace7), orig: &Self._orig7)
        }
        
        if let replace8, let sel8 {
            results[8] = Replace.message(cls, sel8, with: Self.opaquePointer(from: replace8), orig: &Self._orig8)
        }
        
        if let replace9, let sel9 {
            results[9] = Replace.message(cls, sel9, with: Self.opaquePointer(from: replace9), orig: &Self._orig9)
        }

        return results
    }
}
