# Jinx
*Pure Swift tweak development framework for iOS 12-16*

This is a tool for tweak developers. Probably just me tbh, but others are welcome to use any or all of it they want. If you are an end user, this repo means nothing for you.

## Features
- Hook ObjC messages, C functions, and ivars
- Fearless speculative and dynamic hooking
- Support for all hooking engines and jailbreaks
- 100% pure Swift and Assembly
- Works perfectly on jailed and rootless environments
- No preprocessor needed, you can use this in an app
- Uses SPM for automatic (developer-end) updates
- Fast, small, and lightweight (less than 1000 lines)
- Read preferences from sandboxed processes
- Two easy templates to use

## Installation
1. Make sure that Theos is already installed
2. Download the latest Jinx\_Installer.zip from Releases
3. Extract and run `python3 install_jinx.py`
4. Install [mryipc][1] if you want to use preferences
5. Done!

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

## Hooking C Functions
The HookFunc protocol is responsible for hooking C functions.

There are four immutable variables which you must define.

- **T**: typealias for the signature of the hooked function. Must conform to the C convention.
- **function**: `String`. The symbol of the function you will hook. Must have a leading underscore.
- **image**: `String?`. The path to the image containing the target function. You may pass `nil` to access functions from the   shared cache.
- **replacement**: `T`. A closure which replaces the original code.

There is also one function which can be used.

- **hook(onlyIf: Bool)**: `(Bool) -> Bool`. Returns true if the hook succeeds, and false if it fails. The onlyIf parameter defaults to true.

## Calling Original Code
PowPow is used for abstracting the actual hooking so that you can just use Hook and HookFunc, but it also can get the original code (which is stored in HashMap)

Just use `let orig: T = PowPow.orig(HookName.self)!`. It returns `T?`, which can be unwrapped and handled, or forcefully unwrapped. I opt for the latter, but the option is up to you.

This is used for both messages and functions.

## Hooking Ivars
Mouser can set the values of ivars with the setIvar function.

Just use `Mouser.setIvar(object:name:val:)` and pass the object reference, ivar name, and desired value.

## Setting the Backend
By default, Jinx uses a dynamic backend, which uses the native hooking engine or falls back to an internal hooking. However, you can set this manually with the PowPow.native variable, which is of type Hooker.

Possible values are `.dynamic` (default), `.jinx`, `.libhooker`, `.substitute`, `.substrate`, and `.xina`.

[1]:	https://github.com/Muirey03/MRYIPC "mryipc"