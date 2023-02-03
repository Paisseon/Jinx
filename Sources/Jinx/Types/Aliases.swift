import ObjectiveC

// MARK: Libhooker API

typealias LBHookMessageType = @convention(c) (
    AnyClass,
    Selector,
    UnsafeMutableRawPointer,
    UnsafeMutableRawPointer?
) -> Int16

typealias LHHookFunctionsType = @convention(c) (
    UnsafeMutableRawPointer,
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
    UnsafeMutableRawPointer,
    UnsafeMutableRawPointer,
    UnsafeMutablePointer<UnsafeMutableRawPointer?>
) -> Void

typealias MSHookMessageExType = @convention(c) (
    AnyClass,
    Selector,
    OpaquePointer,
    UnsafeMutablePointer<OpaquePointer?>
) -> Void
