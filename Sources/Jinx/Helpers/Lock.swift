//
//  Lock.swift
//  Jinx
//
//  Created by Lilliana on 22/03/2023.
//

import Darwin.C

struct Lock {
    private let lock: UnsafeMutablePointer<os_unfair_lock>
    
    init() {
        let _lock: UnsafeMutablePointer<os_unfair_lock> = .allocate(capacity: 1)
        _lock.initialize(to: os_unfair_lock())
        
        lock = _lock
    }
    
    @inlinable
    func locked<T>(
        _ fn: () throws -> T
    ) rethrows -> T {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        return try fn()
    }
}
