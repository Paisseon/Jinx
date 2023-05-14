//
//  RebindHook.swift
//  Jinx
//
//  Created by Lilliana on 21/03/2023.
//

struct RebindHook {
    let name: String
    let replace: UnsafeMutableRawPointer
    let orig: UnsafeMutablePointer<UnsafeMutableRawPointer?>
}
