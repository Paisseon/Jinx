//
//  Pointer.swift
//  Jinx
//
//  Created by Lilliana on 21/03/2023.
//

enum Pointer {
    case opaque(OpaquePointer)
    case raw(UnsafeMutableRawPointer)
}
