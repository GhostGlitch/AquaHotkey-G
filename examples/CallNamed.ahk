#Requires AutoHotkey >=v2.0.5
#Include <AquaHotkeyX>

class Kwargs_Extension extends AquaHotkey
{
    class Func {
        CallNamed(Args*) {
            ; no conversion is happening - simply return `this()`
            if (!Args.Length) {
                return this()
            }
            
            ; at this point, we use a "Signature" property to determine and
            ; assign arguments by parameter name.
            ;
            ; allowed function signatures:
            ; - String (list of names, delimited by comma ",")
            ; - Array (array of parameter names)
            ; - Map (not recommended) - parameter name --> index, vice versa
            if (!HasProp(this, "Signature")) {
                throw UnsetError('Func requires a "Signature" property')
            }
            Sig := this.Signature
            
            ; convert Signature into a more useful `Map`
            if (!IsObject(Sig)) {
                Sig := StrSplit(Sig, ",", " `r`n`t")
            }
            if (Sig is Array) {
                SigMap := Map()
                SigMap.CaseSense := false
                for ArgName in Sig {
                    if (IsObject(ArgName)) {
                        throw TypeError("Expected a String",, Type(ArgName))
                    }
                    SigMap[ArgName] := A_Index
                }
                Sig := SigMap
                this.DefineProp("Signature", { Get: (Instance) => Sig.Clone() })
            }
            if (!(Sig is Map)) {
                throw TypeError('"Signature" prop must be an Array',, Type(Sig))
            }

            ; the array of actual args passed to the function
            InputArgs := Array()
            InputArgs.Length := this.MaxParams

            ; decide how to enumerate `Args*`
            switch {
                case (Args.Length > 1): Enumer := Map(Args*).__Enum(2)
                case (Args[1] is Map):  Enumer := Args[1].__Enum(2)
                default:                Enumer := Args[1].OwnProps()
            }

            ; fill in arguments based on parameter name
            for Key, Value in Enumer {
                Index := Sig[Key]
                InputArgs[Index] := Value
            }

            ; finally, call the function
            return this(InputArgs*)
        }
    } ; class Func
} ; class Kwargs_Extension

ControlSend.Signature := (
        "Keys, Control, WinTitle, WinText, ExcludeTitle, ExcludeText")

ControlSend.CallNamed({
    Control: "Edit1",
    WinTitle: "ahk_exe notepad.exe",
    Keys: "Hello, world!{Enter}"})
