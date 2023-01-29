import Foundation
import MachO

// MARK: - PowPow

struct PowPow {
    // MARK: Internal

    static var dyldMap: HashMap<String, UnsafeMutableRawPointer> = .init()
    static var origMap: HashMap<ObjectIdentifier, Pointer?> = .init()

    // A simple version of MSHookMessageEx which works jailed
    
    static func replace(
        _ _class: AnyClass,
        _ selector: Selector,
        with replacement: some Any,
        orig _orig: inout OpaquePointer?
    ) -> JinxResult {
        guard let imp: OpaquePointer = unsafeBitCast(replacement, to: OpaquePointer?.self),
              let method: Method = class_getInstanceMethod(_class, selector),
              let types: UnsafePointer<Int8> = method_getTypeEncoding(method)
        else {
            return .noSelector
        }

        let orig: OpaquePointer = class_addMethod(_class, selector, imp, types) ?
            method_getImplementation(method) :
            method_setImplementation(method, imp)

        _orig = orig
        
        return .success
    }
    
    // If A12+ and not using ElleKit, we rebind symbols with FishBones, otherwise use Substrate API

    static func replaceFunc(
        _ function: String,
        in image: String?,
        with replacement: UnsafeMutableRawPointer,
        orig _orig: inout UnsafeMutableRawPointer?
    ) -> JinxResult {
        if native.isEmpty || isArm64e && native.hasSuffix("libellekit.dylib") {
            var fishBones: FishBones = .init()
            return fishBones.rebind(function, in: image, with: replacement, orig: &_orig)
        }

        return branch(function, in: image, with: replacement, orig: &_orig)
    }

    // MARK: Private

    // If on arm64e and not using ElleKit, we must use rebinding instead of branching

    private static let isArm64e: Bool = {
        guard let archRaw = NXGetLocalArchInfo().pointee.name else {
            return false
        }

        return strcasecmp(archRaw, "arm64e") == 0
    }()

    // This is lazy so it only runs if HookFunc.hook() is called =)

    private static let native: String = {
        var paths: [String] = [
            "/usr/lib/libellekit.dylib",
            "/usr/lib/libhooker.dylib",
            "/usr/lib/libsubstitute.dylib",
            "/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate",
            "@executable_path/Frameworks/CydiaSubstrate.framework/CydiaSubstrate"
        ]
        
        // Palera1n users-- switch to Kok3shi, it works on M1, is much more stable, functonal SEP, and has root
        
        for path in paths {
            if !path.hasPrefix("@") {
                paths.append(URL(fileURLWithPath: "/var/jb" + path).realURL().path)
            }
        }
        
        return paths.first(where: { path in
            access(path, F_OK) == 0
        }) ?? ""
    }()

    // If we have a PAC bypass, use assembly branches (preferably ElleKit)
    // Not included in Jinx itself because Jinx is static library, and I want it to be smol

    // TODO: Add hooking for the Libhooker and Substitute APIs

    private static func branch(
        _ function: String,
        in image: String?,
        with replacement: UnsafeMutableRawPointer,
        orig _orig: inout UnsafeMutableRawPointer?
    ) -> JinxResult {
        typealias MSFindSymbolType = @convention(c) (OpaquePointer?, UnsafePointer<Int8>) -> UnsafeMutableRawPointer?
        typealias MSGetImageByNameType = @convention(c) (UnsafePointer<Int8>) -> OpaquePointer?
        typealias MSHookFunctionType = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer, UnsafeMutablePointer<UnsafeMutableRawPointer?>) -> Void
        
        guard let MSFindSymbol: MSFindSymbolType = symbol("MSFindSymbol"),
              let MSGetImageByName: MSGetImageByNameType = symbol("MSGetImageByName"),
              let MSHookFunction: MSHookFunctionType = symbol("MSHookFunction"),
              let sym: UnsafeMutableRawPointer = MSFindSymbol(MSGetImageByName(image ?? String(cString: _dyld_get_image_name(1))), function)
        else {
            return .noFunction
        }
        
        MSHookFunction(sym, replacement, &_orig)
        
        return .success
    }
    
    // Get and store symbols for external hooking engines (ElleKit, Libhooker, etc.)
    
    private static func symbol<T>(
        _ sym: String
    ) -> T? {
        if let handle: UnsafeMutableRawPointer = dyldMap.get(native) {
            guard let fnSym: T = unsafeBitCast(dlsym(handle, sym), to: T?.self) else {
                dlclose(handle)
                return nil
            }
            
            return fnSym
        }
        
        if let handle: UnsafeMutableRawPointer = dlopen(native, RTLD_GLOBAL | RTLD_LAZY) {
            guard let fnSym: T = unsafeBitCast(dlsym(handle, sym), to: T?.self) else {
                dlclose(handle)
                return nil
            }
            
            dyldMap.set(handle, for: native)
            
            return fnSym
        }
        
        return nil
    }
}
