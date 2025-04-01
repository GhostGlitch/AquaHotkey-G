#Requires AutoHotkey >=v2.0.5

#Include <IPv4>
#Include <DarkMode>

ChangedEvent(IPv4) {
    ToolTip("event: IP-Address is now " . IPv4.Address, 50, 50)
}

g := Gui()

; alternatively, [192, 168, 0, 1]
Ctl := g.AddIPv4("w150", "192.168.0.1") ; alternatively, [192, 168, 0, 1]
Ctl.OnEvent("Change", ChangedEvent)

g.Show("autosize")

