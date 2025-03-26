# 02 - Class Prototyping

AutoHotkey’s built-in classes are powerful, but they cannot easily be extended
dynamically. You cannot easily add a method to `Array` or `Gui`. Unless you want
to deep-dive into the intrinsics of class prototyping, you're forced to write
**wrapper functions** like this:

```ahk
; traditional approach without AquaHotkey
Array_Sum(Arr) {
    Result := 0
    for Value in Arr {
        Result += Value
    }
    return Result
}

Arr := [1, 2, 3, 4]
MsgBox(Array_Sum(Arr)) ; 10
```

This works, but it **doesn't feel natural**. Wouldn't it be better if you could
call `Sum()` directly as an array method?
That's exactly what AquaHotkey's class prototyping does for you:

```ahk
class ArrayExtensions extends AquaHotkey {
    class Array {
        Sum() {
            Result := 0
            for Value in this {
                Result += Value
            }
            return Result
        }
    }
}
```

## Basics

Writing own extension properties and methods is extremely easy, just follow
these three steps:

1. Create a class which extends `AquaHotkey`:

   ```ahk
   class ArrayExtensions extends AquaHotkey {

   }
   ```

2. Create a nested class, named after the target class you want to modify:

   ```ahk
   class ArrayExtensions extends AquaHotkey {
       class Array {
       
       }
   }
   ```

3. Create new properties, exactly as if you were working on the actual
   built-in class.

   ```ahk
   class ArrayExtensions extends AquaHotkey {
       class Array {
           IsEmpty => (!this.Length)

           Sum() {
               Result := 0
               for Value in this {
                   Result += Value
               }
               return Result
           }
       }
   }
   ```

4. During runtime, the `AquaHotkey` class transfers will process all of your
   custom properties, adding them to the desired class or function accordingly.

   ```ahk
   Arr := [1, 2, 3, 4]
   Arr.IsEmpty ; false
   Arr.Sum() ; 15
   ```

**Remarks**:

- Properties `__Class` and `Prototype` are intentionally ignored.
- If your class overrides `static __New()` make sure to call `super.__New()`
  to ensure that properties and methods are processed correctly by AquaHotkey.

  ```ahk
  class MyExtensions extends AquaHotkey {
      static __New() {
          ; Extra setup, e.g. forcing a backup or defining more properties
          ; and methods dynamically

          ; (see [## Preserving Original Methods When Overriding])
          (ArrayBackup)

          ; ... and then call `super.__New()`
          super.__New()
      }

      ; etc.
  }
  ```

## Extending `Gui` controls

The same logic applies for targeting nested classes such as `Gui.Control`.

**Example - Define a `Hidden` property for `Gui.Control`**:

```ahk
class GuiControlExtensions extends AquaHotkey
{
    ; GuiControlExtensions.Gui -> Gui
    class Gui
    {
        ; GuiControlExtensions.Gui.Control -> Gui.Control
        class Control {
            Hidden {
                get => (!this.Visible)
                set => (this.Visible := !value)
            }
        }
    }
}
```

## Instance Variable Declarations

AquaHotkey lets you add custom fields (a.k.a. instance variables) to
built-in objects by writing them inside the `__Init()` method, which
runs when the object is created.

You don’t have to write `__Init()` yourself - just declare your
variables like this:

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
Arr.ExampleValue ; 23
Arr.Foo          ; "bar"
```

Note that these declarations are ignored for primitive classes
(`Integer`, `Float`, `String`) as they cannot have their own properties/methods.

**Order of Execution**:

Variable declarations are executed in the order in which they were defined in
the script. A field declaration of `Array` could look like this:

```ahk
; 1. Array.Prototype.__Init            # ...
; 2. ArrayExtensions1.Prototype.__Init # ExampleValue := 23
; 3. ArrayExtensions2.Prototype.__Init # Foo := "bar"
; 4. Array.Prototype.__New             # [1, 2, 3, 4]
Arr := Array(1, 2, 3, 4)

MsgBox(Arr.ExampleValue) ; 23
MsgBox(Arr.Foo)          ; "bar"
```

***IMPORTANT***:

>When defining instance variable declarations for `Object` and `Any`, use
an `__Init()`-method **with a function body**!

Otherwise, the user-defined `__Init()` will infinitely recurse, causing the
script to fail.

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

## Preserving Original Methods When Overriding

When you define new properties or methods using AquaHotkey’s class prototyping,
**any existing properties are completely overwritten** - no questions asked.
This includes native built-in methods and user-defined extensions from earlier classes.
AquaHotkey doesn't currently check for conflicts (except for a few special cases like
`__Class` or `Prototype`, which are intentionally ignored).

This means if you redefine something like the constructor of `Gui`, the original
behavior is lost - unless you save it yourself beforehand.

### Manually Preserving Properties

Overwriting destroys the original behavior. When you override a built-in
method, the original one is gone unless you manually save it:

```ahk
; manually save the old constructor as `OldGuiConstructor`
Old_Gui_New := Gui.Prototype.__New

class GuiExtensions extends AquaHotkey {
    class Gui {
        __New(Args*) {
            ; call the old gui constructor
            Old_Gui_New(this, Args*)

            MsgBox("Custom GUI behavior!")
        }
    }
}
```

### With `PropertyBackup` - A Cleaner Approach

Instead of manually storing functions, `PropertyBackup` automates this process.

To use it, extend `PropertyBackup` and set `static Class` to the target
class whose properties should be preserved.

```ahk
class OriginalGui extends PropertyBackup {
    static Class => Gui ; this creates a snapshot of `class Gui`
}

class GuiExtensions extends AquaHotkey
{
    static __New() {
        ; force a backup into `OriginalGui` before modifying anything
        (OriginalArray)
        super.__New()
    }

    class Gui {
        __New(Args*) {
            (OriginalGui.Prototype.__New)(this, Args*)
            MsgBox("Custom GUI behaviour!")
        }
    }
}
```

Now, `OriginalGui` automatically **preserves all methods and properties** -
making modifications much safer and cleaner.
