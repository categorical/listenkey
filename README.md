
### `Alt` `F......n` `Ctrl`

`Logitech K345` keyboard has a fat `Fn` key that I want to gouge out!
It is in between the right `Alt` and `Ctrl` keys.
It is triple sized and worthless.

The assumed plan was to remap that `Fn` key to a missing right `Meta` key.
That however, might not be possible as the `Fn` key is private to the keyboard (this external keyboard), i.e. it causes the keyboard to send altered scancodes when other keys are pressed, but does not send a scancode for itself.

This program, as a result, creates global keyboard hooks, but remains passive. 
It can be used to detect keyboard events, though:
  
  * `CGEvent`'s at the `Quartz` window system layer,
  * `IOHIDManager` events at the kernel devices layer.

### Installation

```
make build
```
An executable `listenkey` will be placed into a `bin` folder inside the program directory.

### Usage

* `listenkey --scancode` listens for scancodes the keyboard sends to the OS.
* `listenkey --keycode` listens for virtual key codes for keystrokes the window system dispatches.

### Answering to the remapping problem

Mapping the `Fn` key of an external keyboard might not be possible by software.
To map other keys, `macOS` has `hidutil` command;
to do it programmatically, use the `IOKit/hidsystem` APIs (see [this](https://developer.apple.com/library/content/technotes/tn2450/_index.html)).
A hidden file `"$HOME"/Library/Preferences/ByHost/.GlobalPreferences.*.plist`
might be responsible for persisting the mapping upon restarts.
`plutil -convert xml1 -o foo.xml foo.plist` can be used to unpack this file.
The mapping is stored under the key: `com.apple.keyboard.modifiermapping.{idVendor}-{idProduct}-0`.
`idVendor` and `idProduct` are reported by `ioreg -p IOUSB -c IOUSBDevice`.
The value stored is an array of items, each item looks like:

```
<dict>
    <key>HIDKeyboardModifierMappingDst</key>
    <integer>30064771298</integer>
    <key>HIDKeyboardModifierMappingSrc</key>
    <integer>30064771299</integer>
</dict>
```
The structure is self explanatory, and the numbers are offsetted scancodes of keystrokes.

```
30064771298=0x7000000e2=0x700000000|0xe2=0x700000000+226
30064771299=0x7000000e3=0x700000000|0xe3=0x700000000+227
```
`226` is left `Alt`, and `227` is left `GUI` ([source](http://www.freebsddiary.org/APC/usb_hid_usages.php)) which by default is mapped as `Cmd`;
this can be confirmed by this program as well (scancodes are not altered before being listened).

Another way of persisting this remapping configuration is using `defaults`.

```
defaults -currentHost read -g com.apple.keyboard.modifiermapping.{idVendor}-{idProduct}-0

defaults -currentHost delete -g com.apple.keyboard.modifiermapping.{idVendor}-{idProduct}-0

defaults -currentHost write -g \
com.apple.keyboard.modifiermapping.{idVendor}-{idProduct}-0 \
-array "<dict>\
<key>HIDKeyboardModifierMappingDst</key>\
<integer>30064771076</integer>\
<key>HIDKeyboardModifierMappingSrc</key>\
<integer>30064771298</integer>\
</dict>"
```
The `write` would map the left `Alt` to `a`, effective upon next login.
Pressing `Alt` yields scancode `226` and key code `0`,
also the `CGEvent`'s type changes from `NSEventTypeFlagsChanged` to `NSEventTypeKeyDown`;
which means the `Alt` key is no longer a modifier key.











