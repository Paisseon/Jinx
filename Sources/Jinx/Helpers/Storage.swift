//
//  Storage.swift
//  Jinx
//
//  Created by Lilliana on 22/03/2023.
//

import Darwin.C

struct Storage {
    // MARK: Internal
    
    @inlinable
    static func getOrigOpaque(
        for id: Int
    ) -> OpaquePointer? {
        origsOpaque[id] ?? nil
    }
    
    @inlinable
    static func getOrigRaw(
        for id: Int
    ) -> UnsafeMutableRawPointer? {
        origsRaw[id] ?? nil
    }

    static func getSymbol<T>(
        named symbol: String,
        in image: String
    ) -> T? {
        if let symPtr: UnsafeMutableRawPointer = libSymbols[symbol] {
            return unsafeBitCast(symPtr, to: T?.self)
        }

        let imgPtr: UnsafeMutableRawPointer

        if let _imgPtr: UnsafeMutableRawPointer = libImages[image] {
            imgPtr = _imgPtr
        } else if let _imgPtr = dlopen(image, RTLD_LAZY) {
            imgPtr = _imgPtr
            libImages[image] = imgPtr
        } else {
            return nil
        }

        let symPtr: UnsafeMutableRawPointer = dlsym(imgPtr, symbol)
        libSymbols[symbol] = symPtr

        return unsafeBitCast(symPtr, to: T?.self)
    }
    
    @inlinable
    static func getUUID(
        for obj: ObjectIdentifier
    ) -> Int {
        if let ret: Int = uuids[obj] {
            return ret
        }
        
        let newID: Int = uuids.count * 10
        uuids[obj] = newID
        
        return newID
    }
    
    @inlinable
    static func removeImage(
        named image: String
    ) {
        if let handle: UnsafeMutableRawPointer = libImages[image] {
            dlclose(handle)
        }
    }

    @inlinable
    static func setOrigOpaque(
        _ ptr: OpaquePointer?,
        for id: Int
    ) {
        lock.locked {
            origsOpaque[id] = ptr
        }
    }

    @inlinable
    static func setOrigRaw(
        _ ptr: UnsafeMutableRawPointer?,
        for id: Int
    ) {
        lock.locked {
            origsRaw[id] = ptr
        }
    }

    // MARK: Private

    private static var libSymbols: [String: UnsafeMutableRawPointer] = [:]
    private static var libImages: [String: UnsafeMutableRawPointer] = [:]
    private static var origsOpaque: [Int: OpaquePointer?] = [:]
    private static var origsRaw: [Int: UnsafeMutableRawPointer?] = [:]
    private static var uuids: [ObjectIdentifier: Int] = [:]
    private static let lock: Lock = .init()
}
