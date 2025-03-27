#Requires AutoHotkey >=v2.0.5

#Include <IPv4>
#Include <DarkMode>

g := Gui()
; alternatively, [192, 168, 0, 1]
IPv4Control := g.AddIPv4("w150", "192.168.0.1")

g.Show("autosize")
MsgBox(IPv4Control.Address[1]) ; 192

IPv4Control.Address[4] := 15
MsgBox(IPv4Control.Address) ; "192.168.0.15"

