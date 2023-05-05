//
//  HookGroup.swift
//  Jinx
//
//  Created by Lilliana on 25/03/2023.
//

import ObjectiveC

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
        Storage.getUUID(for: ObjectIdentifier(Self.self))
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

    private static var _orig0: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 0) }
    private static var _orig1: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 1) }
    private static var _orig2: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 2) }
    private static var _orig3: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 3) }
    private static var _orig4: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 4) }
    private static var _orig5: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 5) }
    private static var _orig6: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 6) }
    private static var _orig7: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 7) }
    private static var _orig8: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 8) }
    private static var _orig9: OpaquePointer? { Storage.getOrigOpaque(for: Self.uuid + 9) }

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

    @discardableResult
    func hook() -> [Bool] {
        var results: [Bool] = .init(repeating: false, count: 10)
        var selectors: [Selector?] = [sel0] + .init(repeating: nil, count: 9)
        var replaces: [Any?] = [replace0] + .init(repeating: nil, count: 9)

        guard let cls else {
            return results
        }

        let mirror: Mirror = .init(reflecting: self)

        for child: Mirror.Child in mirror.children {
            if child.label?.count == 4,
               child.label?.hasPrefix("sel") == true,
               let i: Int = .init(String(child.label?.last ?? "🥺"))
            {
                selectors[i] = child.value as? Selector
            }
            
            if child.label?.count == 8,
               child.label?.hasPrefix("replace") == true,
               let i: Int = .init(String(child.label?.last ?? "🥺"))
            {
                replaces[i] = child.value
            }
        }
        
        for i: Int in 0 ..< 10 {
            if let replace: Any = replaces[i], let selector: Selector = selectors[i] {
                var orig: OpaquePointer? = nil
                results[i] = Replace.message(cls, selector, with: Self.opaquePointer(from: replace), orig: &orig)
                Storage.setOrigOpaque(orig, for: Self.uuid + i)
            }
        }

        return results
    }
}
