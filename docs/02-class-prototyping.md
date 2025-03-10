# 02 - Class Prototyping

## Basics

Writing own extension properties and methods follows a 3-step process:

1. Create a class which extends `AquaHotkey`:

   ```ahk
   class ArrayExtensions extends AquaHotkey {

   }
   ```

2. Create a nested class, named after the class to modify:

   ```ahk
   class ArrayExtensions extends AquaHotkey {
       class Array {
       
       }
   }
   ```

3. Write new properties into this nested class. The `this`-keyword refers to the
   object instance which the method belongs to (for static properties, the
   class itself).

   The syntax is exactly the same as if the nested class resembles the actual
   built-in class, making it very easy to write new properties.

   ```ahk
   class ArrayExtensions extends AquaHotkey {
       class Array {
           IsEmpty => (!this.Length)

           ExampleValue := 23

           static Create(Length) {
               /**
                * Generally, it is recommended to use `this` and `super`
                * whenever possible, to allow different behaviour depending
                * on which class called this method:
                * ```
                * class CustomArray extends Array {
                *     __New(Args*) {
                *         ; <custom behaviour>
                *         super.__New(Args*)
                *     }
                * }
                * 
                * Type(CustomArray.Create(16)) ; "CustomArray"
                * ```
                */
               Arr := this()

               Arr.Length := Length
               return Arr
           }
       }
   }
   ```

4. During runtime, the class initialization of the `AquaHotkey` class properly
   enumerates all user-defined properties and transfers them to the desired
   class or function.

   ```ahk
   Arr := [42]
   MsgBox(Arr.ExampleValue) ; 23
   
   if (Arr.IsEmpty) {
       MsgBox("this array is empty")
   } else {
       MsgBox("this array is not empty")
   }
   
   Arr := Array.Create(16)
   MsgBox("length of array " . Arr.Length)
   ```

## Remarks

- To target nested classes such as `Gui.Control`, create a nested class
  `MyExtensions.Gui.Control`:

  ```ahk
  class GuiControlExtensions extends AquaHotkey {
      class Gui {
          class Control {
              Hidden {
                  Get => (!this.Visible)
                  Set => (this.Visible := !Value)
              }
          }
      }
  }
  MyGuiControl.Hidden := true
  ```

- If two separate classes define the same property, the class
  initialized last in the script takes precedence over the first.

  ```ahk
  class StringExtension1 extends AquaHotkey {
      class String {
          MyMethod() => MsgBox("Hello from StringExtension1!")
      }
  }

  class StringExtension2 extends AquaHotkey {
      class String {
          MyMethod() => MsgBox("Hello from StringExtension2!")
      }
  }

  "foo".MyMethod() ; "Hello from StringExtension2!"
  ```

- The following special properties are ignored by this library and should
  not be modified:
  - `__New()`
  - `__Class`
  - `Call()`
  - `Prototype`

## Limitations

- **IMPORTANT**: when defining instance variable declarations for `Object` or
  `Any`, not using a function body for `__Init()` breaks the process behind
  object creation and the script will fail to work!
  [More details...](#instance-variable-declarations)

- Instance variable declarations (`__Init()` methods) don't affect primitive
  types as they cannot have their own properties and methods, and are therefore
  ignored by `AquaHotkey.__New()` when found in classes targeting
  `Primitive`, `Integer`, `Float` or `String`.

- Non-static properties added to `ComObject` have no effect when directly
  called from an instance.

  ```ahk
  class Example extends AquaHotkey {
      class ComObject {
          Type => Type(this)
      }
  }
  ie := ComObject("InternetExplorer.Application")
  ie.Type ; Error!

  ; possible workaround:
  (ComObject.Type)(ie) ; "Dictionary"
  ```

## Technical Overview

### `AquaHotkey.__New()`

The class initialization of `AquaHotkey` is responsible for transferring
properties from a property supplier (the nested classes defined by the user) to
a property receiver (any class or function in global namespace).

```ahk
class StringExtensions extends AquaHotkey {
    ; property supplier: StringExtensions.String
    ; property receiver: String
    class String {
        ; ...
    }
}
```

In case a class defines its own class initialization `static __New()`,
it must call `AquaHotkey.__New()` somewhere in its function body.

```ahk
class StringExtensions extends AquaHotkey {
    static __New() {
        ; <custom setup>
        ; ...and then call `AquaHotkey.__New()`
        super.__New()
    }
}
```

### Instance Variable Declarations

AquaHotkey allows adding instance variable declarations by modifying the
`__Init()`-method which is called during object construction.

```ahk
class ArrayExtensions1 extends AquaHotkey {
    class Array {
        ExampleValue := 23
    }
}

class ArrayExtensions2 extends AquaHotkey {
    class Array {
        Foo := "bar"
    }
}

Arr := Array(1, 2, 3, 4)
MsgBox(Arr.ExampleValue) ; 23
MsgBox(Arr.Foo)
```

**Order of Execution**:

Variable declarations are executed in the order in which they were defined in
the script. An object construction of `Array` would look like this:

```ahk
; 1. Array.Prototype.__Init            # ...
; 2. ArrayExtensions1.Prototype.__Init # ExampleValue := 23
; 3. ArrayExtensions2.Prototype.__Init # Foo := "bar"
; 4. Array.Prototype.__New             # [1, 2, 3, 4]
Arr := Array(1, 2, 3, 4)

MsgBox(Arr.ExampleValue) ; 23
MsgBox(Arr.Foo)          ; "bar"
```

### Known issues

**IMPORTANT**: when defining instance variable declarations for `Object`, use
an `__Init()`-method **with a function body**! Otherwise, the user-defined
`__Init()` call try to implicitly call `super.__Init()`, causing infinite
recursion and a stack overflow error, causing the script to fail.

```ahk
class ObjectExtensions extends AquaHotkey {
    class Object  {
        Field := "foo" ; ERROR - This breaks the entirety of Object.Call()!
        
        ; use a function body:
        __Init() {
            this.Field := "foo"
        }
    }

    ; The same problem applies to `Any.Prototype.__Init()`.
    ; 
    ; class Any {
    ;     __Init() {
    ;         ; (do something here)
    ;     }
    ; }
}

Obj := Object()
MsgBox(Obj.Field) ; "foo"
```
