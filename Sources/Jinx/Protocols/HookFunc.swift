//
//  HookFunc.swift
//  Jinx
//
//  Created by Lilliana on 25/03/2023.
//

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
    
    private static var _orig: UnsafeMutableRawPointer? {
        get { Storage.getOrigRaw(for: Self.uuid) }
        set { Storage.setOrigRaw(newValue, for: Self.uuid) }
    }
    
    static var orig: T {
        _orig!.assumingMemoryBound(to: T.self).pointee
    }
    
    @discardableResult
    func hook() -> Bool {
        External(name: name, image: image, replacement: unsafeBitCast(replace, to: UnsafeRawPointer.self)).hookFunc(orig: &Self._orig)
    }
    
    @discardableResult
    func unhook() -> Bool {
        External(name: name, image: image, replacement: Self._orig!).hookFunc(orig: &Self._orig)
    }
}
