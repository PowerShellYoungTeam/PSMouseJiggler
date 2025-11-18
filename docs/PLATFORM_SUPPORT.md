# Platform Support Matrix

Complete guide to PSMouseJiggler v2.0.0 cross-platform capabilities, requirements, and platform-specific features.

## Quick Reference

| Feature | Windows | Linux | macOS |
|---------|:-------:|:-----:|:-----:|
| PowerShell 5.1 | ✅ | ❌ | ❌ |
| PowerShell 7+ | ✅ | ✅ | ✅ |
| Mouse Jiggling | ✅ | ✅ | ✅ |
| Keep-Awake (System API) | ✅ | ✅ | ✅ |
| Windows Forms GUI | ✅ | ❌ | ❌ |
| Terminal UI (TUI) | ✅ | ✅ | ✅ |
| Incognito Mode | ✅ | ✅ | ✅ |
| Scheduled Tasks | ✅ | ✅* | ✅* |

*Linux: systemd timers, macOS: launchd

---

## Platform Details

### Windows

**Supported Versions:**
- Windows 10 (1809+)
- Windows 11
- Windows Server 2019+

**PowerShell Editions:**
- Windows PowerShell 5.1 (built-in)
- PowerShell 7+ (recommended)

**Dependencies:**
- .NET Framework 4.7.2+ (for Windows Forms GUI)
- No external tools required

**Available Methods:**

| Method | Technology | Description |
|--------|-----------|-------------|
| **MouseSoftware** | Cursor.Position API | Software-based cursor movement |
| **MouseHardware** | SendInput API | Hardware-level mouse simulation |
| **Keyboard** | SendInput API | F15 key press simulation (invisible) |
| **SystemAPI** | SetThreadExecutionState | Direct power management API |

**User Interfaces:**
- ✅ Windows Forms GUI (`Show-PSMouseJigglerGUI`)
- ✅ Terminal UI (`Show-PSMouseJigglerTUI`)
- ✅ Command-Line

**Scheduled Tasks:**
- Windows Task Scheduler integration
- Functions: `Get/New/Remove/Start/Stop-PSMJScheduledTask`

---

### Linux

**Supported Distributions:**
- Ubuntu 20.04+
- Debian 11+
- Fedora 36+
- RHEL/CentOS 8+
- Arch Linux
- openSUSE Leap 15.4+

**PowerShell Edition:**
- PowerShell 7+ only

**Required Dependencies:**

| Tool | Purpose | Installation |
|------|---------|--------------|
| **xdotool** | Mouse simulation (X11) | `sudo apt install xdotool` |
| **ydotool** | Mouse simulation (Wayland) | `sudo apt install ydotool` |
| **systemd-inhibit** | Sleep prevention | Built-in with systemd |

**Installation Command:**
```bash
# Automated installer
./Install-PSMouseJigglerDependencies.ps1

# Manual (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install xdotool

# Manual (Fedora/RHEL)
sudo dnf install xdotool

# Manual (Arch)
sudo pacman -S xdotool
```

**Available Methods:**

| Method | Technology | Requirement |
|--------|-----------|-------------|
| **MouseSoftware** | xdotool/ydotool | xdotool or ydotool |
| **SystemAPI** | systemd-inhibit | systemd (most distributions) |

**User Interfaces:**
- ❌ Windows Forms GUI (not available)
- ✅ Terminal UI (`Show-PSMouseJigglerTUI`)
- ✅ Command-Line

**Display Server Support:**

| Display Server | Tool | Status | Notes |
|----------------|------|:------:|-------|
| **X11** | xdotool | ✅ Full support | Default for most distros |
| **Wayland** | ydotool | ✅ Full support | May require elevated permissions |

**Detect Display Server:**
```bash
echo $XDG_SESSION_TYPE  # Output: x11 or wayland
```

**Scheduled Tasks:**
- systemd timers (preferred)
- cron fallback
- Functions: `Get/New/Remove/Start/Stop-PSMJScheduledTask`

---

### macOS

**Supported Versions:**
- macOS 11 (Big Sur)
- macOS 12 (Monterey)
- macOS 13 (Ventura)
- macOS 14 (Sonoma)

**PowerShell Edition:**
- PowerShell 7+ only

**Required Dependencies:**

| Tool | Purpose | Built-in | Installation |
|------|---------|:--------:|--------------|
| **cliclick** | Mouse simulation | ❌ | `brew install cliclick` |
| **caffeinate** | Sleep prevention | ✅ | Built-in |

**Installation Command:**
```bash
# Automated installer
./Install-PSMouseJigglerDependencies.ps1

# Manual (Homebrew required)
brew install cliclick
```

**Available Methods:**

| Method | Technology | Requirement |
|--------|-----------|-------------|
| **MouseSoftware** | cliclick | cliclick (Homebrew) |
| **SystemAPI** | caffeinate | Built-in |

**User Interfaces:**
- ❌ Windows Forms GUI (not available)
- ✅ Terminal UI (`Show-PSMouseJigglerTUI`)
- ✅ Command-Line

**Permissions:**

macOS requires **Accessibility permissions** for mouse simulation:

1. System Preferences → Security & Privacy → Privacy → Accessibility
2. Add Terminal or PowerShell to allowed apps
3. Check the box to enable
4. Restart PowerShell session

**Verify Permissions:**
```powershell
# Test mouse movement
Start-PSMouseJiggler -Duration 3

# Should work without "Accessibility" errors
```

**Scheduled Tasks:**
- launchd integration
- Functions: `Get/New/Remove/Start/Stop-PSMJScheduledTask`

---

## Feature Comparison

### Mouse Movement Patterns

All patterns available on all platforms:

| Pattern | Description | Use Case |
|---------|-------------|----------|
| **Random** | Random direction and distance | Most natural, default |
| **Horizontal** | Left-right movement | Minimal disturbance |
| **Vertical** | Up-down movement | Vertical scrolling simulation |
| **Circular** | Clockwise circular motion | Smooth continuous movement |

### Keep-Awake Methods by Platform

| Method | Windows | Linux | macOS | Technology |
|--------|:-------:|:-----:|:-----:|------------|
| MouseSoftware | ✅ | ✅ | ✅ | Cursor API / xdotool / cliclick |
| MouseHardware | ✅ | ❌ | ❌ | SendInput API (Windows only) |
| Keyboard | ✅ | ❌ | ❌ | SendInput API (Windows only) |
| SystemAPI | ✅ | ✅ | ✅ | Platform-specific idle prevention |

**SystemAPI Implementation:**
- **Windows**: `SetThreadExecutionState` (direct power management)
- **Linux**: `systemd-inhibit` (idle/sleep inhibit locks)
- **macOS**: `caffeinate` (display on, idle timer disabled)

---

## Terminal UI (TUI) Features

The Terminal UI adapts to each platform's capabilities:

### Windows TUI
- 4 Keep-Awake method checkboxes:
  - ☑️ Software Mouse Movements
  - ☑️ Hardware Mouse Input
  - ☑️ Keyboard Input (F15)
  - ☑️ System API (SetThreadExecutionState)
- All 4 movement patterns
- Incognito mode checkbox
- Full configuration options

### Linux TUI
- 2 Keep-Awake method checkboxes:
  - ☑️ Software Mouse Movements
  - ☑️ System API (systemd-inhibit)
- All 4 movement patterns
- Incognito mode checkbox
- Full configuration options

### macOS TUI
- 2 Keep-Awake method checkboxes:
  - ☑️ Software Mouse Movements
  - ☑️ System API (caffeinate)
- All 4 movement patterns
- Incognito mode checkbox
- Full configuration options

**Launch TUI:**
```powershell
# Install Terminal.Gui module (all platforms)
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser

# Launch TUI
Show-PSMouseJigglerTUI
```

---

## Version Compatibility

### Tool Version Requirements

**Linux:**
- xdotool ≥ 3.20180117 (recommended)
- ydotool ≥ 1.0.0 (recommended)
- Older versions may work but with warnings

**macOS:**
- cliclick ≥ 5.0 (recommended)
- Older versions may work but with warnings

**Check Versions:**
```bash
# Linux
xdotool --version  # or: ydotool --version

# macOS
cliclick -V
```

### PowerShell Version Check

```powershell
# Display PowerShell version
$PSVersionTable

# Minimum versions:
# Windows: 5.1 or 7+
# Linux/macOS: 7+ only
```

---

## Migration from v1.x

### Breaking Changes in v2.0.0

1. **Linux/macOS Support Added**
   - New external tool dependencies required
   - Platform-specific functionality

2. **Windows Forms GUI Exclusive to Windows**
   - Use Terminal UI on Linux/macOS instead
   - `Show-PSMouseJigglerGUI` only works on Windows

3. **PowerShell 7+ Required for Linux/macOS**
   - Windows PowerShell 5.1 still supported on Windows only

### Upgrade Path

**Windows Users:**
- No changes required
- All v1.x features preserved
- New TUI available as alternative to GUI

**New Linux/macOS Users:**
1. Install PowerShell 7+
2. Install platform dependencies (use installer script)
3. Install module from PowerShell Gallery
4. Use TUI or command-line interface

**Staying on v1.1.0 (Windows only):**
```powershell
Install-Module PSMouseJiggler -RequiredVersion 1.1.0 -Force
```

---

## Troubleshooting

### Windows

| Issue | Solution |
|-------|----------|
| GUI doesn't launch | Install .NET Framework 4.7.2+ |
| "Unapproved verb" warning | Safe to ignore (Prevent-SystemIdle verb) |
| Scheduled task fails | Run PowerShell as Administrator |
| Mouse not moving | Check if antivirus blocks input simulation |

### Linux

| Issue | Solution |
|-------|----------|
| "xdotool not found" | Install: `sudo apt install xdotool` |
| Mouse doesn't move (Wayland) | Install ydotool, may need sudo/elevated permissions |
| systemd-inhibit not found | Ensure systemd is installed and active |
| Permission denied (ydotool) | Run with sudo or add user to input group |

### macOS

| Issue | Solution |
|-------|----------|
| "cliclick not found" | Install: `brew install cliclick` |
| Mouse doesn't move | Grant Accessibility permissions in System Preferences |
| caffeinate not working | Built-in on macOS 11+, check macOS version |
| Homebrew not installed | Install from https://brew.sh |

### All Platforms

| Issue | Solution |
|-------|----------|
| TUI doesn't launch | Install: `Install-Module Microsoft.PowerShell.ConsoleGuiTools` |
| Module import fails | Check PowerShell version (5.1+ Windows, 7+ Linux/macOS) |
| Function not found | Verify module loaded: `Get-Module PSMouseJiggler` |
| Configuration not saving | Check file permissions in module config directory |

---

## Testing Your Installation

### Verify Platform Detection
```powershell
Import-Module PSMouseJiggler

# Check detected platform
Get-OperatingSystemPlatform  # Should return: Windows, Linux, or macOS

# Check available capabilities
Test-PlatformCapability -Capability GUI
Test-PlatformCapability -Capability WindowsAPI
Test-PlatformCapability -Capability XDoTool
Test-PlatformCapability -Capability CliClick
Test-PlatformCapability -Capability SystemdInhibit
Test-PlatformCapability -Capability Caffeinate
```

### Quick Test
```powershell
# Start mouse jiggling for 5 seconds
Start-PSMouseJiggler -Duration 5

# Observe mouse cursor movement

# Manually stop if needed
Stop-PSMouseJiggler
```

---

## Getting Help

### Documentation
- [Main README](../README.md) - Getting started guide
- [Usage Guide](USAGE.md) - Detailed usage examples
- [Manual Testing](MANUAL_TESTING.md) - Platform-specific testing procedures
- [Contributing](CONTRIBUTING.md) - Development guide

### Command Help
```powershell
# Get help for any function
Get-Help Start-PSMouseJiggler -Detailed
Get-Help Show-PSMouseJigglerTUI -Examples
Get-Help Start-KeepAwake -Full
```

### Support
- **Issues**: [GitHub Issues](https://github.com/PowerShellYoungTeam/PSMouseJiggler/issues)
- **Discussions**: [GitHub Discussions](https://github.com/PowerShellYoungTeam/PSMouseJiggler/discussions)
- **Pull Requests**: Contributions welcome!

---

**Document Version:** 2.0.0
**Last Updated:** November 2025
**Platforms Covered:** Windows 10/11, Ubuntu 22.04, macOS 13+
