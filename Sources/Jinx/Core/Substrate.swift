//
//  Substrate.swift
//  Jinx
//
//  Created by Lilliana on 08/05/2023.
//

import Darwin.C

struct Substrate {
    let hook: RebindHook
    
    func hookFunc() -> Bool {
        guard let MSFindSymbol: T0 = Storage.getSymbol("MSFindSymbol", in: substratePath),
              let MSHookFunction: T1 = Storage.getSymbol("MSHookFunction", in: substratePath),
              let symbol: UnsafeMutableRawPointer = MSFindSymbol(nil, "_" + hook.name)
        else {
            return false
        }
        
        var orig: UnsafeMutableRawPointer? = nil
        
        MSHookFunction(symbol, hook.replace, &orig)
        hook.orig.initialize(to: orig)
        
        return true
    }
    
    private typealias T0 = @convention(c) (OpaquePointer?, UnsafePointer<Int8>) -> UnsafeMutableRawPointer?
    private typealias T1 = @convention(c) (UnsafeMutableRawPointer, UnsafeRawPointer, UnsafeMutablePointer<UnsafeMutableRawPointer?>) -> Void
    
    private let substratePath: String = {
        var buffer: [Int8] = .init(repeating: 0, count: Int(PATH_MAX))
        var path: String = "/usr/lib/libsubstrate.dylib".withRootPath
        
        if readlink(path, &buffer, buffer.count) != -1 {
            path = String(cString: buffer)
        }
        
        return path
    }()
}
