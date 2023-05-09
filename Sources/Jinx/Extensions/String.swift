//
//  String.swift
//  Jinx
//
//  Created by Lilliana on 13/04/2023.
//

import Darwin

public extension String {
    private static let rootPath: String = {
        let dir: UnsafeMutablePointer<DIR> = opendir("/private/preboot")
        
        while let entry: UnsafeMutablePointer<dirent> = readdir(dir) {
            let bootHash: String = .init(cString: withUnsafeBytes(of: entry.pointee.d_name) { Array($0) })
            
            if bootHash.count == 40 {
                return "/private/preboot/\(bootHash)/procursus/"
            }
        }
        
        return "/"
    }()
    
    func withRootPath() -> String {
        Self.rootPath + self
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
