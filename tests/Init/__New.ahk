/**
 * AquaHotkey - TestSuite.__New
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - tests/Init/__New.ahk
 */
static __New() {
    Output := ""
    for ClsName in ObjOwnProps(this) {
        Cls := this.%ClsName%
        if (!(Cls is Class)) {
            continue
        }
        for PropertyName in ObjOwnProps(Cls) {
            if (!HasMethod(Cls, PropertyName) || (PropertyName == "__Init")) {
                continue
            }

            Function := Cls.%PropertyName%
            try {
                Function(Cls)
                Output .= FormatTestResult(Function, true)
            } catch as E {
                Output .= FormatTestResult(Function, false, E)
            }
        }
        Output .= "=".Repeat(60) . "`n"
    }

    Output.ToClipboard()

    ; (G := Gui()).SetFont("s9", "Cascadia Code")
    ; EditField := G.AddEdit("w500 h500 readonly -Wrap HScroll", Output)
    ; G.Show("autosize")

    ; OutputFile := FileOpen(A_LineFile . "/../test_results.txt", "w")
    ; OutputFile.Write(Output)
    ; OutputFile.Close()

    static FormatTestResult(Function, Successful, E?) {
        StartIndex    := InStr(Function.Name, ".") + 1
        SeparatorLine := "-".Repeat(60) . "`n"
        static FormatStack(E) {
            Pattern     := "m).*?(\(\d+\)) : (\S++)"
            Replacement := "> $2 $1"
            Stack       := E.Stack
            return RegExReplace(Stack, Pattern, Replacement)
        }
        static Check(Boolean) {
            return (Boolean) ? "x" : " "
        }
        Name   := SubStr(Function.Name, StartIndex)
        Output := Format("{:-57}[{}]`n", Name, Check(Successful))
        if (IsSet(E)) {
            Output .= SeparatorLine
            Output .= E.Message . "`n"
            if (E.Extra == "") {
                E.Extra := '""'
            }
            Output .= "Specifically: " . E.Extra . "`n"
            Output .= FormatStack(E)
            Output .= SeparatorLine
        }
        return Output
    }
}
