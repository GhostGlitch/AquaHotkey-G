#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkey_Minimal>

class DefaultFalse extends AquaHotkey {
    class Array {
        Default := false
    }

    class Map {
        Default := false
    }
}

ArrayObj  := Array(unset, unset, unset)
ArrayItem := ArrayObj[3]
MapObj    := Map()
MapItem   := MapObj["foo"]

MsgBox(Format("
(
ArrayObj := Array(unset, unset, unset)
MapObj := Map()

ArrayObj[3] == {1}
MapObj["foo"] == {2}

For more information, see:
    docs/02-class-prototyping.md#instance-variable-declarations
)", ArrayItem, MapItem))