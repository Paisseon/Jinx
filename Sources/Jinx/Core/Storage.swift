//
//  Storage.swift
//  Jinx
//
//  Created by Lilliana on 22/03/2023.
//

import Darwin.C

struct Storage {
    private static var libSymbols: [String: UnsafeMutableRawPointer] = [:]
    private static var libImages: [String: UnsafeMutableRawPointer] = [:]
    private static var origs: [Int: Pointer?] = [:]
    
    private static let lock: Lock = .init()
    
    static func getSymbol<T>(
        named symbol: String,
        in image: String
    ) -> T? {
        if let symPtr: UnsafeMutableRawPointer = libSymbols[symbol] {
            return symPtr.assumingMemoryBound(to: T?.self).pointee
        }
        
        let imgPtr: UnsafeMutableRawPointer
        
        if let _imgPtr: UnsafeMutableRawPointer = libImages[image] {
            imgPtr = _imgPtr
        } else {
            imgPtr = dlopen(image, RTLD_LAZY)
            libImages[image] = imgPtr
        }
        
        let symPtr: UnsafeMutableRawPointer = dlsym(imgPtr, symbol)
        libSymbols[symbol] = symPtr
        
        return symPtr.assumingMemoryBound(to: T?.self).pointee
    }
    
    static func removeImage(
        named image: String
    ) {
        if let handle: UnsafeMutableRawPointer = libImages[image] {
            dlclose(handle)
        }
    }
    
    static func getOrig(
        for id: Int
    ) -> Pointer? {
        origs[id] ?? nil
    }
    
    static func setOrig(
        _ ptr: Pointer?,
        for id: Int
    ) {
        lock.locked {
            origs[id] = ptr
        }
    }
}
