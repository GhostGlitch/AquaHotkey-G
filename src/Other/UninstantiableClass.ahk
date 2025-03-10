/**
 * AquaHotkey - UninstantiableClass.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/UninstantiableClass.ahk
 * 
 * **Overview**:
 * 
 * This class makes its subclasses uninstantiable by overriding the
 * `static Call()` method and throwing an error on object construction.
 * 
 * @example
 * 
 * class Foo extends UninstantiableClass {
 * 
 * }
 * 
 * FooObj := Foo() ; Error!
 */
class UninstantiableClass {
    static Call(*) {
        throw ValueError("this class is not instantiable",,
                         this.Prototype.__Class)
    }

    __New(*) {
        throw ValueError("this class is not instantiable",,
                         "UninstantiableClass")
    }
}
