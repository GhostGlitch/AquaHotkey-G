
# **AquaHotkey**

*Class Prototyping Library for AutoHotkey v2.*

## **Overview**

```ahk
"Hello, World!".SubStr(1, 7).Append("AquaHotkey!").MsgBox()
```

AquaHotkey is a powerful and intuitive library for AutoHotkey v2 that provides
an interface for extending built-in classes and functions. Users can define new
properties and methods for built-in types like `String`, `Array`, or even
built-in functions with minimal effort.

---

## **Key Features**

- **Extend Built-In Types Easily**:

  Seamlessly extend built-in classes like `String` or `Array` with new
  properties and methods, making them feel like a natural part of the language.

- **Redefine the Rules**:

  AquaHotkey gives you the tools to bend AutoHotkey to your will, making your
  scripts not just functional, but extremely elegant and uniquely yours.

- **Modular Extension Packages**:

  Organize your property extensions into reusable, modular classes and `#Include`
  them when needed.

- **Powerful out-of-the-box extensions**:

  AquaHotkey uses its class prototyping feature to provide its own extensions
  out of the box, focusing on concise and expressive code, alongside many other
  [interesting features](#list-of-features).

---

## **Getting Started**

### **Installation**

1. Clone the repository:

   ```sh
   git clone https://www.github.com/0w0Demonic/AquaHotkey.git
   ```

2. Include `AquaHotkey.ahk` in your script:

   ```ahk
   #Requires AutoHotkey >=v2.0.5
   #Include  %A_LineFile%/../path/to/AquaHotkey.ahk
   ```

   Using `%A_LineFile%/../` is extremely useful for including files
   by relative path.

#### Using AquaHotkey_Minimal

To use a minimal version of AquaHotkey with only class prototyping and
no additional features, include `AquaHotkey_Minimal.ahk` in your script instead.

---

### **How to extend types**

#### **Step 1: Create a Subclass**

Start by creating a class that extends `AquaHotkey`, and create a nested class
named after the type to modify (e.g. "Integer"):

```ahk
class MyExtensions extends AquaHotkey {
    class Integer {

    }
}
```

#### **Step 2: Add Your Own Extensions**

Continue by writing your own properties and methods. In the example below, the
`this` keyword refers to the integer which called the method:

```ahk
class MyExtensions extends AquaHotkey {
    class Integer {
        TimesTwo() {
            return (this * 2)
        }
    }
}
```

#### **Step 3: Done!**

```ahk
Four := 2.TimesTwo()
MsgBox(Four)
```

---

## **Examples**

### **Extending `String`**

```ahk
class StringExtensions extends AquaHotkey {
    class String {
        FirstCharacter() {
            return SubStr(this, 1, 1)
        }
    }
}

"foo".FirstCharacter() ; "f"

```

### **Extending Functions**

```ahk
class FunctionExtensions extends AquaHotkey {
    class MsgBox {
        static Info(Text?, Title?) {
            return this(Text?, Title?, 0x40)
        }
    }
}

MsgBox.Info("Hello, world!")
```

---

### **Modular Packages**

AquaHotkey supports modular design, allowing you to build and reuse your own
implementations as "packages":

1. Define your extensions in separate class files.
2. Include files when needed:

   ```ahk
   #Include StringExtensions.ahk
   #Include GuiExtensions.ahk
   ```

---

## List of Features

### Function Chaining

Inspired by Elixir's `|>`, this feature greatly improves code readability
by allowing you to write expressions as long chains of arbitrary functions:

**Implicit Function Chaining** (`Any.Prototype.__Call()`):

```ahk
DoThis(Value) {

}

DoThat(Value, Arg) {

}

MyVariable.DoThis().DoThat("foo").MsgBox()
```

**Explicit Function Chaining** (`Any.Prototype.o0()`):

```ahk
class Foo {
    static Bar(Value) {
        
    }
}

Baz(Value) {
    
}

MyVariable.o0(Foo.Bar)
          .o0(Baz)
          .o0(MsgBox)
```

### Lazy-Evaluated Streams

Lazy-evaluated streams allow efficient and expressive data processing by
applying transformations sequentially, without eagerly computing intermediate
results.

- A stream is created from any enumerable object using the `.Stream()` method.
- Operations like `.RetainIf()`, `.Map()`, and `.Sum()` process elements lazily.
- Intermediate operations (such as filtering and mapping) do not modify the
  original array but instead create a transformation pipeline.
- The final result is only computed when a terminal operation (like `.Sum()`,
  `.ToArray()`, or `.First()`) is called.

**Example**:

```ahk
MyArray := [13, 12, 3, -4, 2]
Result := MyArray.Stream()                          ; for Value in Array ...
                 .RetainIf((Value) => (Value > 10)) ; [13, 12]
                 .Map((Value) => (Value * Value))   ; [169, 144]
                 .Sum()                             ; 303

#Requires AutoHotkey >=v2.1-alpha.3
MyArray := [13, 12, 3, -4, 2]
Result := MyArray.Stream().RetainIf((Num) {
    return (Num > 10)
}).Map((Num) {
    return (Num * Num)
}).Sum()
```

### Optional Type

The `Optional` type provides a way to handle values that may be `unset`,
reducing the need for explicit `if` checks. This is especially useful for
cases where a function might return a value or nothing at all.

**Example**:

```ahk
Optional("Hello world!")
        .RetainIf(InStr, "H")
        .IfPresent(MsgBox)
        .OrElseThrow(ValueError, "no value present!")

#Requires AutoHotkey >=v2.1-alpha.3
Optional("Hello, world!").RetainIf((Str) {
    return InStr(Str, "H")
}).IfPresent((Str) {
    MsgBox(Str)
}).IfAbsent(() {
    throw ValueError("no value present!")
})
```

### DLL File Interface

The DLL interface allows you to easily interact with dynamically linked libraries (DLLs), calling functions from system libraries or custom native libraries in a structured and type-safe way.

**Example Usage**:

```ahk
class CStdLib extends DLL {
    static FilePath => "msvcrt.dll"
    
    static TypeSignatures => {
        sqrtf:  ["Float", "Float"] ; float sqrtf(float arg);
        malloc: ["UPtr", "Ptr"]    ; void *malloc(size_t size);
    }
}

; DLL functions are called directly by memory address
CStdLib.sqrtf(9.0) ; 3.0

; define new function signature
CStdLib.atoi := ["Str", "Int"]
CStdLib.atoi("-4236") ; -4236
```

### COM Object Interface

The COM interface simplifies the process of working with Component Object Model
(COM) objects, allowing easy interaction with applications like Microsoft Office,
Internet Explorer, or custom COM objects.

```ahk
class InternetExplorer extends COM {
    static CLSID => "InternetExplorer.Application"
    ; static IID => "{...}"
    
    ; binds instances of `ComCall()`
    static MethodSignatures => {
        ExampleMethod: [9, "Double", "UInt"]
    }
    
    ; called after construction
    __OnStartup() {
        this.Visible := True
        this.Navigate("https://www.autohotkey.com")
    }

    ; catches events thrown by the COM object
    class EventSink extends ComEventSink
    {
        DocumentComplete(ieEventParam, &URL)
        {
            ; important: `this` refers to the `InternetExplorer` object,
            ; not the event sink!
            
            ; [COM object].Document.Title
            MsgBox(this.Document.Title)
            
            ; [COM object].Quit()
            this.Quit()
            return
        }
    }
}
```

## More Features

For a full list of features, navigate to the [API Overview](./docs/03-api-overview.md).

## About

Made with love and lots of caffeine.

- 0w0Demonic
