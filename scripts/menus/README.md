# Various Dropdown Menus

This package contains a bunch of dropdown menus. These menus attempt to organize Reaper actions to more accessible groups:

- Arrangement menus:
    - Item/Track freezing
    - Peak display settings
    - List of all installed arrangement scripts with blacklist (Requires JS extension)
    - Take envelopes
    - Track envelopes
    - Opened windows
    - Zooming
- MIDI editor:
    - Note channels
    - Note colors
    - Exploding notes to new items/tracks (KAWA extension)
    - MIDI grid/timebase settings
    - Quantizing
    - List of all installed MIDI scripts with blacklist (Requires JS extension)
    - MIDI transforming
    - Visibility of some elements

The postfix of the scripts (if any) indicate the extensions required for the menus to work.

```
# this menu can be run without any extensions
midi-grid-type-menu.lua

# this menu requires the SWS extension
midi-grid-type-menu-sws.lua

# this menu requires both the SWS extension and the KAWA extension
arr-freeze-menu-sws-kawa.lua
```

## Creating your own menus

Menus are very easy to create, just require `lib.menu` (available in my Required Functions package)


