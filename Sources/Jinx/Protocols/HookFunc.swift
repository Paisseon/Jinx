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
        unsafeBitCast(_orig, to: T.self)
    }
    
    @discardableResult
    func hook() -> Bool {
        External(symbol: name, image: image, replace: unsafeBitCast(replace, to: UnsafeMutableRawPointer.self)).hookFunc(orig: &Self._orig)
    }
    
    @discardableResult
    func unhook() -> Bool {
        External(symbol: name, image: image, replace: Self._orig!).hookFunc(orig: &Self._orig)
    }
}
