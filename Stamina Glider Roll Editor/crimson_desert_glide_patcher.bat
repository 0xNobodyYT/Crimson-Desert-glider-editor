@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "DEFAULT_GAME_DIR="
call :find_default_game_dir

set "MODE=%~1"
set "NORMAL=%~2"
set "FAST=%~3"
set "ROLL=%~4"
set "GAME_DIR=%~5"

if /I "%~1"=="/?" goto :usage
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="--help" goto :usage

if /I "%MODE%"=="patch" goto :cli_patch

if defined MODE (
  set "NORMAL=%~1"
  set "FAST=%~2"
  set "GAME_DIR=%~3"
  if defined NORMAL goto :legacy_patch
)

goto :interactive

:interactive
cls
echo Crimson Desert Glide Patcher
echo.
echo This tool patches glide stamina values with your custom numbers.
echo.
echo Default in-game Stamina Spent values:
echo   Normal glide Stamina Spent = 25
echo   Fast glide Stamina Spent   = 50
echo   Aerial roll Stamina Spent  = 80
echo.
echo Value guide:
echo   Lower numbers = less stamina spent = longer glide.
echo   Higher numbers = more stamina spent = shorter glide.
echo   Vanilla example: 25, 50, 80
echo   Balanced example: 10, 20, 40
echo   Long-glide example: 2, 5, 30
echo.
echo Aerial roll note:
echo   Aerial roll is the Alt input by default.
echo   Supported tested roll values in this BAT: 10, 30, 40, 80
echo.
echo Folder instructions:
echo   Enter your Crimson Desert game folder path.
echo   If this BAT is inside the game's folder, just press Enter.
if defined DEFAULT_GAME_DIR (
  echo   Auto-detected folder: %DEFAULT_GAME_DIR%
) else (
  echo   Auto-detect did not find the game folder, so type it manually.
)
echo.

:prompt_game_dir
set "GAME_DIR="
if defined DEFAULT_GAME_DIR (
  set /p "GAME_DIR=Game folder path [%DEFAULT_GAME_DIR%]: "
  if not defined GAME_DIR set "GAME_DIR=%DEFAULT_GAME_DIR%"
) else (
  set /p "GAME_DIR=Game folder path: "
)
call :normalize_game_dir
if not defined GAME_DIR (
  echo.
  echo Please enter a valid Crimson Desert folder path.
  echo.
  goto :prompt_game_dir
)
if not exist "%GAME_DIR%\0008\0.paz" (
  echo.
  echo Could not find "%GAME_DIR%\0008\0.paz"
  echo Make sure the path points to your Crimson Desert folder.
  echo.
  goto :prompt_game_dir
)

:prompt_action
echo.
echo Select an action:
echo   1. Patch glide values
echo   2. Exit
set "ACTION="
set /p "ACTION=Enter 1 or 2: "
if "%ACTION%"=="1" goto :interactive_patch
if "%ACTION%"=="2" goto :finish
echo.
echo Invalid selection.
goto :prompt_action

:interactive_patch
echo.
echo Enter your custom glide stamina values.
echo Default normal glide Stamina Spent is 25.
echo Default fast glide Stamina Spent is 50.
echo Default aerial roll Stamina Spent is 80.
echo Lower numbers spend less stamina and make glide last longer.
echo Higher numbers spend more stamina and make glide drain faster.
echo Exact 0 is not supported by this patcher.
echo Roll supports these tested values only: 10, 30, 40, 80.
echo.
set "NORMAL="
set "FAST="
set "ROLL="
set /p "NORMAL=Normal glide Stamina Spent [25]: "
set /p "FAST=Fast glide Stamina Spent [50]: "
set /p "ROLL=Aerial roll Stamina Spent [80] (10, 30, 40, 80): "
if not defined NORMAL set "NORMAL=25"
if not defined FAST set "FAST=50"
if not defined ROLL set "ROLL=80"
call :validate_roll_value
if errorlevel 1 goto :interactive_patch
set "MODE=patch"
goto :run

:cli_patch
call :resolve_roll_and_game_dir
if not defined NORMAL (
  echo Missing normal glide cost.
  goto :usage_error
)
if not defined FAST (
  echo Missing fast glide cost.
  goto :usage_error
)
if not defined ROLL set "ROLL=80"
call :validate_roll_value
if errorlevel 1 goto :finish
if not defined GAME_DIR (
  if defined DEFAULT_GAME_DIR (
    set "GAME_DIR=%DEFAULT_GAME_DIR%"
  ) else (
    echo.
    echo Could not auto-detect the game folder.
    echo Pass the Crimson Desert folder path explicitly.
    goto :usage_error
  )
)
call :normalize_game_dir
if not exist "%GAME_DIR%\0008\0.paz" (
  echo.
  echo Could not find "%GAME_DIR%\0008\0.paz"
  echo Make sure the path points to your Crimson Desert folder.
  goto :finish
)
goto :run

:legacy_patch
call :resolve_roll_and_game_dir
if not defined FAST (
  echo Missing fast glide cost.
  goto :usage_error
)
if not defined ROLL set "ROLL=80"
call :validate_roll_value
if errorlevel 1 goto :finish
if not defined GAME_DIR (
  if defined DEFAULT_GAME_DIR (
    set "GAME_DIR=%DEFAULT_GAME_DIR%"
  ) else (
    echo.
    echo Could not auto-detect the game folder.
    echo Pass the Crimson Desert folder path explicitly.
    goto :usage_error
  )
)
set "MODE=patch"
call :normalize_game_dir
if not exist "%GAME_DIR%\0008\0.paz" (
  echo.
  echo Could not find "%GAME_DIR%\0008\0.paz"
  echo Make sure the path points to your Crimson Desert folder.
  goto :finish
)
goto :run

:resolve_roll_and_game_dir
if not defined ROLL exit /b 0
if defined GAME_DIR exit /b 0
if exist "%ROLL%\0008\0.paz" (
  set "GAME_DIR=%ROLL%"
  set "ROLL=80"
  exit /b 0
)
echo %ROLL%| findstr /R "[\\/:]" >nul
if not errorlevel 1 (
  set "GAME_DIR=%ROLL%"
  set "ROLL=80"
)
exit /b 0

:validate_roll_value
if "%ROLL%"=="10" exit /b 0
if "%ROLL%"=="30" exit /b 0
if "%ROLL%"=="40" exit /b 0
if "%ROLL%"=="80" exit /b 0
echo.
echo Aerial roll Stamina Spent must be one of these tested values: 10, 30, 40, 80.
echo.
exit /b 1

:find_default_game_dir
if exist "%SCRIPT_DIR%\0008\0.paz" (
  set "DEFAULT_GAME_DIR=%SCRIPT_DIR%"
  exit /b 0
)

for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
  if not defined DEFAULT_GAME_DIR if exist "%%D:\Program Files\Steam\steamapps\common\Crimson Desert\0008\0.paz" set "DEFAULT_GAME_DIR=%%D:\Program Files\Steam\steamapps\common\Crimson Desert"
  if not defined DEFAULT_GAME_DIR if exist "%%D:\Steam\steamapps\common\Crimson Desert\0008\0.paz" set "DEFAULT_GAME_DIR=%%D:\Steam\steamapps\common\Crimson Desert"
  if not defined DEFAULT_GAME_DIR if exist "%%D:\SteamLibrary\steamapps\common\Crimson Desert\0008\0.paz" set "DEFAULT_GAME_DIR=%%D:\SteamLibrary\steamapps\common\Crimson Desert"
)
exit /b 0

:normalize_game_dir
set "GAME_DIR=%GAME_DIR:"=%"
if "%GAME_DIR:~-1%"=="\" set "GAME_DIR=%GAME_DIR:~0,-1%"
exit /b 0

:run
set "CD_GLIDE_MODE=%MODE%"
set "CD_GLIDE_GAME_DIR=%GAME_DIR%"
set "CD_GLIDE_NORMAL=%NORMAL%"
set "CD_GLIDE_FAST=%FAST%"
set "CD_GLIDE_ROLL=%ROLL%"
set "ARCHIVE_BACKUP=%CD_GLIDE_GAME_DIR%\0008\0.paz.glide_patcher_backup"

if /I not "%CD_GLIDE_ROLL%"=="80" (
  if not exist "%SCRIPT_DIR%\CrimsonDesertSkillPatcher.exe" (
    echo.
    echo Missing "%SCRIPT_DIR%\CrimsonDesertSkillPatcher.exe"
    echo The roll patch could not start, so no changes were applied.
    goto :finish
  )
  if not exist "%SCRIPT_DIR%\lz4.dll" (
    echo.
    echo Missing "%SCRIPT_DIR%\lz4.dll"
    echo The roll patch could not start, so no changes were applied.
    goto :finish
  )
  echo.
  echo Checking roll value fit...
  "%SCRIPT_DIR%\CrimsonDesertSkillPatcher.exe" roll patch --value "%CD_GLIDE_ROLL%" --game-dir "%CD_GLIDE_GAME_DIR%" --dry-run
  if errorlevel 1 (
    echo.
    echo No changes were applied.
    goto :finish
  )
)

if not exist "%ARCHIVE_BACKUP%" (
  copy /y "%CD_GLIDE_GAME_DIR%\0008\0.paz" "%ARCHIVE_BACKUP%" >nul
  echo Backup created: %ARCHIVE_BACKUP%
) else (
  echo Backup exists:  %ARCHIVE_BACKUP%
)

if /I not "%CD_GLIDE_ROLL%"=="80" (
  echo.
  "%SCRIPT_DIR%\CrimsonDesertSkillPatcher.exe" roll patch --value "%CD_GLIDE_ROLL%" --game-dir "%CD_GLIDE_GAME_DIR%"
  if errorlevel 1 (
    echo.
    echo Roll patch failed before glide patching.
    goto :finish
  )
) else (
  if exist "%SCRIPT_DIR%\CrimsonDesertSkillPatcher.exe" if exist "%SCRIPT_DIR%\lz4.dll" (
    echo.
    "%SCRIPT_DIR%\CrimsonDesertSkillPatcher.exe" roll uninstall --game-dir "%CD_GLIDE_GAME_DIR%"
    if errorlevel 1 (
      echo.
      echo Roll restore failed before glide patching.
      goto :finish
    )
  )
)

echo.
powershell -NoProfile -Command ^
  "$ErrorActionPreference = 'Stop'; try {" ^
  "$mode = $env:CD_GLIDE_MODE;" ^
  "$gameDir = $env:CD_GLIDE_GAME_DIR;" ^
  "$normalText = $env:CD_GLIDE_NORMAL;" ^
  "$fastText = $env:CD_GLIDE_FAST;" ^
  "$baseOffset = 0x00CCDF9E;" ^
  "$fastOffset = 0x00CCBD2B;" ^
  "$basePrefix = [byte[]](0x00,0x2b,0x2c,0x05,0x50,0xe4,0x12,0x22);" ^
  "$baseSuffix = [byte[]](0x25,0x0d,0x0f,0xe4,0x12,0x13);" ^
  "$fastPrefix = [byte[]](0x02,0x00,0x2c,0x1d,0xf5,0x0a,0x1d,0x21);" ^
  "$fastSuffix = [byte[]](0x6c,0x4d,0x0f,0x50,0xc8,0x14);" ^
  "$culture = [System.Globalization.CultureInfo]::InvariantCulture;" ^
  "function Parse-Cost([string]$text,[string]$label) { " ^
  "  try { $value = [decimal]::Parse($text, $culture) } catch { throw \"$label is not a valid number: '$text'\" };" ^
  "  if ($value -le 0) { throw \"$label must be greater than 0. Exact 0 is not supported by this patcher.\" };" ^
  "  $scaled = [int][decimal]::Round(($value * 1000), 0, [System.MidpointRounding]::AwayFromZero);" ^
  "  if ($scaled -le 0 -or $scaled -gt 65535) { throw \"$label must be between 0.001 and 65.535 inclusive. Got $value.\" };" ^
  "  return [pscustomobject]@{ Value = $value; Scaled = $scaled };" ^
  "};" ^
  "function Get-Low16Bytes([int]$scaled) { " ^
  "  $raw = (-$scaled) -band 0xFFFF;" ^
  "  return [byte[]]@([byte]($raw -band 0xFF), [byte](($raw -shr 8) -band 0xFF));" ^
  "};" ^
  "function Assert-Context([byte[]]$blob,[int]$offset,[byte[]]$prefix,[byte[]]$suffix,[string]$label) { " ^
  "  if ($offset -lt $prefix.Length -or ($offset + 2 + $suffix.Length) -gt $blob.Length) { throw \"$label patch offset is out of bounds for this archive.\" };" ^
  "  for ($i = 0; $i -lt $prefix.Length; $i++) { if ($blob[$offset - $prefix.Length + $i] -ne $prefix[$i]) { throw \"$label guard bytes do not match this game build.\" } };" ^
  "  for ($i = 0; $i -lt $suffix.Length; $i++) { if ($blob[$offset + 2 + $i] -ne $suffix[$i]) { throw \"$label guard bytes do not match this game build.\" } };" ^
  "};" ^
  "function Write-Bytes([string]$path,[int]$offset,[byte[]]$bytes) { " ^
  "  $stream = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::Read);" ^
  "  try { $stream.Seek($offset, [System.IO.SeekOrigin]::Begin) | Out-Null; $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() };" ^
  "};" ^
  "function Read-Bytes([string]$path,[int]$offset,[int]$count) { " ^
  "  $stream = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite);" ^
  "  try { $buffer = New-Object byte[] $count; $stream.Seek($offset, [System.IO.SeekOrigin]::Begin) | Out-Null; $read = $stream.Read($buffer, 0, $count); if ($read -ne $count) { throw 'Could not read verification bytes from the archive.' }; return $buffer } finally { $stream.Dispose() };" ^
  "};" ^
  "$pazPath = Join-Path $gameDir '0008\0.paz';" ^
  "if (-not (Test-Path -LiteralPath $pazPath)) { throw \"Archive not found: $pazPath\" };" ^
  "$blob = [System.IO.File]::ReadAllBytes($pazPath);" ^
  "Assert-Context $blob $baseOffset $basePrefix $baseSuffix 'Normal glide';" ^
  "Assert-Context $blob $fastOffset $fastPrefix $fastSuffix 'Fast glide';" ^
  "if ($mode -eq 'patch') { " ^
  "  $normal = Parse-Cost $normalText 'Normal glide Stamina Spent';" ^
  "  $fast = Parse-Cost $fastText 'Fast glide Stamina Spent';" ^
  "  $normalBytes = Get-Low16Bytes $normal.Scaled;" ^
  "  $fastBytes = Get-Low16Bytes $fast.Scaled;" ^
  "  Write-Bytes $pazPath $baseOffset $normalBytes;" ^
  "  Write-Bytes $pazPath $fastOffset $fastBytes;" ^
  "  Write-Host ('Patched:      ' + $pazPath);" ^
  "  Write-Host ('Normal glide Stamina Spent: ' + $normal.Value + ' -> ' + ([System.BitConverter]::ToString($normalBytes).Replace('-', ' ')));" ^
  "  Write-Host ('Fast glide Stamina Spent:   ' + $fast.Value + ' -> ' + ([System.BitConverter]::ToString($fastBytes).Replace('-', ' ')));" ^
  "  Write-Host 'Scope: shared glide/flight roots for Damian, CrowWing, and RocketPack.';" ^
  "} else { throw ('Unknown mode: ' + $mode + '. This patcher only supports patch mode.') };" ^
  "$currentBase = Read-Bytes $pazPath $baseOffset 2;" ^
  "$currentFast = Read-Bytes $pazPath $fastOffset 2;" ^
  "Write-Host ('Bytes now:     normal=' + ([System.BitConverter]::ToString($currentBase).Replace('-', ' ')) + ' fast=' + ([System.BitConverter]::ToString($currentFast).Replace('-', ' ')));" ^
  "} catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"

if errorlevel 1 (
  echo.
  echo Glide patch failed after the roll step.
  goto :finish
)

echo.
echo Patch complete.
goto :finish

:usage_error
echo.

:usage
echo Usage:
echo   %~nx0
echo   %~nx0 patch 2 5 30 "E:\Program Files\Steam\steamapps\common\Crimson Desert"
echo   %~nx0 patch 2 5 30 "D:\SteamLibrary\steamapps\common\Crimson Desert"
echo.
echo Legacy shortcut:
echo   %~nx0 2 5 30 "E:\Program Files\Steam\steamapps\common\Crimson Desert"

:finish
set "FINAL_EXIT_CODE=%ERRORLEVEL%"
echo.
echo The script is finished.
set "PRESS_ENTER="
set /p "PRESS_ENTER=Press Enter to close this window..."
exit /b %FINAL_EXIT_CODE%
