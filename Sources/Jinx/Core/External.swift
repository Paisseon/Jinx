//
//  External.swift
//  Jinx
//
//  Created by Lilliana on 22/03/2023.
//

import Darwin.C
import MachO

struct External {
    // MARK: Internal

    let symbol: String
    let image: String?
    let replace: UnsafeRawPointer

    func hookFunc(
        orig: inout UnsafeMutableRawPointer?
    ) -> Bool {
        switch Self.hookLib.1 {
            case .apple:
                return Rebind(image: image ?? Self.currentImage, symbol: symbol, replace: replace).rebind(storingOrig: &orig)
            case .ellekit, .libhooker:
                return lh_hookFunc(orig: &orig)
            case .substitute:
                return ss_hookFunc(orig: &orig)
        }
    }

    // MARK: Private

    private typealias CharPtrPtr = UnsafeMutablePointer<UnsafePointer<Int8>>
    private typealias VoidPtrPtr = UnsafeMutablePointer<UnsafeMutableRawPointer?>
    private static let currentImage: String = "/private" + CommandLine.arguments[0]
    
    private static let hookLib: (String, HookLib) = {
        let parts: [String] = String(cString: _dyld_get_image_name(0)).split(separator: "/").map { String($0) }
        
        switch parts.last {
            case "libinjector.dylib":
                return (parts.dropLast(2).joined(separator: "/") + "/libellekit.dylib", .ellekit)
            case "substitute-loader.dylib":
                return (parts.dropLast().joined(separator: "/") + "/libsubstrate.dylib", .substitute)
            case "TweakInject.dylib":
                return (parts.dropLast().joined(separator: "/") + "/libhooker.dylib", .libhooker)
            default:
                return ("", .apple)
        }
    }()

    // MARK: Substrate API

    private typealias MSFindSymbolType = @convention(c) (OpaquePointer?, UnsafePointer<Int8>) -> UnsafeMutableRawPointer?
    private typealias MSGetImageByNameType = @convention(c) (UnsafePointer<Int8>) -> OpaquePointer?
    private typealias MSHookFunctionType = @convention(c) (UnsafeMutableRawPointer, UnsafeRawPointer, VoidPtrPtr) -> Void

    private func ss_hookFunc(
        orig: inout UnsafeMutableRawPointer?
    ) -> Bool {
        guard let MSFindSymbol: MSFindSymbolType = Storage.getSymbol(named: "MSFindSymbol", in: Self.hookLib.0),
              let MSGetImageByName: MSGetImageByNameType = Storage.getSymbol(named: "MSGetImageByName", in: Self.hookLib.0),
              let MSHookFunction: MSHookFunctionType = Storage.getSymbol(named: "MSHookFunction", in: Self.hookLib.0),
              let sym: UnsafeMutableRawPointer = MSFindSymbol(MSGetImageByName(image ?? Self.currentImage), "_" + symbol)
        else {
            return false
        }

        MSHookFunction(sym, replace, &orig)

        return true
    }
    
    // MARK: Libhooker API
    
    private typealias LHHookFunctionsType = @convention(c) (UnsafeRawPointer, Int32) -> Int16
    private typealias LHOpenImageType = @convention(c) (UnsafePointer<Int8>) -> OpaquePointer?
    private typealias LHCloseImageType = @convention(c) (OpaquePointer?) -> Void
    private typealias LHFindSymbolsType = @convention(c) (OpaquePointer, CharPtrPtr, VoidPtrPtr, Int ) -> Bool

    private func lh_hookFunc(
        orig: inout UnsafeMutableRawPointer?
    ) -> Bool {
        guard let LHCloseImage: LHCloseImageType = Storage.getSymbol(named: "LHCloseImage", in: Self.hookLib.0),
              let LHFindSymbols: LHFindSymbolsType = Storage.getSymbol(named: "LHFindSymbols", in: Self.hookLib.0),
              let LHHookFunctions: LHHookFunctionsType = Storage.getSymbol(named: "LHHookFunctions", in: Self.hookLib.0),
              let LHOpenImage: LHOpenImageType = Storage.getSymbol(named: "LHOpenImage", in: Self.hookLib.0),
              let lhImage: OpaquePointer = LHOpenImage(image ?? Self.currentImage)
        else {
            return false
        }

        var searchSyms: [UnsafeMutableRawPointer?] = .init(repeating: nil, count: 1)
        var symbolNames: UnsafePointer<Int8> = .init(strdup("_" + symbol))

        guard LHFindSymbols(lhImage, &symbolNames, &searchSyms, 1) else {
            LHCloseImage(lhImage)
            return false
        }

        var result: Int16 = 1

        withUnsafeMutablePointer(to: &orig) { pointer in
            var hook: LHFunctionHook = .init(
                function: searchSyms[0],
                replacement: replace,
                oldptr: pointer,
                options: nil
            )

            result = LHHookFunctions(&hook, 1)
        }

        LHCloseImage(lhImage)
        return result == 0
    }
}
