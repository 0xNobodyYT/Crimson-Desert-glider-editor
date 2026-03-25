# Crimson Desert Glider Editor Repo

This repo now contains two separate tool sets.

## Root Files

- `Stamina Glider Editor`
  - The original glide-only installer already in this repo.
  - This edits normal glide and fast glide stamina.
- `Stamina Glider Editor Uninstall`
  - The original glide-only restore tool already in this repo.
  - This restores the glide-only changes.

Those two root files were left untouched.

## Legacy Combined Glide + Roll Package

Folder:
- `Stamina Glider Roll Editor/`

Contents:
- `crimson_desert_glide_patcher.bat`
  - Combined installer/editor.
  - Edits normal glide, fast glide, and aerial roll.
- `crimson_desert_glide_uninstall.bat`
  - Combined restore tool.
  - Restores normal glide, fast glide, and aerial roll.
- `CrimsonDesertSkillPatcher.exe`
  - Native helper used by the BAT when editing aerial roll.
  - Aerial roll is stored inside compressed game data and cannot be changed safely with a simple BAT-only byte edit.
- `lz4.dll`
  - Compression library required by `CrimsonDesertSkillPatcher.exe`.
  - Used to decompress and recompress the archive entry safely.

Why the EXE and DLL are needed:
- Normal glide and fast glide can be changed with direct byte edits.
- Aerial roll is different. Its value lives inside compressed `skill.pabgb` data in `0008\\0.paz`.
- The EXE handles opening the archive entry, decompressing it, editing the roll value, recompressing it to the required size, and writing it back correctly.

See the README inside `Stamina Glider Roll Editor/` for usage.
