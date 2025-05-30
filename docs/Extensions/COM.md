# COM

The `COM` class is a user-friendly framework for COM object which allows the
user to create complex wrapper classes, complete with `ComCall()`-methods and
event handling.

---

## **Defining a Subclass**

To define a COM subclass, extend the `COM` class and provide the necessary
static properties:

### `(required) static CLSID => String`

CLSID or Prog ID of the COM object.

### `(optional) static IID => String`

IID of the interface (default IID_IDispatch).

### `(optional) static MethodSignatures => Object`

An object that contains type signatures for `ComCall()`-methods.

### `(optional) static EventSink => Class`

A nested class that handles events thrown by the COM object.

Alternatively, a static property `static EventSink => Class` can point to an
event sink class somewhere else in the script.

Instead of the event sink, the `this`-keyword used in methods of the event sink
refer to the instance of `COM` that raised the event.

Due to this change, methods of the event sink no longer accept the original COM
object as last parameter.

## Example

```ahk
class InternetExplorer extends COM {
    static CLSID => "InternetExplorer.Application"
    ; static IID => "..."

    __New(URL) {
        this.Visible := true
        this.Navigate(URL)
    }

    static MethodSignatures => {
        ; DoSomething(Arg1, Arg2) {
        ;     return ComCall(6, this, "Int", Arg1, "UInt", Arg2)
        ; }
        DoSomething: [6, "Int", "UInt"]
    }
    
    class EventSink extends ComEventSink
    {
        ; see AHK docs on `ComObjConnect()`:
        ; the last parameter `ieFinalParam` is omitted
        DocumentComplete(pDisp, &URL)
        {
            MsgBox("document completed: " . URL)
            
            ; `this` refers to the instance of `InternetExplorer`!
            ; in this example: [InternetExplorer].Quit()
            this.Quit()
        }
    }
}

ie := InternetExplorer("https://www.autohotkey.com") ; create a new COM object
ie.DoSomething(34, 9)                                ; predefined `ComCall()`
ie(6, "Ptr", 0, "Ptr")                               ; undefined `ComCall()`
```
