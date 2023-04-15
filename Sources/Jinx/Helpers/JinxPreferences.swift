//
//  Ivar.swift
//  Jinx
//
//  Created by Lilliana on 21/03/2023.
//

import CoreFoundation

// MARK: - JinxPreferences

public struct JinxPreferences {
    // MARK: Lifecycle

    public init(
        for domain: String
    ) {
        let cfDomain: CFString = getCFString(from: domain)

        if isSandboxed() {
            dict = readPlist(for: "/var/mobile/Library/Preferences/\(domain).plist") ?? [:]
        } else {
            let keyList: CFArray = CFPreferencesCopyKeyList(
                cfDomain,
                kCFPreferencesCurrentUser,
                kCFPreferencesAnyHost
            ) ?? CFArrayCreate(nil, nil, 0, nil)
            
            let cfDict: CFDictionary = CFPreferencesCopyMultiple(
                keyList,
                cfDomain,
                kCFPreferencesCurrentUser,
                kCFPreferencesAnyHost
            )
            
            dict = getDictionary(from: cfDict)
        }
    }

    // MARK: Public

    public func get<T>(
        for key: String,
        default val: T
    ) -> T {
        dict[key] as? T ?? val
    }

    // MARK: Private

    private let dict: [String: Any]
}

// MARK: Read the preferences plist to a [String: Any] dictionary

private func readPlist(
    for path: String
) -> [String: Any]? {
    let _path: String = access(path, F_OK) == 0 ? path : path.withRootPath
    
    guard let url: CFURL = CFURLCreateWithFileSystemPath(nil, getCFString(from: _path), .cfurlposixPathStyle, false) else {
        return nil
    }

    let stream: CFReadStream = CFReadStreamCreateWithFile(nil, url)
    var buffer: [UInt8] = .init(repeating: 0, count: 0x1000)
    let data: CFMutableData = CFDataCreateMutable(nil, 0)

    guard CFReadStreamOpen(stream) else {
        return nil
    }

    while CFReadStreamHasBytesAvailable(stream) {
        let byteCount = CFReadStreamRead(stream, &buffer, buffer.count)

        if byteCount > 0 {
            CFDataAppendBytes(data, buffer, byteCount)
        }
    }

    CFReadStreamClose(stream)

    return CFPropertyListCreateWithData(nil, data, 0, nil, nil)?.takeRetainedValue() as? [String: Any]
}

// MARK: Determine if we are in a sandboxed process, i.e., a user app

private func isSandboxed() -> Bool {
    #if os(macOS)
        false
    #else
        guard let url: CFURL = CFCopyHomeDirectoryURL(),
              let str: CFString = CFURLGetString(url)
        else {
            return false
        }

        return CFStringCompare(str, getCFString(from: "file:///var/mobile/"), .compareBackwards) != .compareEqualTo
    #endif
}

// MARK: CoreFoundation <3- Swift conversions

private func getCFString(
    from str: String
) -> CFString {
    let cString: UnsafeMutablePointer<Int8> = strdup(str)
    return CFStringCreateWithCString(nil, cString, CFStringBuiltInEncodings.UTF8.rawValue)
}

private func getString(
    from cfStr: CFString
) -> String {
    let length: CFIndex = CFStringGetLength(cfStr)
    let maxSize: CFIndex = CFStringGetMaximumSizeForEncoding(length, CFStringBuiltInEncodings.UTF8.rawValue)
    var buffer: [UInt8] = .init(repeating: 0, count: maxSize)
    
    guard CFStringGetCString(cfStr, &buffer, maxSize, CFStringBuiltInEncodings.UTF8.rawValue) else {
        return ""
    }
    
    return String(cString: buffer)
}

private func getDictionary(
    from cfDict: CFDictionary
) -> [String: Any] {
    var format: CFPropertyListFormat = .binaryFormat_v1_0
    let cfData: CFData? = CFPropertyListCreateData(nil, cfDict, .binaryFormat_v1_0, 0, nil)?.takeUnretainedValue()
    let cfPlist: CFPropertyList? = CFPropertyListCreateWithData(nil, cfData, 0, &format, nil).takeUnretainedValue()
    
    return cfPlist as? [String: Any] ?? [:]
}
