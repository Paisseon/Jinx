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

    let name: String
    let image: String?
    let replacement: UnsafeRawPointer

    func hookFunc(
        orig: inout UnsafeMutableRawPointer?
    ) -> Bool {
        if hookingLibrary.hasSuffix("libellekit.dylib") || hookingLibrary.hasSuffix("libhooker.dylib") {
            return lh_hookFunc(orig: &orig)
        } else if hookingLibrary.hasSuffix("libsubstrate.dylib") {
            return ss_hookFunc(orig: &orig)
        } else {
            return Rebind(image: image ?? currentImage, symbol: name, replacement: replacement).rebind(storingOrig: &orig)
        }
    }

    // MARK: Private

    private let currentImage: String = "/private" + CommandLine.arguments[0]
    private let hookingLibrary: String = {
        let parts: [String] = String(cString: _dyld_get_image_name(0)).split(separator: "/").map { String($0) }

        guard let endPart: String = parts.last else {
            return ""
        }

        if strstr(endPart, "substi") != nil {
            return parts.dropLast().joined(separator: "/") + "/libsubstrate.dylib"
        } else if strstr(endPart, "libho") != nil {
            return parts.dropLast().joined(separator: "/") + "/libhooker.dylib"
        } else if strstr(endPart, "ellek") != nil {
            return parts.dropLast().joined(separator: "/") + "/libellekit.dylib"
        }

        return ""
    }()

    // Hook a function using Substrate API

    private func ss_hookFunc(
        orig: inout UnsafeMutableRawPointer?
    ) -> Bool {
        guard let MSFindSymbol: MSFindSymbolType = Storage.getSymbol(named: "MSFindSymbol", in: hookingLibrary),
              let MSGetImageByName: MSGetImageByNameType = Storage.getSymbol(named: "MSGetImageByName", in: hookingLibrary),
              let MSHookFunction: MSHookFunctionType = Storage.getSymbol(named: "MSHookFunction", in: hookingLibrary),
              let sym: UnsafeMutableRawPointer = MSFindSymbol(MSGetImageByName(image ?? currentImage), name)
        else {
            return false
        }

        MSHookFunction(sym, replacement, &orig)

        return true
    }

    // Hook a function using Libhooker API

    private func lh_hookFunc(
        orig: inout UnsafeMutableRawPointer?
    ) -> Bool {
        guard let LHCloseImage: LHCloseImageType = Storage.getSymbol(named: "LHCloseImage", in: hookingLibrary),
              let LHFindSymbols: LHFindSymbolsType = Storage.getSymbol(named: "LHFindSymbols", in: hookingLibrary),
              let LHHookFunctions: LHHookFunctionsType = Storage.getSymbol(named: "LHHookFunctions", in: hookingLibrary),
              let LHOpenImage: LHOpenImageType = Storage.getSymbol(named: "LHOpenImage", in: hookingLibrary),
              let lhImage: OpaquePointer = LHOpenImage(image ?? currentImage)
        else {
            return false
        }

        var searchSyms: [UnsafeMutableRawPointer?] = .init(repeating: nil, count: 1)
        var symbolNames: UnsafePointer<Int8> = .init(strdup(name))

        guard LHFindSymbols(lhImage, &symbolNames, &searchSyms, 1) else {
            LHCloseImage(lhImage)
            return false
        }

        var result: Int16 = 1

        withUnsafeMutablePointer(to: &orig) { pointer in
            var hook: LHFunctionHook = .init(
                function: searchSyms[0],
                replacement: replacement,
                oldptr: pointer,
                options: nil
            )

            result = LHHookFunctions(&hook, 1)
        }

        LHCloseImage(lhImage)
        return result == 0
    }
}
