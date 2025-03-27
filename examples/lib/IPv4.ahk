#Requires AutoHotkey >=2.0.5
#Include %A_LineFile%/../../../AquaHotkey_Minimal.ahk

/**
 * AquaHotkey - IPv4.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - examples/lib/IPv4.ahk
 * 
 * **Overview**:
 * 
 * An AquaHotkey extension class that adds a custom GUI control class
 * for entering IPv4 addresses (`Gui.Custom.IPv4`).
 * 
 * This control provides a segmented input fields with automatic formatting,
 * validation and events.
 * 
 * - Easily integrates with `Gui.Prototype.AddIPv4()`.
 * 
 * @example
 * 
 * g := Gui()
 * Ctl := g.AddIPv4("w250", "192.168.0.1")
 * Ctl.OnEditChange(EditChangedCallback)
 * Ctl.OnFieldChange(FieldChangedCallback)
 * 
 * g.Show()
 * 
 * MsgBox(IPv4Control.Address)      ; "192.168.0.1"
 * MsgBox(IPv4Control.Address[4])   ; 1
 * IPv4.Control[1] := 76            ; new address: "76.168.0.1"
 * IPv4Control.Address := "8.8.4.4" ; new address: "8.8.4.4"
 * 
 * ; alternatively:
 * ; IPv4Control.Address := [8, 8, 4, 4]
 * 
 * @summary
 * 
 * ---
 * 
 * **Gui**:
 * - `AddAPv4(Opt := "", Addr?)`
 * 
 * ---
 * 
 * **Gui.Custom.IPv4**:
 * - `OnEditChange(Callback, AddRemove?)`
 * - `OnFieldChange(Callback, AddRemove?)`
 * - `Address[Octet?] { get; set; }`
 * - `Clear()`
 * - `IsBlank { get; }`
 * - `Focus(Index)`
 * - `SetIndex(Index, Lo := 0, Hi := 255)`
 * 
 * ---
 * 
 * @extends AquaHotkey
 */
class IPv4 extends AquaHotkey {
    class Gui {
        /**
         * Adds an IPv4 control to the GUI.
         * 
         * @param   {String?}         Opt   additional GUI options
         * @param   {String?/Array?}  Addr  initial IPv4 address
         */
        AddIPv4(Opt := "", Addr?) {
            Ctl := this.Add("Custom", "ClassSysIPAddress32 r1 " . Opt)
            ObjSetBase(Ctl, Gui.IPv4.Prototype)
            if (IsSet(Addr)) {
                Ctl.Address := Addr
            }
            return Ctl
        }

        class IPv4 extends Gui.Custom {
            /**
             * Registers a function to call when the edit of the IPv4 control
             * is changed.
             * 
             * @example
             * 
             * EditChanged(GuiCtrl) {
             *     ; ...
             * }
             * 
             * @param   {Func/String}  Callback   function to call on event
             * @param   {Integer?}     AddRemove  adds or removes the callback
             */
            OnEditChange(Callback, AddRemove?) {
                this.OnCommand(0x300, Callback, AddRemove?)
            }

            /**
             * Registers a function to call when a field of the IPv4 control
             * is changed.
             * 
             * @example
             * 
             * FieldChanged(GuiCtrl, NMIPADDRESS) {
             *     ; ...
             * }
             * 
             * @param   {Func/String}  Callback   function to call on event
             * @param   {Integer?}     AddRemove  adds or removes the callback
             */
            OnFieldChange(Callback, AddRemove?) {
                this.OnNotify(-860, Callback, AddRemove?)
            }

            /**
             * Gets or sets the IPv4 address of the control.
             * 
             * This property allows reading and modifying the IPv4 address as either:
             * - A full string (e.g., `"192.168.0.1"`)
             * - A segmented array of four octets (e.g., `[192, 168, 0, 1]`)
             * - A specific octet via indexed access (`Ctl.Address[1]` -> `192`)
             * 
             * When setting the address:
             * - Strings must be valid IPv4 addresses.
             * - Arrays must contain exactly four integers (0-255).
             * - Individual octets must be in the valid range.
             * @example
             * 
             * MsgBox(Ctl.Address)         ; "192.168.0.1"
             * MsgBox(Ctl.Address[1])      ; 192
             * 
             * Ctl.Address[1] := 78        ; updates first octet
             * Ctl.Address := "8.8.8.8"    ; assigns a new address
             * Ctl.Address := [8, 8, 8, 8] ; alternative array syntax 
             */
            Address[Octet?] {
                get {
                    static IPM_GETADDRESS := 0x0400 + 102

                    AddrWord := Buffer(4)
                    SendMessage(IPM_GETADDRESS, 0, AddrWord, this)
                    if (!IsSet(Octet)) {
                        return Format("{}.{}.{}.{}",
                                NumGet(AddrWord, 3, "Uchar"),
                                NumGet(AddrWord, 2, "Uchar"),
                                NumGet(AddrWord, 1, "Uchar"),
                                NumGet(AddrWord, 0, "Uchar"))
                    }
                    if (!IsInteger(Octet) || (Octet < 1) || (Octet > 4)) {
                        throw ValueError("invalid octet value")
                    }
                    return NumGet(AddrWord, 4 - Octet, "UChar")
                }

                set {
                    static IPM_SETADDRESS := 0x0400 + 101
                    static IPM_GETADDRESS := 0x0400 + 102

                    if (!IsSet(Octet)) {
                        switch {
                            case (value is Array):
                                Bytes := value
                            case (value is String):
                                Bytes := StrSplit(value, ".")
                            default:
                                throw TypeError("invalid IP address")
                        }
                        if (Bytes.Length != 4) {
                            throw ValueError("invalid IPv4 address",, value)
                        }

                        IPAddr := 0
                        for b in Bytes {
                            if (!IsInteger(b) || (b < 0) || (b > 255)) {
                                throw ValueError("invalid octet",, b)
                            }
                            IPAddr <<= 8
                            IPAddr += b
                        }
                        SendMessage(IPM_SETADDRESS, 0, IPAddr, this)
                        return value
                    }

                    if (!IsInteger(Octet) || (Octet < 1) || (Octet > 4)) {
                        throw TypeError("invalid index",, Type(value))
                    }
                    if (!IsInteger(value) || (value < 0) || (value > 255)) {
                        throw ValueError("invalid octet value",, value)
                    }

                    AddrWord := Buffer(4)
                    SendMessage(IPM_GETADDRESS, 0, AddrWord, this)

                    NumPut("UChar", value, AddrWord, 4 - Octet)
                    IPAddr := NumGet(AddrWord, 0, "UInt")
                    SendMessage(IPM_SETADDRESS, 0, IPAddr, this)
                    return value
                }
            }

            /**
             * Clears the contents of the IP address control.
             */
            Clear() => SendMessage(IPM_CLEARADDRESS := 0x0400 + 100, 0, 0, this)

            /**
             * Determines if all fields in the IP address control are blank.
             * 
             * @return  {Boolean}
             */
            IsBlank => !!SendMessage(IPM_ISBLANK := 0x0400 + 105, 0, 0, this)

            /**
             * Sets the keyboard focus to the specified field in the IP address
             * control. All of the text in that field will be selected.
             * 
             * @param   {Integer}  Index  index of the field to set
             */
            Focus(Index) {
                static IPM_SETFOCUS := 0x0400 + 104
                if (!IsInteger(Index) || (Index < 1) || (Index > 4)) {
                    throw ValueError("invalid index")
                }
                SendMessage(IPM_SETFOCUS, Index - 1, 0, this)
            }

            /**
             * Sets the valid range for the specified field in the IP address
             * control.
             * 
             * @param  {Integer}  Index  index of the field to set
             * @param  {Integer}  Lo     lower limit of the range
             * @param  {Integer}  Hi     upper limit of the range
             */
            SetRange(Index, Lo := 0, Hi := 255) {
                static IPM_SETRANGE := 0x0400 + 103
                if ((Lo < 0) || (Lo > 255) || (Hi < 0) || (Hi > 255)) {
                    throw ValueError("invalid range",, Lo . " - " . Hi)
                }
                lParam := Lo | (Hi << 8)
                SendMessage(IPM_SETRANGE, Index - 1, lParam, this)
            }

        }
    }
}
