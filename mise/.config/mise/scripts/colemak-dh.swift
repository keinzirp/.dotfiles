import Carbon
import Foundation

func fail(_ message: String) -> Never {
    fputs("Colemak-DH: \(message)\n", stderr)
    exit(1)
}

func check(_ status: OSStatus, _ action: String) {
    guard status == noErr else {
        fail("\(action) failed (OSStatus \(status)).")
    }
}

let filter = [kTISPropertyInputSourceID as String: "io.github.colemakmods.keyboardlayout.colemakdh.colemakdhansi"] as CFDictionary
func findLayout() -> TISInputSource? {
    (TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource])?.first
}

var source = findLayout()
if source == nil {
    check(TISRegisterInputSource(URL(fileURLWithPath: "/Library/Keyboard Layouts/Colemak DH.bundle") as CFURL), "Registering layout")
    source = findLayout()
}
guard let source else {
    fail("ANSI layout unavailable; log out/in and rerun mise bootstrap.")
}

check(TISEnableInputSource(source), "Enabling layout")
check(TISSelectInputSource(source), "Selecting layout")
guard let current = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(), CFEqual(current, source) else {
    fail("Colemak-DH was not selected.")
}
print("Colemak-DH ANSI enabled and selected.")
