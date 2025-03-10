/**
 * AquaHotkey - Any.ahk - TESTS
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Classes/Any.ahk
 */
class Any {
    static __Call() {
        65.Chr().AssertEquals("A")
    }

    static o0() {
        65.o0(Chr).AssertEquals("A")
    }

    static BindMethod() {
        Arr      := Array()
        ArrPush1 := Arr.BindMethod("Push", 1)

        Loop 5 {
            ArrPush1()
        }

        Arr.Join(" ").AssertEquals("1 1 1 1 1")
    }

    static Store1() {
        ("Hello, world!").Store(&Result)

        Result.AssertEquals("Hello, world!")
    }

    static Store2() {
        Obj := Object().Store(&Copy)
        Obj.DefineProp("Age", { Value: 12 })
        HasProp(Copy, "Age").AssertEquals(false)
    }

    static Store3() {
        SubStr.Bind("Hello, world!").Store(&Copy).Call(1, 1).AssertEquals("H")
        Copy.AssertType(BoundFunc)
    }

    static Property_Type() {
        "Hello world!".Type.AssertEquals("String")
    }

    static Property_Class() {
        "Hello world!".Class.AssertEquals(String)
    }

    static Stream1() {
        "Hello world!".Stream()
    }

    static Stream2() {
        "Hello world!".Stream(2)
    }
    
    static Optional() {
        "Hello world!".Optional().AssertType(Optional)
    }

    static AssertNumber1() {
        Num := 912.12
        Num.AssertNumber()
    }

    static AssertNumber2() {
        Num := "912.12"
        Num.AssertNumber().AssertType(Float)
    }

    static AssertInteger1() {
        Int := 123
        Int.AssertInteger()
    }

    static AssertInteger2() {
        Int := "123"
        Int.AssertInteger().AssertType(Integer)
    }

    static AssertCallable1() {
        Obj := Object()
        Obj.Call := (Obj) => MsgBox("Hello world!")

        Obj.AssertCallable()
    }

    static AssertCallable2() {
        TestSuite.AssertThrows(() => (
            InStr.AssertCallable(0)
        ))
    }
}
