# PSMouseJiggler Test Plan (pre-merge / pre-release)

Use this checklist before merging to `main` and publishing a new version to the PowerShell Gallery.
Run through it any time `Start-PSMouseJiggler`, profiles, the GUI, or scheduled tasks change.

## 1. Automated tests

- [ ] `Invoke-Pester tests/PSMouseJiggler.Tests.ps1 -Output Detailed` — all tests pass
- [ ] `./Validate.ps1` — clean run, no missing functions or manifest errors
- [ ] `Test-ModuleManifest src/PSMouseJiggler/PSMouseJiggler.psd1` — succeeds, version matches intended release

## 2. Manual: core jiggling

- [ ] `Start-PSMouseJiggler` (defaults) moves the mouse, `Stop-PSMouseJiggler` stops it
- [ ] `-MovementPattern` Random / Horizontal / Vertical / Circular all move the cursor as expected
- [ ] `-Interval` and `-Duration` are respected (job stops itself after Duration)
- [ ] Calling `Start-PSMouseJiggler` while already running shows the "already running" warning (or clears host silently with `-Incognito`)

## 3. Manual: Methods / Strategy (former Start-KeepAwake behavior)

- [ ] `-Methods @('MouseHardware')`
- [ ] `-Methods @('MouseSoftware','MouseHardware')`
- [ ] `-Methods @('Keyboard')` — no visible mouse movement
- [ ] `-Methods @('SystemAPI')` — no visible mouse movement, system stays awake
- [ ] `-Methods @('All')` — all four methods cycle
- [ ] `-Strategy Adaptive` / `LowImpact` / `Compatibility`
- [ ] `-Strategy AppKeepAlive` — confirm SystemAPI + Keyboard keeps a target app (e.g. a chat/media app) marked active without moving the mouse

## 4. Manual: Incognito mode

- [ ] Console: `-Incognito` clears the console on start
- [ ] GUI: Incognito checkbox minimizes the window and hides it from the taskbar; restoring on Stop works

## 5. Manual: GUI (`Show-PSMouseJigglerGUI`)

- [ ] Basic tab: all 4 patterns, all 3 mouse input methods (Software/Hardware/Both), Start/Stop toggle status correctly
- [ ] Advanced tab: each checkbox combination starts correctly; rejects starting with zero methods selected
- [ ] Quick Launch: all 5 profile buttons start correctly and switch to Basic tab with correct status text
- [ ] Help dialog opens and displays current text
- [ ] Reopening the GUI after a console-started session reflects "Running (Started from Console)"

## 6. Manual: Profiles

- [ ] `Save-PSMJProfile` / `Get-PSMJProfile` / `Remove-PSMJProfile` round-trip
- [ ] Save and start a profile with only Interval/Duration/MovementPattern (no Methods/Strategy)
- [ ] Save and start a profile with `Methods`
- [ ] Save and start a profile with `Strategy = 'AppKeepAlive'`
- [ ] Confirm profiles saved by an older module version (with a `Mode` field) load without error (the field is ignored)

## 7. Manual: Scheduled tasks

- [ ] `New-PSMJScheduledTask` / `Start-PSMJScheduledTask` / `Stop-PSMJScheduledTask` / `Remove-PSMJScheduledTask`
- [ ] `New-PSMJScheduledProfileTask` against a saved profile, then manually trigger and confirm it starts jiggling

## 8. Manual: Diagnostics

- [ ] `Get-PSMJDiagnostics` reports `IsRunning`/`JobState` correctly while running and after stopping
- [ ] `ProfileCount` reflects saved profiles

## Sign-off

- [ ] All automated tests green
- [ ] All manual checks above completed on a Windows machine
- [ ] `PSMouseJiggler.psd1` `ModuleVersion` and `ReleaseNotes` updated
- [ ] Reviewer approval obtained before merging to `main` / publishing to PowerShell Gallery
