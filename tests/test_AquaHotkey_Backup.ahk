#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkeyX>

class SomeClass extends AquaHotkey_Backup {
    static __New() => super.__New(Hotkey)
}

SomeClass.OwnProps().Stream().JoinLine().MsgBox()
