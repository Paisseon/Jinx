//
//  JinxPreferences.swift
//  Jinx
//
//  Created by Lilliana on 13/04/2023.
//

import CoreFoundation

public struct JinxPreferences {
    public init(
        for domain: String
    ) {
        let cfDomain: CFString = getCFString(from: domain)

        if isSandboxed() {
            dict = readPlist(for: "/var/mobile/Library/Preferences/\(domain).plist".withRootPath()) ?? [:]
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

    public func get<T>(
        for key: String,
        default val: T
    ) -> T {
        dict[key] as? T ?? val
    }

    private let dict: [String: Any]
}

private func readPlist(
    for path: String
) -> [String: Any]? {
    guard let url: CFURL = CFURLCreateWithFileSystemPath(nil, getCFString(from: path), .cfurlposixPathStyle, false) else {
        return nil
    }

    let stream: CFReadStream = CFReadStreamCreateWithFile(nil, url)
    var buffer: [UInt8] = .init(repeating: 0, count: 0x1000)
    let data: CFMutableData = CFDataCreateMutable(nil, 0)

    guard CFReadStreamOpen(stream) else {
        return nil
    }
    
    defer { CFReadStreamClose(stream) }

    while CFReadStreamHasBytesAvailable(stream) {
        let byteCount = CFReadStreamRead(stream, &buffer, buffer.count)

        if byteCount > 0 {
            CFDataAppendBytes(data, buffer, byteCount)
        }
    }

    return CFPropertyListCreateWithData(nil, data, 0, nil, nil)?.takeRetainedValue() as? [String: Any]
}

private func isSandboxed() -> Bool {
    #if os(macOS)
    return true
    #else
    guard let url: CFURL = CFCopyHomeDirectoryURL(),
          let str: CFString = CFURLGetString(url)
    else {
        return false
    }
    
    return CFStringCompare(str, getCFString(from: "file:///var/mobile/"), .compareBackwards) != .compareEqualTo
    #endif
}

private func getCFString(
    from str: String
) -> CFString {
    let cString: UnsafeMutablePointer<Int8> = strdup(str)
    return CFStringCreateWithCString(nil, cString, CFStringBuiltInEncodings.UTF8.rawValue)
}

private func getDictionary(
    from cfDict: CFDictionary
) -> [String: Any] {
    var format: CFPropertyListFormat = .binaryFormat_v1_0
    let cfData: CFData? = CFPropertyListCreateData(nil, cfDict, .binaryFormat_v1_0, 0, nil)?.takeUnretainedValue()
    let cfPlist: CFPropertyList? = CFPropertyListCreateWithData(nil, cfData, 0, &format, nil).takeUnretainedValue()

    return cfPlist as? [String: Any] ?? [:]
}
