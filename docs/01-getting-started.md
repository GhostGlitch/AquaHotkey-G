# 01 - Getting Started

## Overview

AquaHotkey consists of two separate components:

**1. Class Prototyping**:

A feature that is used to define custom methods and properties for built-in
classes.

**2. Type Extensions**:

An extensive and expressive API that builds on the previous component, providing
a large variety of new methods and properties for built-in classes and other
interesting tools.

## Installation and Setup

1. Clone the repository anywhere:

   ```sh
   git clone https://www.github.com/0w0Demonic/AquaHotkey.git
   ```

   Consider moving the repository into a standard library path such as
   `A_MyDocuments\AutoHotkey\Lib` so it can be imported more easily.

2. Include AquaHotkey.ahk in your script:

   ```ahk
   #Requires AutoHotkey >=v2.0.5
   #Include <AquaHotkey>

   ; #Include path/to/AquaHotkey.ahk
   ```

   Note: using `%A_LineFile%/../` is very useful for loading files by
   relative path, as it describes the directory in which the current file
   is located.

3. Done! Feel free to continue by [writing your own extensions](02-class-prototyping.md)
   or by reading the [API reference](./03-api-overview.md) to get started with
   AquaHotkey's built-in class API.

### Using AquaHotkey_Minimal

To use a minimal version of AquaHotkey with only class prototyping and
no additional features, use `AquaHotkey_Minimal.ahk` instead:

```ahk
#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkey_Minimal>

; #Include path/to/AquaHotkey_Minimal.ahk
```

The minimal version of AquaHotkey is useful whenever the full API is not needed.

## Class Prototyping - Basics

1. Create a subclass of `AquaHotkey`:

   ```ahk
   class StringExtensions extends AquaHotkey {
       
   }
   ```

2. Inside your new class, create a nested class named after the desired type:

   ```ahk
   class StringExtensions extends AquaHotkey {
       class String {
       
       }
   }
   ```

3. The nested class behaves exactly if it was the actual built-in class
   (in this example, `String`). Now continue by implementing new properties:

   ```ahk
   class StringExtensions extends AquaHotkey {
       class String {
           Append(Str) {
               return this . Str ; `this` - the string instance
           }
       }
   }
   ```

4. Done! In this example, built-in `String` now has an `.Append()` method.

   ```ahk
   "Hello ".Append("world!") ; "Hello, world!"
   ```

Reference [Class Prototyping](./02-class-prototyping.md) for a more detailed
guide to class prototyping.

## AquaHotkey's Built-in Library

AquaHotkey builds on its class prototyping to create an extensive API, complete
with extensions for built-in types and a range of other utilities.
Every tool and feature is designed to integrate seemlessly with each other,
allowing users to effortlessly chain methods into complex expressions, often
with just one line of code.

These concepts not only promote cleaner and safer code but also introduce a
declarative syntax that simplifies operations on data.
AquaHotkey embraces functional programming paradigms like
immutability, higher-order functions and implements features like lazy-evaluated
streams and optional types.

```ahk
Squared(Value) {
    return Value * Value
}

; "square numbers 1-10: 1, 4, 9, 16, 25, 36, 49, 64, 81, 100"
Range(1, 10).Map(Squared).Join(", ").Prepend("square numbers 1-10: ").MsgBox()
```

For a comprehensive guide to everything AquaHotkey offers, refer to
the [API Overview](./03-api-overview.md).
