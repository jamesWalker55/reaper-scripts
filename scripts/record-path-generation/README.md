# Generate Project Recording Path

This package contains 2 scripts for automatically generating and setting the "recording path" of a project.

The user provides a base path, then the script generates a random subfolder in that base path as the "recording path".

For example, if I set the base path as `_Audio files`, the generated recording paths will look like this:

- `_Audio files/s72el275nglp`
- `_Audio files/inf3yxjcgdub`
- `_Audio files/bw7x4uwg7mkm`
- `_Audio files/jzvn8tdd1ke4`

## How to use

- `set-record-root-path.lua`
    - Used to set the base path used for generating new paths
    - Preferably a relative path, because Reaper is buggy with absolute paths (unless the devs decide to fix it)
    - e.g. `_Audio files`
- `set-record-path.lua`
    - Used to generate a new recording path and set it to the project's "recording path" setting
