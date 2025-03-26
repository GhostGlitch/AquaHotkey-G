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
 * class IntegerExtensions extends AquaHotkey {
 *     class Integer {
 *         TimesTwo() {
 *             return this * 2
 *         }
 *     }
 * }
 * (45).TimesTwo() ; 90
 */
class AquaHotkey {
    #Include %A_LineFile%/../Init/__New.ahk
}

#Include %A_LineFile%/../Init/PropertyBackup.ahk
