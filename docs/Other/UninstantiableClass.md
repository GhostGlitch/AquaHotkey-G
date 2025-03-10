# UninstantiableClass

This class makes its subclasses uninstantiable by throwing an error upon object construction.

**Example**:

```ahk
class Foo extends Uninstantiable {
    ; ...
}

FooObj := Foo() ; Error!
```
