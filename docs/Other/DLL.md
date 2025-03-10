# DLL

## Overview

The `DLL` class provides an object-oriented interface for dynamically loading
and interacting with Windows DLLs in a clean and structured way.
It automatically resolves function addresses and binds method signatures
for type safety.

## Usage

To create a DLL wrapper, define a subclass and specify the target DLL using the
`static FilePath` property:

```ahk
class User32 extends DLL {
    static FilePath => "user32.dll"
}
```

This automatically resolves all available functions in `user32.dll` by memory
address when the class is initialized.

## Defining Function Signatures

Function parameter can be defined explicitly via:

- Assigning signatures dynamically:

  ```ahk
  User32.CharUpper := ["Str", "Str"]
  ```

- Defining them inside the subclass:

  ```ahk
  class User32 extends DLL {
      static FilePath => "user32.dll"

      class TypeSignatures => {
          MessageBox: ["Ptr", "Str", "Str", "UInt", "Int"],
          CharUpper: "Str, Str"
          ; etc.
      }
  }
  ```

## Function Resolution Behavior

- If a method is **directly defined**, it is used immediately.
- If a method is **not available**, the class automatically
  tries **appending "A" (ANSI) or "W" (Wide)** based on system architecture:
  - **32-bit AutoHotkey → Uses "A" (ANSI) functions**.
  - **64-bit AutoHotkey → Uses "W" (Unicode) functions**.
- Once resolved, the function address is retroactively added as property,
  improving performance for repeated calls.

## Limitations

- Each subclass can only reference a single DLL.
- Subclasses cannot override the `FilePath` property.
- If a DLL does not export a function table (e.g., COM-based DLLs),
  function resolution will fail.

## Error Handling

- If a requested function is not found, an explicit error message
  is thrown.
- If an invalid function signature is provided, an **error is raised
  during assignment**.

## Example Usage

```ahk
class Kernel32 extends DLL {
    static FilePath => "kernel32.dll"

    static TypeSignatures => {
        GetTickCount: ["UInt"]
    }
}

TickCount := Kernel32.GetTickCount()

; defining a function signature
Kernel32.Sleep := ["UInt"]
Kernel32.Sleep(1000) ; Sleep for 1 second
```
