//
//  Table.swift
//  Jinx
//
//  Created by Lilliana on 21/03/2023.
//

import MachO

struct Table {
    let sym: UnsafeMutablePointer<nlist_64>
    let str: UnsafeMutablePointer<UInt8>
    let ind: UnsafeMutablePointer<UInt32>
    let sect: UnsafeMutablePointer<section_64>
}
