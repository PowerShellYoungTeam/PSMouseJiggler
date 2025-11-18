# Manual Testing Guide for PSMouseJiggler v2.0.0

This guide provides comprehensive manual testing procedures for PSMouseJiggler across Windows, Linux, and macOS platforms. Automated tests cover unit and integration testing, but some features (especially GUI/TUI interactions and visual feedback) require manual verification.

## Table of Contents

- [Pre-Testing Setup](#pre-testing-setup)
- [Windows Testing](#windows-testing)
- [Linux Testing](#linux-testing)
- [macOS Testing](#macos-testing)
- [Cross-Platform Testing](#cross-platform-testing)
- [Troubleshooting](#troubleshooting)

---

## Pre-Testing Setup

### All Platforms

1. **Install PowerShell**
   - Windows: PowerShell 5.1+ (built-in) or PowerShell 7+
   - Linux/macOS: PowerShell 7+ ([Installation guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell))

2. **Clone Repository**
   ```powershell
   git clone https://github.com/PowerShellYoungTeam/PSMouseJiggler.git
   cd PSMouseJiggler
   ```

3. **Import Module**
   ```powershell
   Import-Module ./src/PSMouseJiggler/PSMouseJiggler.psd1 -Force
   ```

---

## Windows Testing

### Prerequisites

- Windows 10/11 or Windows Server 2019+
- PowerShell 5.1+ or PowerShell 7+
- .NET Framework 4.7.2+ (for GUI)

### Test Suite

#### 1. Platform Detection
```powershell
# Verify platform detection
Get-OperatingSystemPlatform  # Should return: Windows

# Check available capabilities
Test-PlatformCapability -Capability GUI            # Should be: True
Test-PlatformCapability -Capability WindowsAPI     # Should be: True
Test-PlatformCapability -Capability ScheduledTasks # Should be: True
```

#### 2. Windows Forms GUI
```powershell
# Launch GUI
Show-PSMouseJigglerGUI
```

**Manual Checks:**
- [ ] GUI window opens without errors
- [ ] Three tabs visible: Basic Mode, Advanced Mode, Quick Launch
- [ ] **Basic Mode Tab:**
  - [ ] Interval field accepts numeric input
  - [ ] Movement pattern dropdown shows all 4 options
  - [ ] Duration field accepts numeric input
  - [ ] Incognito checkbox toggles
  - [ ] Start button initiates mouse movement (observe cursor)
  - [ ] Stop button terminates movement
- [ ] **Advanced Mode Tab:**
  - [ ] Four method checkboxes: Software Mouse, Hardware Mouse, Keyboard, System API
  - [ ] Start Keep-Awake button works with selected methods
  - [ ] Incognito mode minimizes window when checked
- [ ] **Quick Launch Tab:**
  - [ ] Five profile buttons launch correctly
  - [ ] Each profile uses appropriate methods

#### 3. Terminal UI (TUI)
```powershell
# Install Microsoft.PowerShell.ConsoleGuiTools if not already installed
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser

# Launch TUI
Show-PSMouseJigglerTUI
```

**Manual Checks:**
- [ ] TUI interface displays in terminal
- [ ] Status, Platform, Configuration, Keep-Awake Methods, Controls frames visible
- [ ] TAB key navigates between controls
- [ ] SPACE key toggles checkboxes
- [ ] Start button begins mouse jiggling (observe cursor)
- [ ] Keep Awake button with selected methods works
- [ ] Incognito checkbox option visible and functional
- [ ] ESC or Quit button exits cleanly

#### 4. Command-Line Operations
```powershell
# Test basic mouse jiggling
Start-PSMouseJiggler -Interval 1000 -MovementPattern Random -Duration 5
# Observe: Mouse should move randomly for 5 seconds

# Test incognito mode
Start-PSMouseJiggler -Interval 1000 -Incognito -Duration 5
# Observe: Console window minimizes

# Test keep-awake (System API)
Start-KeepAwake -Methods @('SystemAPI') -Duration 10
# Observe: System should not sleep during this time

# Test keep-awake (All methods)
Start-KeepAwake -Methods @('All') -Duration 10
# Observe: Combination of mouse, keyboard, and system API

# Stop operations
Stop-PSMouseJiggler
```

#### 5. Scheduled Tasks (Windows-Specific)
```powershell
# Create scheduled task
New-PSMJScheduledTask -TaskName "TestJiggle" -Interval 1000 -MovementPattern Random

# List tasks
Get-PSMJScheduledTasks

# Start task
Start-PSMJScheduledTask -TaskName "TestJiggle"

# Stop task
Stop-PSMJScheduledTask -TaskName "TestJiggle"

# Remove task
Remove-PSMJScheduledTask -TaskName "TestJiggle"
```

**Manual Checks:**
- [ ] Task appears in Windows Task Scheduler
- [ ] Task runs on schedule
- [ ] Task can be started/stopped manually
- [ ] Task removal cleans up Task Scheduler

---

## Linux Testing

### Prerequisites

- Ubuntu 20.04+, Fedora 36+, or similar distribution
- PowerShell 7+
- xdotool or ydotool (for mouse simulation)
- systemd-inhibit (for sleep prevention)

### Installation
```bash
# Install dependencies
./Install-PSMouseJigglerDependencies.ps1

# Or manually:
# Ubuntu/Debian
sudo apt-get install xdotool

# Fedora/RHEL
sudo dnf install xdotool

# Arch
sudo pacman -S xdotool
```

### Test Suite

#### 1. Platform Detection
```powershell
# Verify platform detection
Get-OperatingSystemPlatform  # Should return: Linux

# Check available capabilities
Test-PlatformCapability -Capability XDoTool        # Should be: True (if installed)
Test-PlatformCapability -Capability SystemdInhibit # Should be: True (if systemd present)
Test-PlatformCapability -Capability GUI            # Should be: False
Test-PlatformCapability -Capability WindowsAPI     # Should be: False
```

#### 2. Terminal UI (TUI)
```powershell
# Install Microsoft.PowerShell.ConsoleGuiTools
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser

# Launch TUI
Show-PSMouseJigglerTUI
```

**Manual Checks:**
- [ ] TUI launches without GUI-related errors
- [ ] Only Linux-compatible methods shown: Software Mouse, System API
- [ ] Windows-specific methods (Hardware Mouse, Keyboard) not shown
- [ ] Mouse movement works (observe cursor in X11 or Wayland)
- [ ] Keep Awake with SystemAPI prevents sleep

#### 3. Command-Line Operations
```powershell
# Test mouse jiggling with xdotool/ydotool
Start-PSMouseJiggler -Interval 1000 -MovementPattern Random -Duration 5
# Observe: Mouse cursor should move

# Test different patterns
Start-PSMouseJiggler -MovementPattern Horizontal -Duration 5
Start-PSMouseJiggler -MovementPattern Vertical -Duration 5
Start-PSMouseJiggler -MovementPattern Circular -Duration 5

# Test keep-awake with systemd-inhibit
Start-KeepAwake -Methods @('SystemAPI') -Duration 10
# Verify: Check inhibit lock with `systemd-inhibit --list`

# Test combined methods
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 10

Stop-PSMouseJiggler
```

#### 4. Display Server Compatibility
```bash
# Identify display server
echo $XDG_SESSION_TYPE  # Should be: x11 or wayland
```

**X11 Testing (xdotool):**
- [ ] Mouse movements visible
- [ ] All movement patterns work
- [ ] No permission errors

**Wayland Testing (ydotool):**
- [ ] ydotool installed and accessible
- [ ] May require running with elevated permissions
- [ ] Mouse movements work across all workspaces

---

## macOS Testing

### Prerequisites

- macOS 11 (Big Sur) or later
- PowerShell 7+
- cliclick (for mouse simulation)
- caffeinate (built-in, for sleep prevention)

### Installation
```bash
# Install dependencies
./Install-PSMouseJigglerDependencies.ps1

# Or manually install cliclick:
brew install cliclick
```

### Test Suite

#### 1. Platform Detection
```powershell
# Verify platform detection
Get-OperatingSystemPlatform  # Should return: macOS

# Check available capabilities
Test-PlatformCapability -Capability CliClick       # Should be: True (if installed)
Test-PlatformCapability -Capability Caffeinate     # Should be: True (built-in)
Test-PlatformCapability -Capability GUI            # Should be: False
Test-PlatformCapability -Capability WindowsAPI     # Should be: False
Test-PlatformCapability -Capability LaunchD        # Should be: True
```

#### 2. Terminal UI (TUI)
```powershell
# Install Microsoft.PowerShell.ConsoleGuiTools
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser

# Launch TUI
Show-PSMouseJigglerTUI
```

**Manual Checks:**
- [ ] TUI launches without GUI-related errors
- [ ] Only macOS-compatible methods shown: Software Mouse, System API
- [ ] Mouse movement works with cliclick
- [ ] Keep Awake with caffeinate prevents sleep

#### 3. Command-Line Operations
```powershell
# Test mouse jiggling with cliclick
Start-PSMouseJiggler -Interval 1000 -MovementPattern Random -Duration 5
# Observe: Mouse cursor should move

# Test different patterns
Start-PSMouseJiggler -MovementPattern Circular -Duration 5

# Test keep-awake with caffeinate
Start-KeepAwake -Methods @('SystemAPI') -Duration 10
# Verify: System should not sleep, display should stay on

# Test combined methods
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 10

Stop-PSMouseJiggler
```

#### 4. Permissions
macOS may require accessibility permissions for mouse simulation.

**Grant Permissions:**
1. System Preferences → Security & Privacy → Privacy → Accessibility
2. Add Terminal or PowerShell to allowed apps
3. Restart PowerShell session

**Verify:**
```powershell
# Test mouse movement after granting permissions
Start-PSMouseJiggler -Duration 3
# Should work without "Accessibility" errors
```

---

## Cross-Platform Testing

### Configuration Management
Test on all platforms:

```powershell
# Get default configuration
$config = Get-Configuration
$config | Format-List

# Update configuration
Update-Configuration -Interval 2000 -MovementPattern Horizontal

# Verify changes
$config = Get-Configuration
$config.Interval  # Should be: 2000
$config.MovementPattern  # Should be: Horizontal

# Save configuration
Save-Configuration

# Reset to defaults
Reset-Configuration
```

### Dependency Installer Script
Test on each platform:

```powershell
# Run dependency installer (with -WhatIf for safety)
./Install-PSMouseJigglerDependencies.ps1 -WhatIf

# View install instructions
Show-DependencyInstallInstructions
```

**Manual Checks:**
- [ ] Windows: Displays "No dependencies needed"
- [ ] Linux: Shows appropriate package manager command (apt/dnf/pacman)
- [ ] macOS: Shows Homebrew installation command

---

## Troubleshooting

### Windows

| Issue | Solution |
|-------|----------|
| GUI doesn't launch | Verify .NET Framework 4.7.2+ installed |
| "Unapproved verb" warning | Safe to ignore (Prevent-SystemIdle) |
| Scheduled task fails | Run PowerShell as Administrator |

### Linux

| Issue | Solution |
|-------|----------|
| "xdotool not found" | Install: `sudo apt-get install xdotool` |
| Mouse not moving (Wayland) | Install ydotool, may need sudo |
| systemd-inhibit fails | Ensure systemd is active |

### macOS

| Issue | Solution |
|-------|----------|
| "cliclick not found" | Install: `brew install cliclick` |
| Mouse not moving | Grant Accessibility permissions |
| caffeinate not working | Built-in, check macOS version (11+) |

### All Platforms

| Issue | Solution |
|-------|----------|
| TUI doesn't launch | Install: `Install-Module Microsoft.PowerShell.ConsoleGuiTools` |
| Module import fails | Check PowerShell version (5.1+ Windows, 7+ Linux/macOS) |
| Function not found | Verify module imported: `Get-Module PSMouseJiggler` |

---

## Test Completion Checklist

Mark off as you complete testing:

### Windows
- [ ] Module loads without errors
- [ ] Platform detection returns "Windows"
- [ ] Windows Forms GUI launches and functions
- [ ] TUI launches and functions
- [ ] All four keep-awake methods work
- [ ] Scheduled tasks create/start/stop/remove
- [ ] Incognito mode works in GUI and CLI

### Linux
- [ ] Module loads without errors
- [ ] Platform detection returns "Linux"
- [ ] TUI launches (GUI not available)
- [ ] xdotool/ydotool mouse movement works
- [ ] systemd-inhibit prevents sleep
- [ ] Works in both X11 and Wayland

### macOS
- [ ] Module loads without errors
- [ ] Platform detection returns "macOS"
- [ ] TUI launches (GUI not available)
- [ ] cliclick mouse movement works
- [ ] caffeinate prevents sleep
- [ ] Accessibility permissions handled

### Cross-Platform
- [ ] Configuration management works on all platforms
- [ ] Dependency installer provides correct instructions
- [ ] All exported functions available
- [ ] Help documentation accessible (`Get-Help <function>`)

---

## Reporting Issues

If you encounter issues during testing:

1. **Capture Environment Info:**
   ```powershell
   $PSVersionTable | Format-List
   Get-OperatingSystemPlatform
   Get-Module PSMouseJiggler | Format-List
   ```

2. **Enable Verbose Output:**
   ```powershell
   Start-PSMouseJiggler -Verbose -Duration 5
   ```

3. **Report on GitHub:**
   - Repository: https://github.com/PowerShellYoungTeam/PSMouseJiggler
   - Include: Platform, PowerShell version, error messages, steps to reproduce

---

**Document Version:** 2.0.0
**Last Updated:** November 2025
**Tested Platforms:** Windows 11, Ubuntu 22.04, macOS 13 Ventura
