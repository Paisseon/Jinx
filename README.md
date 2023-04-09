# Jinx
*Pure Swift tweak development library for iOS and macOS*

Jinx is a library for tweak developers to write their tweaks in Swift.

## Prerequisites
- macOS device with Xcode 14 or newer
- (for using templates) Theos

## Features
- Struct-based hooks for ObjC messages and C functions
- Fearless speculative and dynamic hooking
- Supports batched hooking for ObjC messages
- Written in 100% Swift and Assembly
- No preprocessors— better for Xcode and fast compilation
- First tweak framework with SPM support =)
- Small, fast, and lightweight
- Easy templates for use with Theos (prefs or no prefs)
- Works on rootless even from non-rootless branches
- Includes preferences reader

## Installation
### Theos
1. Download the latest archive from Releases
2. Extract and run `python3 install_jinx.py`
### Without Theos
1. Simply add this repo as a dependency to your Package.swift file

## Usage
### Activating hooks
In the provided Tweak struct’s `ctor` function, initialise an instance of your hook, then run its `.hook()` function:

```swift
ExampleHook().hook()
ExampleHookGroup().hook()
ExampleHookFunc().hook()
```

### Hooking an ObjC message
```swift
struct ExampleHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> Bool

    let cls: AnyClass? = objc_lookUpClass("SomeClass")
    let sel: Selector = sel_registerName("someMethod")
    let replace: T = { _, _ in true }
}
```

### Hooking multiple ObjC messages in a single class
One `HookGroup`-conforming struct can hold `T0`-`T9` and corresponding `sel` and `replace` properties.

```swift
struct ExampleHookGroup: HookGroup {
    typealias T0 = @convention(c) (AnyObject, Selector) -> Int
    typealias T1 = @convention(c) (AnyObject, Selector) -> String

    let cls: AnyClass? = objc_lookUpClass("SomeClass")

    let sel0: Selector = sel_registerName("firstMethod")
    let sel1: Selector = sel_registerName("secondMethod")

    let replace0: T0 = { _, _ in 413 }
    let replace1: T1 = { _, _ in "EMT!" }

```

### Hooking a C, C++, or Swift function
```swift
struct ExampleHookFunc: HookFunc {
    typealias T = @convention(c) (Int) -> Void
    
    let name: String = "someFunc"
    let image: String? = "/usr/lib/system/libsomething.dylib"
    let replace: T = { _ in NSLog("Hej fra someFunc!") }
}
```

### Calling original code
For `Hook` and `HookFunc`, simply call `orig()` from within the replacement definition and pass the requisite parameters. For example, `orig(obj, sel)`. 

`HookGroup` uses `orig0` through `orig9`. These are identical to the other protocols’ `orig` except for the name, which allows unambiguity as to which sub-hook it relates.

### Getting and setting instance variables
Inside a `Hook` or `HookGroup` replacement definition, 

```swift
Ivar.get("ivarName", for: obj) // returns an optional
Ivar.set("ivarName", for: obj, to: 413)
```

### Dynamic hooking
To use dynamic hooking (i.e., hooking a class and method determined at runtime), you can abstain from assigning a value to cls and/or sel in the struct definition and instead assign it during initialisation.

The same principle goes for `HookGroup` and `HookFunc` with their respective properties.

```swift
ExampleHook(cls: objc_lookUpClass(someString), sel: sel_registerName(anotherString)).hook()
```

### Reading preferences
Preferences are stored in the JinxPreferences struct. Simply create an instance of this struct and use `let isEnabled: Bool = prefs.get(for: "isEnabled", default: true)`