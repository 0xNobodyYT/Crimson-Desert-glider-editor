# Stamina Glider Roll Editor

This is the previous combined version that edits:

- Normal glide `Stamina Spent`
- Fast glide `Stamina Spent`
- Aerial roll `Stamina Spent`

## Files

- `crimson_desert_glide_patcher.bat`
  - Main installer/editor.
  - Auto-detects the game folder and lets you enter custom glide values.
- `crimson_desert_glide_uninstall.bat`
  - Restore tool.
  - Restores glide and roll back to their backup/default values.
- `CrimsonDesertSkillPatcher.exe`
  - Required for aerial roll edits.
  - The BAT calls this for the roll step.
- `lz4.dll`
  - Required by the EXE.
  - Provides LZ4 compression/decompression support.

## Important Note

The BAT is the launcher and menu.

The EXE and `lz4.dll` are included because aerial roll is stored inside compressed game data and cannot be edited safely with a simple BAT-only patch. Normal glide and fast glide still use the direct BAT patch path.

## How To Use

1. Keep all 4 files together in the same folder.
2. Put them in your Crimson Desert game folder, or run the BAT and enter the folder manually.
3. Run `crimson_desert_glide_patcher.bat`.
4. Enter:
   - Normal glide `Stamina Spent`
   - Fast glide `Stamina Spent`
   - Aerial roll `Stamina Spent`

Default values:
- Normal glide = `25`
- Fast glide = `50`
- Aerial roll = `80`

Lower numbers mean less stamina spent.
Higher numbers mean more stamina spent.

Tested aerial roll values:
- `10`
- `30`
- `40`
- `80`

## Uninstall

Run `crimson_desert_glide_uninstall.bat` and confirm the restore.
