#Requires AutoHotkey >=v2.0.5
#Include %A_LineFile%/../../src/AquaHotkey_Minimal.ahk

class MyExtensions extends AquaHotkey {
    class String {
        FirstCharacter() => SubStr(this, 1, 1)
    }
}

if (!ObjHasOwnProp(String.Prototype, "FirstCharacter")
    || ("foo".FirstCharacter() != "f"))
{
    throw ValueError("something went wrong during AquaHotkey init...")
}
