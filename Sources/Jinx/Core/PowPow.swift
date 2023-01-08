import Foundation
import MachO

// MARK: - PowPow

public struct PowPow {
    // MARK: Public

    public typealias AnyType = Any.Type

    public static var native: Hooker = .dynamic

    public static func orig<T>(
        _ key: AnyType
    ) -> T? {
        if let voidOrig: T = unsafeBitCast(voidMap.get(key), to: T?.self) {
            return voidOrig
        }

        if let impOrig: T = unsafeBitCast(impMap.get(key), to: T?.self) {
            return impOrig
        }

        return nil
    }

    // MARK: Internal

    @discardableResult
    static func hook(
        _ class: AnyClass,
        _ selector: Selector,
        _ replacement: some Any,
        _ key: AnyType
    ) -> Bool {
        switch _native {
            case .dynamic:
                fallthrough // This is impossible

            case .jinx:
                return hookInternal(
                    `class`,
                    selector,
                    replacement,
                    key
                )

            case .libhooker:
                return hookLibhooker(
                    `class`,
                    selector,
                    replacement,
                    key
                )

            case .substitute:
                return hookSubstitute(
                    `class`,
                    selector,
                    replacement,
                    key,
                    false
                )

            case .substrate:
                return hookSubstrate(
                    `class`,
                    selector,
                    replacement,
                    key
                )

            case .xina:
                return hookSubstitute(
                    `class`,
                    selector,
                    replacement,
                    key,
                    true
                )
        }
    }

    @discardableResult
    static func hookFunc(
        _ function: String,
        _ image: String?,
        _ replacement: UnsafeMutableRawPointer,
        _ key: AnyType
    ) -> Bool {
        if _native == .jinx || isArm64e {
            return hookFuncInternal(
                function,
                image,
                replacement,
                key
            )
        }

        return hookFuncSubstrate(
            function,
            image,
            replacement,
            key,
            _native == .xina
        )
    }

    // MARK: Private

    private static let isArm64e: Bool = {
        guard let archRaw = NXGetLocalArchInfo().pointee.name else {
            return false
        }

        return strcasecmp(archRaw, "arm64e") == 0
    }()

    private static let __native: Hooker = {
        if access(URL(fileURLWithPath: "/var/jb/usr/lib/libsubstitute.dylib").realURL().path, F_OK) == 0 {
            return .xina
        }

        let hookingLibraries: [(String, Hooker)] = [
            ("libhooker", .libhooker),
            ("libsubstitute", .substitute),
            ("libsubstrate", .substrate),
        ]

        for i in 0 ..< 3 {
            if access("/usr/lib/\(hookingLibraries[i].0).dylib", F_OK) == 0 {
                return hookingLibraries[i].1
            }
        }

        return .jinx
    }()

    private static var _native: Hooker {
        native != .dynamic ? native : __native
    }

    private static func hookFuncInternal(
        _ function: String,
        _ image: String?,
        _ replacement: UnsafeMutableRawPointer,
        _ key: AnyType
    ) -> Bool {
        var fishBones: FishBones = .init()
        var tmp: UnsafeMutableRawPointer?

        let ret: Bool = fishBones.hook(
            function,
            image,
            replacement,
            &tmp
        )

        voidMap.set(tmp, for: key)

        return ret
    }

    private static func hookFuncSubstrate(
        _ function: String,
        _ image: String?,
        _ replacement: UnsafeMutableRawPointer,
        _ key: AnyType,
        _ xina: Bool
    ) -> Bool {
        var tmp: UnsafeMutableRawPointer?
        let dylib: String = xina ? URL(fileURLWithPath: "/var/jb/usr/lib/libsusbtrate.dylib").realURL().path : "/usr/lib/libsubstrate.dylib"

        guard let MSFindSymbol: MF = getHookingSymbol(dylib, "MSFindSymbol"),
              let MSGetImageByName: MG = getHookingSymbol(dylib, "MSGetImageByName"),
              let MSHookFunction: MH = getHookingSymbol(dylib, "MSHookFunction"),
              let symbol: UnsafeMutableRawPointer = MSFindSymbol(MSGetImageByName(image ?? String(cString: _dyld_get_image_name(1))), function)
        else {
            return false
        }

        MSHookFunction(symbol, replacement, &tmp)
        voidMap.set(tmp, for: key)

        return true
    }

    private static func getHookingSymbol<T>(
        _ image: String,
        _ symbol: String
    ) -> T? {
        if let handle: UnsafeMutableRawPointer = hndlMap.get(image) {
            guard let fnSym: T = unsafeBitCast(dlsym(handle, symbol), to: T?.self) else {
                dlclose(handle)
                return nil
            }

            return fnSym
        } else {
            guard let handle: UnsafeMutableRawPointer = dlopen(image, RTLD_GLOBAL | RTLD_LAZY),
                  let fnSym: T = unsafeBitCast(dlsym(handle, symbol), to: T?.self)
            else {
                return nil
            }

            return fnSym
        }
    }

    private static func hookInternal(
        _ class: AnyClass,
        _ selector: Selector,
        _ replacement: some Any,
        _ key: AnyType
    ) -> Bool {
        guard let imp: IMP = unsafeBitCast(replacement, to: IMP?.self),
              let orig: Method = class_getInstanceMethod(`class`, selector),
              let types: UnsafePointer<Int8> = method_getTypeEncoding(orig)
        else {
            return false
        }

        let tmp: IMP = class_addMethod(`class`, selector, imp, types) ? method_getImplementation(orig) : method_setImplementation(orig, imp)
        impMap.set(tmp, for: key)

        return true
    }

    private static func hookLibhooker(
        _ class: AnyClass,
        _ selector: Selector,
        _ replacement: some Any,
        _ key: AnyType
    ) -> Bool {
        guard let LBHookMessage: LH = getHookingSymbol("/usr/lib/libblackjack.dylib", "LBHookMessage"),
              let replacementPtr: UnsafeMutableRawPointer = unsafeBitCast(replacement, to: UnsafeMutableRawPointer?.self)
        else {
            return false
        }

        var tmp: UnsafeMutableRawPointer?

        let status: Int16 = LBHookMessage(
            `class`,
            selector,
            replacementPtr,
            &tmp
        )

        voidMap.set(tmp, for: key)

        return status == 0
    }

    private static func hookSubstitute(
        _ class: AnyClass,
        _ selector: Selector,
        _ replacement: some Any,
        _ key: AnyType,
        _ xina: Bool
    ) -> Bool {
        let libPath: String = xina ? URL(fileURLWithPath: "/var/jb/usr/lib/libsubstitute.dylib").realURL().path : "/usr/lib/libsubstitute.dylib"

        guard let substitute_hook_objc_message: SH = getHookingSymbol(libPath, "substitute_hook_objc_message"),
              let replacementPtr: UnsafeMutableRawPointer = unsafeBitCast(replacement, to: UnsafeMutableRawPointer?.self)
        else {
            return false
        }

        var tmp: UnsafeMutableRawPointer?

        let status: Int32 = substitute_hook_objc_message(
            `class`,
            selector,
            replacementPtr,
            &tmp,
            nil
        )

        voidMap.set(tmp, for: key)

        return status == 0
    }

    private static func hookSubstrate(
        _ class: AnyClass,
        _ selector: Selector,
        _ replacement: some Any,
        _ key: AnyType
    ) -> Bool {
        guard let MSHookMessageEx: MX = getHookingSymbol("/usr/lib/libsubstrate.dylib", "MSHookMessageEx"),
              let replacementImp: IMP = unsafeBitCast(replacement, to: IMP?.self)
        else {
            return false
        }

        var tmp: IMP?

        MSHookMessageEx(
            `class`,
            selector,
            replacementImp,
            &tmp
        )
        
        impMap.set(tmp, for: key)

        return true
    }
}
