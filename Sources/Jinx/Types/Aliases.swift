//
//  Aliases.swift
//  Jinx
//
//  Created by Lilliana on 21/03/2023.
//

// MARK: Libhooker API

typealias LHHookFunctionsType = @convention(c) (
    UnsafeRawPointer,
    Int32
) -> Int16

typealias LHOpenImageType = @convention(c) (
    UnsafePointer<Int8>
) -> OpaquePointer?

typealias LHCloseImageType = @convention(c) (
    OpaquePointer?
) -> Void

typealias LHFindSymbolsType = @convention(c) (
    OpaquePointer,
    UnsafeMutablePointer<UnsafePointer<Int8>>,
    UnsafeMutablePointer<UnsafeMutableRawPointer?>,
    Int
) -> Bool

// MARK: Substrate API

typealias MSFindSymbolType = @convention(c) (
    OpaquePointer?,
    UnsafePointer<Int8>
) -> UnsafeMutableRawPointer?

typealias MSGetImageByNameType = @convention(c) (
    UnsafePointer<Int8>
) -> OpaquePointer?

typealias MSHookFunctionType = @convention(c) (
    UnsafeRawPointer,
    UnsafeRawPointer,
    UnsafeMutablePointer<UnsafeMutableRawPointer?>
) -> Void
