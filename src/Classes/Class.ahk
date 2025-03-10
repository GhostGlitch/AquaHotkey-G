/**
 * AquaHotkey - Class.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Classes/Class.ahk
 */
class Class {
    /**
     * Override of `Any.Prototype.__Call()` that throws an error.
     * @override `Any.Prototype.__Call()`
     * @example
     * 
     * Foo(Value) {
     *     MsgBox(Type(Value))
     * }
     * String.Foo() ; Error!
     * 
     * @param   {String}  MethodName  the name of the undefined method
     * @param   {Array}   Args        zero or more additional arguments
     * @return  (none)
     */
    __Call(MethodName, *) {
        throw MethodError("undefined static method: " . MethodName,, Type(this))
    }

    /**
     * Returns the class with the name of `ClassName`.
     * @example
     * 
     * (Class.ForName("Gui.ActiveX") == Gui.ActiveX) ; true
     * 
     * @param   {String}  ClassName  name of a class
     * @return  {Class}
     */
    static ForName(ClassName) {
        static Deref1(this)    => %this%
        static Deref2(VarName) => %VarName%
        static Cache := (M := Map(), M.CaseSense := false, M)

        ClassName.AssertType(String)
        if (ClassObj := Cache.Get(ClassName, false)) {
            return ClassObj
        }
        Loop Parse ClassName, "." {
            if (ClassObj) {
                ClassObj := ClassObj.%A_LoopField%
            } else if (ClassName != "this") {
                ClassObj := Deref1(A_LoopField)
            } else {
                ClassObj := Deref2(A_LoopField)
            }
            ClassObj.AssertType(Class)
        }
        return (Cache[ClassName] := ClassObj)
    }

    /**
     * Returns this class expressed as a string.
     * @example
     * 
     * Gui.ToString() ; "Class Gui"
     * 
     * @return  {String}
     */
    ToString() => "Class " . this.Prototype.__Class
}
