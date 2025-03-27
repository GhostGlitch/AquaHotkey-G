#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkey_Minimal>

class StringUtil extends AquaHotkey {
    class String {
        Length => StrLen(this)

        __Item[n] => SubStr(this, n, 1)
    }
}

MsgBox(Format("
(
"foo".Length == {1}
("bar")[1] == {2}
)", "foo".Length, ("bar")[1]))