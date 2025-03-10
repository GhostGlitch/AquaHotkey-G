#Requires AutoHotkey >=v2.0.5

;@Ahk2Exe-IgnoreBegin
if (A_ScriptFullPath == A_LineFile) {
    MsgBox("This file should not be run directly. Use #Include to import it.",
           "AquaHotkey", 0x40)
    ExitApp(1)
}
;@Ahk2Exe-IgnoreEnd

/**
 * @example
 * 
 * class StringExtensions extends AquaHotkey {
 *     class String {
 *         FirstCharacter() {
 *             return SubStr(this, 1, 1)
 *         }
 *     }
 * }
 * "foo".FirstCharacter() ; "f"
 */
class AquaHotkey
{
#Include %A_LineFile%/../Init/__New.ahk

#Include %A_LineFile%/../Classes/Any.ahk
#Include %A_LineFile%/../Classes/Array.ahk
#Include %A_LineFile%/../Classes/BoundFunc.ahk
#Include %A_LineFile%/../Classes/Buffer.ahk
#Include %A_LineFile%/../Classes/Class.ahk
#Include %A_LineFile%/../Classes/ClipboardAll.ahk
#Include %A_LineFile%/../Classes/Closure.ahk
#Include %A_LineFile%/../Classes/ComObject.ahk
#Include %A_LineFile%/../Classes/ComValue.ahk
#Include %A_LineFile%/../Classes/ComValueRef.ahk
#Include %A_LineFile%/../Classes/Enumerator.ahk
#Include %A_LineFile%/../Classes/Error.ahk
#Include %A_LineFile%/../Classes/File.ahk
#Include %A_LineFile%/../Classes/Float.ahk
#Include %A_LineFile%/../Classes/Func.ahk
#Include %A_LineFile%/../Classes/Gui.ahk
#Include %A_LineFile%/../Classes/InputHook.ahk
#Include %A_LineFile%/../Classes/Integer.ahk
#Include %A_LineFile%/../Classes/Map.ahk
#Include %A_LineFile%/../Classes/Menu.ahk
#Include %A_LineFile%/../Classes/MenuBar.ahk
#Include %A_LineFile%/../Classes/Number.ahk
#Include %A_LineFile%/../Classes/Object.ahk
#Include %A_LineFile%/../Classes/Primitive.ahk
#Include %A_LineFile%/../Classes/RegExMatchInfo.ahk
#Include %A_LineFile%/../Classes/String.ahk
#Include %A_LineFile%/../Classes/VarRef.ahk

#Include %A_LineFile%/../Functions/ClipWait.ahk
#Include %A_LineFile%/../Functions/DirSelect.ahk
#Include %A_LineFile%/../Functions/FileOpen.ahk
#Include %A_LineFile%/../Functions/FileSelect.ahk
#Include %A_LineFile%/../Functions/Hotkey.ahk
#Include %A_LineFile%/../Functions/MsgBox.ahk
#Include %A_LineFile%/../Functions/OnClipboardChange.ahk
#Include %A_LineFile%/../Functions/OnError.ahk
#Include %A_LineFile%/../Functions/OnExit.ahk
#Include %A_LineFile%/../Functions/TrayTip.ahk
}

#Include %A_LineFile%/../Other/COM.ahk
#Include %A_LineFile%/../Other/ComEventSink.ahk
#Include %A_LineFile%/../Other/Comparator.ahk
#Include %A_LineFile%/../Other/Control.ahk
#Include %A_LineFile%/../Other/DLL.ahk
#Include %A_LineFile%/../Other/DllCallType.ahk
#Include %A_LineFile%/../Other/DllFunc.ahk
#Include %A_LineFile%/../Other/Optional.ahk
#Include %A_LineFile%/../Other/Process.ahk
#Include %A_LineFile%/../Other/Range.ahk
#Include %A_LineFile%/../Other/Stream.ahk
#Include %A_LineFile%/../Other/UninstantiableClass.ahk
#Include %A_LineFile%/../Other/Window.ahk