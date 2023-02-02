# Jinx
*Pure Swift tweak development framework for iOS 12-16*

This is a tool for tweak developers. Probably just me tbh, but others are welcome to use any or all of it they want. If you are an end user, this repo means nothing for you.

Please note that this does require a macOS device with Xcode to compile. You’ll also need to run `make spm` and open the Package.swift file in Xcode at least once, as Jinx is distributed through SPM.

## Features
- Hook ObjC messages, C/C++/Swift functions, and ivars
- Fearless speculative and dynamic hooking
- Support for Libhooker, Substrate, and internal APIs
- 100% Swift and ARM64 Assembly
- Works on jailed devices without injecting Substrate
- No preprocessor needed, you can use this in an app
- Uses SPM for automatic (developer-end) updates
- Fast, small, and lightweight
- Read preferences from sandboxed processes w/ Powder
- Returns useful error codes for debugging
- Two easy templates to use with Theos

## Installation
1. Make sure that Theos (Orion branch) is already installed
2. Download the latest archive from Releases
3. Extract and run `python3 install_jinx.py`
4. Done!

## Usage
### Hooking ObjC Messages
The Hook protocol is the one which you will most often use, as it is responsible for hooking Objective-C messages.

There are four immutable variables which you must define in a struct conforming to Hook:

- **T**: typealias for the signature of the hooked method. Must conform to the C convention.
- **\`class\`**: `AnyClass?`. The class you will hook. A `nil` value will prevent the hook from taking place.
- **selector**: `Selector`. The name of the method you will hook.
- **replacement**: `T`. A closure which replaces the original code.

There is also one function which can be used.

- **hook(onlyIf: Bool)**: `(Bool) -> Bool`. Returns true if the hook succeeds, and false if it fails. The onlyIf parameter defaults to true.

## Hooking Functions
The HookFunc protocol is responsible for hooking C, C++, and Swift functions.

There are four immutable variables which you must define.

- **T**: typealias for the signature of the hooked function. Must conform to the C convention.
- **function**: `String`. The symbol of the function you will hook. Must have a leading underscore. For C++/Swift functions, use the mangled name.
- **image**: `String?`. The path to the image containing the target function. You may pass `nil` to refer to the current process.
- **replacement**: `T`. A closure which replaces the original code.

There is also one function which can be used.

- **hook(onlyIf: Bool)**: `(Bool) -> Bool`. Returns true if the hook succeeds, and false if it fails. The onlyIf parameter defaults to true.

## Calling Original Code
To call original implementation of a message or function, you can add `orig()` to your `replacement`. Just supply the arguments of the closure and you’re good to go.

## Hooking Instance Variables
To set an instance variable from inside a hook, you can use `Mouser.setIvar(_:for:to:)` with the name, object reference, and desired value.

You can also get the value of an instance variable with `Mouser.getIvar(_:for:)` with the name and object reference.

## Getting Preferences
To get preferences, you will need to use the tweak\_swift\_jinx\_prefs template, which includes by default all the requisite code. 

In the Helpers/Preferences.swift file, you will see a variable `isEnabled`, just follow that pattern for assigning variables and change the Root.plist file in Resources folder accordingly.