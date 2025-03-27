#Requires AutoHotkey >=v2.0.5
#Include %A_LineFile%/../../../AquaHotkey_Minimal.ahk

class DarkGui extends AquaHotkey {
    class Backup extends PropertyBackup {
        static Class => Gui
    }

    static __New() {
        (this.Backup)
        super.__New()
    }

    class Gui {
        __New(Args*) {
            (DarkGui.Backup.Prototype.__New)(this, Args*)
            this.BackColor := 0x171717 ; TODO
            
            
            if (VerCompare(A_OSVersion, "10.0.17763") >= 0) {
                DWMWA_USE_IMMERSIVE_DARK_MODE := 19
                if (VerCompare(A_OSVersion, "10.0.18985") >= 0) {
                    DWMWA_USE_IMMERSIVE_DARK_MODE := 20
                }
                    
                uxtheme := DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr")
                SetPreferredAppMode := DllCall("GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
                FlushMenuThemes := DllCall("GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
                
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                    "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", true, "Int", 4)
                DllCall(SetPreferredAppMode, "Int", 2)
                DllCall(FlushMenuThemes)
            }
            
            DllCall(SetPreferredAppMode, "Int", 1)
            DllCall(FlushMenuThemes)
        }
        
        class Control {
            ApplyDarkTheme() {
                
            }
            
            Redraw() {
                DllCall("InvalidateRect", "Ptr", this.Hwnd, "Ptr", 0, "Int", true)
            }
            
            Destroy() {
                DllCall("DestroyWindow", "UPtr", this.Hwnd)
            }
            
            ExStyle {
                get => ControlGetExStyle(this.Hwnd)
                set => ControlSetExStyle(value, this.Hwnd)
            }
            
            Style {
                get => ControlGetStyle(this.Hwnd)
                set => ControlSetStyle(value, this.Hwnd)
            }
        }
        
        Add(Args*) {
            Ctl := (DarkGui.Backup.Prototype.Add)(this, Args*)
            Ctl.ApplyDarkTheme()
            return Ctl
        }
        
        AddText(Args*)   => this.Add("Text", Args*)
        AddButton(Args*) => this.Add("Button", Args*)
        AddEdit(Args*)   => this.Add("Edit", Args*)
        
        class Text {
            ApplyDarkTheme() {
                DllCall("uxtheme\SetWindowTheme", "Ptr", this.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
                this.SetFont("c" . Format("{:X}", 0xE0E0E0)) ; TODO
                this.Redraw()
            }
        }
        
        class Button {
            ApplyDarkTheme() {
                DllCall("uxtheme\SetWindowTheme", "Ptr", this.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
                this.SetFont("c" . Format("{:X}", 0x0E0E0E0)) ; TODO
                this.Redraw()
            }
        }
        
        class Edit {
            ApplyDarkTheme() {
                DllCall("uxtheme\SetWindowTheme", "Ptr", this.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
                this.SetFont("c" . Format("{:X}", 0xE0E0E0)) ; TODO
                this.Redraw()
            }
        }
    }
}
