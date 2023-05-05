//
//  Storage.swift
//  Jinx
//
//  Created by Lilliana on 22/03/2023.
//

import Darwin.C

struct Storage {
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

    private static var origsOpaque: [Int: OpaquePointer?] = [:]
    private static var origsRaw: [Int: UnsafeMutableRawPointer?] = [:]
    private static var uuids: [ObjectIdentifier: Int] = [:]
    private static let lock: Lock = .init()
}
