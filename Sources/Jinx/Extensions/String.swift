//
//  String.swift
//  Jinx
//
//  Created by Lilliana on 13/04/2023.
//

import Darwin.POSIX

public extension String {
    func withRootPath() -> String {
        #if JINX_ROOTLESS
        ("/var/jb" + self).resolvingSymlinks()
        #else
        self
        #endif
    }
    
    func resolvingSymlinks() -> String {
        var buffer: [Int8] = .init(repeating: 0, count: Int(PATH_MAX))
        var path: String = self
        
        if readlink(path, &buffer, buffer.count) != -1 {
            path = String(cString: buffer)
        }
        
        return path
    }
}
