//
//  HookFunc.swift
//  Jinx
//
//  Created by Lilliana on 25/03/2023.
//

public typealias HookF = HookFunc

public protocol HookFunc {
    associatedtype T
    
    var name: String { get }
    var image: String? { get }
    var replace: T { get }
}

public extension HookFunc {
    private static var uuid: Int {
        ObjectIdentifier(Self.self).hashValue
    }
    
    private static var _orig: Pointer? {
        get { Storage.getOrig(for: Self.uuid) }
        set { Storage.setOrig(newValue, for: Self.uuid) }
    }
    
    static var orig: T {
        if case .raw(let ptr) = _orig { return ptr.assumingMemoryBound(to: T.self).pointee }
        return unsafeBitCast(_orig, to: T.self)
    }
    
    @discardableResult
    func hook(
        onlyIf condition: Bool = true
    ) -> Bool {
        guard condition else {
            return false
        }
        
        let ext: External = .init(name: name, image: image, replacement: withUnsafePointer(to: replace, { UnsafeRawPointer($0) }))
        return ext.hookFunc(orig: &Self._orig)
    }
    
    @discardableResult
    func unhook() -> Bool {
        let ext: External = .init(name: name, image: image, replacement: withUnsafePointer(to: Self.orig, { UnsafeRawPointer($0) }))
        return ext.hookFunc(orig: &Self._orig)
    }
}
