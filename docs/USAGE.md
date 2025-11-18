# PSMouseJiggler v2.0.0 - Usage Guide

Comprehensive usage guide for PSMouseJiggler cross-platform PowerShell module.

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Platform-Specific Setup](#platform-specific-setup)
4. [User Interfaces](#user-interfaces)
5. [Command Line Usage](#command-line-usage)
6. [Advanced Features](#advanced-features)
7. [Configuration Management](#configuration-management)
8. [Scheduled Tasks](#scheduled-tasks)
9. [Platform-Specific Examples](#platform-specific-examples)
10. [Troubleshooting](#troubleshooting)

---

## Installation

### From PowerShell Gallery (All Platforms)

```powershell
# Install the module
Install-Module -Name PSMouseJiggler -Scope CurrentUser

# Import the module
Import-Module PSMouseJiggler
```

### Install Platform Dependencies

Run the automated installer:

```powershell
./Install-PSMouseJigglerDependencies.ps1
```

**Or install manually:**

#### Windows

No external dependencies required! (Optional: .NET Framework 4.7.2+ for GUI)

#### Linux

```bash
# Ubuntu/Debian (X11)
sudo apt-get update
sudo apt-get install xdotool

# Ubuntu/Debian (Wayland)
sudo apt-get install ydotool

# Fedora/RHEL
sudo dnf install xdotool

# Arch Linux
sudo pacman -S xdotool
```

#### macOS

```bash
# Install Homebrew if needed: https://brew.sh
brew install cliclick
```

### Verify Installation

```powershell
# Check module is loaded
Get-Module PSMouseJiggler -ListAvailable

# List all functions
Get-Command -Module PSMouseJiggler

# Check platform detection
Get-OperatingSystemPlatform
```

---

## Getting Started

### Platform Detection

PSMouseJiggler automatically detects your platform:

```powershell
# Get current platform
Get-OperatingSystemPlatform
# Returns: Windows, Linux, or macOS

# Check available capabilities
Test-PlatformCapability -Capability GUI           # Windows only
Test-PlatformCapability -Capability WindowsAPI    # Windows only
Test-PlatformCapability -Capability XDoTool       # Linux (X11)
Test-PlatformCapability -Capability YDoTool       # Linux (Wayland)
Test-PlatformCapability -Capability CliClick      # macOS
Test-PlatformCapability -Capability SystemdInhibit # Linux
Test-PlatformCapability -Capability Caffeinate    # macOS
```

### Quick Start - Windows

```powershell
# Launch GUI
Show-PSMouseJigglerGUI

# Or use command-line
Start-PSMouseJiggler -Duration 30
```

### Quick Start - Linux/macOS

```powershell
# Launch Terminal UI
Show-PSMouseJigglerTUI

# Or use command-line
Start-PSMouseJiggler -Duration 30
```

---

## Platform-Specific Setup

### Windows Setup

**PowerShell Version:**
- Windows PowerShell 5.1 (built-in)
- PowerShell 7+ (recommended, download from https://aka.ms/powershell)

**GUI Requirements:**
- .NET Framework 4.7.2 or later (usually pre-installed)

**No external tools required!**

### Linux Setup

**PowerShell Version:**
- PowerShell 7+ required (https://aka.ms/powershell)

**Display Server Detection:**

```bash
# Check your display server
echo $XDG_SESSION_TYPE
# Output: x11 or wayland
```

**For X11 (most distributions):**

```bash
sudo apt-get install xdotool  # Ubuntu/Debian
sudo dnf install xdotool      # Fedora/RHEL
sudo pacman -S xdotool        # Arch Linux
```

**For Wayland:**

```bash
sudo apt-get install ydotool  # Ubuntu/Debian
# May require elevated permissions or input group membership
sudo usermod -aG input $USER  # Add user to input group
```

**Verify Installation:**

```bash
xdotool version  # or: ydotool --version
```

### macOS Setup

**PowerShell Version:**
- PowerShell 7+ required (https://aka.ms/powershell)

**Install Dependencies:**

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install cliclick
brew install cliclick

# Verify
cliclick -V
```

**Accessibility Permissions:**

macOS requires Accessibility permissions for mouse simulation:

1. Open **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**
2. Click the lock icon and authenticate
3. Add **Terminal** or **PowerShell** to the allowed apps list
4. Check the box to enable
5. Restart PowerShell session

**Test Permissions:**

```powershell
# This should work without "Accessibility" errors
Start-PSMouseJiggler -Duration 3
```

---

## User Interfaces

### Windows Forms GUI (Windows Only)

**Launch:**

```powershell
Show-PSMouseJigglerGUI
```

**Features:**
- 3 tabs: Basic Mode, Advanced Mode, Quick Launch
- 5 preset profiles for common scenarios
- Visual status indicators
- Real-time configuration

**Tabs Overview:**

#### 1. Basic Mode Tab

- Movement Pattern: Random, Horizontal, Vertical, Circular
- Interval: Time between movements (default: 1000ms)
- Duration: Run time (0 = indefinite)
- Mouse Input Method: Software, Hardware, or Both
- Incognito Mode: Minimize and hide console

#### 2. Advanced Mode Tab

- Multiple keep-awake methods (checkboxes):
  - Software Mouse Movements
  - Hardware Mouse Input (SendInput API)
  - Keyboard Input (F15 key)
  - System API (SetThreadExecutionState)
- Longer intervals recommended (30 seconds)
- Duration control

#### 3. Quick Launch Tab

- **[Mouse] Basic Discrete**: Random movements, 1-second interval, incognito
- **[Lock] Maximum Security**: Hardware mouse + System API
- **[Key] Keyboard Only**: F15 key presses only
- **[API] System API Only**: Direct power management
- **[MAX] All Methods**: Maximum reliability

### Terminal UI (All Platforms)

**Requirements:**

```powershell
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
```

**Launch:**

```powershell
Show-PSMouseJigglerTUI
```

**Features:**
- Cross-platform text-based interface
- Platform-aware method selection (shows only available methods)
- Granular control with checkboxes for each keep-awake method
- Movement pattern configuration
- Incognito mode toggle
- Real-time status display

**Platform-Specific Method Availability:**

**Windows TUI:**
- ☑️ Software Mouse Movements
- ☑️ Hardware Mouse Input
- ☑️ Keyboard Input (F15)
- ☑️ System API (SetThreadExecutionState)

**Linux TUI:**
- ☑️ Software Mouse Movements
- ☑️ System API (systemd-inhibit)

**macOS TUI:**
- ☑️ Software Mouse Movements
- ☑️ System API (caffeinate)

---

## Command Line Usage

### Basic Mouse Jiggling

```powershell
# Start with default settings (random pattern, 3-second interval)
Start-PSMouseJiggler

# Run for 30 minutes
Start-PSMouseJiggler -Duration 30

# Custom pattern
Start-PSMouseJiggler -Pattern Circular

# Custom interval (5 seconds)
Start-PSMouseJiggler -Interval 5

# Combine options
Start-PSMouseJiggler -Pattern Horizontal -Interval 2 -Duration 60

# Stop manually
Stop-PSMouseJiggler
```

**Available Patterns:**
- `Random` - Random direction and distance (default, most natural)
- `Horizontal` - Left-right movement only
- `Vertical` - Up-down movement only
- `Circular` - Smooth clockwise circular motion

### Advanced Keep-Awake

```powershell
# Windows: Multiple methods
Start-KeepAwake -Methods @('MouseSoftware', 'Keyboard', 'SystemAPI') -Interval 3

# Linux: Available methods
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 60

# macOS: Available methods
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 60

# Incognito mode (no visible cursor movement)
Start-KeepAwake -Methods @('SystemAPI') -Incognito

# Custom interval (30 seconds recommended for keep-awake)
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Interval 30

# Stop any running keep-awake
Stop-PSMouseJiggler
```

**Method Availability by Platform:**

| Method | Windows | Linux | macOS |
|--------|:-------:|:-----:|:-----:|
| `MouseSoftware` | ✅ | ✅ | ✅ |
| `MouseHardware` | ✅ | ❌ | ❌ |
| `Keyboard` | ✅ | ❌ | ❌ |
| `SystemAPI` | ✅ | ✅ | ✅ |

### Direct Function Calls

```powershell
# Move mouse cursor
Move-Mouse -X 100 -Y 100

# Prevent system idle (Windows)
Prevent-SystemIdle -IdlePrevention $true

# Cross-platform mouse movement wrapper
Invoke-MouseMove -X 200 -Y 200 -Relative

# Cross-platform idle prevention wrapper
Invoke-SystemIdlePrevention -Enable $true -Reason "Automated testing"
```

---

## Advanced Features

### Incognito Mode

Keep system awake with **zero visible mouse cursor movement**:

```powershell
# System API only (no mouse movement)
Start-KeepAwake -Methods @('SystemAPI') -Incognito

# GUI: Check "Incognito Mode" checkbox
Show-PSMouseJigglerGUI

# TUI: Toggle "Incognito Mode" checkbox
Show-PSMouseJigglerTUI
```

**How Incognito Works:**
- Disables all mouse movement methods
- Uses only system power management APIs
- No visible cursor changes
- Console minimized/hidden (optional)

### Movement Pattern Customization

```powershell
# Get new position for pattern
$newPos = Get-NewMousePosition -CurrentX 500 -CurrentY 500 -Pattern Circular

# Start custom movement pattern
Start-MovementPattern -Pattern Random -Interval 3 -Duration 10

# Stop pattern
Stop-MovementPattern
```

### Platform-Specific API Access

#### Windows

```powershell
# Direct Windows API call
Prevent-SystemIdle -IdlePrevention $true

# Send F15 key press
Send-KeyboardInput

# Send hardware mouse input
Send-MouseInput -X 0 -Y 1 -Relative

# Move cursor with software API
Move-Mouse -X 100 -Y 100 -Relative
```

#### Linux

```powershell
# Cross-platform wrapper (auto-detects xdotool/ydotool)
Invoke-MouseMove -X 10 -Y 10 -Relative

# Cross-platform idle prevention (uses systemd-inhibit)
Invoke-SystemIdlePrevention -Enable $true -Reason "Build process"
```

#### macOS

```powershell
# Cross-platform wrapper (uses cliclick)
Invoke-MouseMove -X 10 -Y 10 -Relative

# Cross-platform idle prevention (uses caffeinate)
Invoke-SystemIdlePrevention -Enable $true -Reason "Rendering video"
```

---

## Configuration Management

### View Configuration

```powershell
# Get current configuration
Get-Configuration

# View specific setting
(Get-Configuration).Interval
(Get-Configuration).Pattern
```

### Update Configuration

```powershell
# Update interval
Update-Configuration -Interval 5000

# Update pattern
Update-Configuration -Pattern Circular

# Update multiple settings
Update-Configuration -Interval 3000 -Pattern Random -Duration 30
```

### Save and Reset

```powershell
# Save current configuration to file
Save-Configuration

# Reset to defaults
Reset-Configuration

# Verify reset
Get-Configuration
```

**Default Configuration:**

```json
{
  "Interval": 3000,
  "Pattern": "Random",
  "Duration": 0,
  "MouseInputMethod": "Software",
  "IncognitoMode": false
}
```

---

## Scheduled Tasks

### Windows Task Scheduler

```powershell
# Create daily scheduled task (9 AM, 8-hour duration)
New-PSMJScheduledTask -TaskName "KeepAwake-Work" -StartTime "09:00" -Duration 480

# List all PSMouseJiggler scheduled tasks
Get-PSMJScheduledTasks

# Start task manually
Start-PSMJScheduledTask -TaskName "KeepAwake-Work"

# Stop running task
Stop-PSMJScheduledTask -TaskName "KeepAwake-Work"

# Remove task
Remove-PSMJScheduledTask -TaskName "KeepAwake-Work"
```

### Linux systemd Timers

```powershell
# Create daily systemd timer (9 AM, 8-hour duration)
New-PSMJScheduledTask -TaskName "keep-awake-work" -StartTime "09:00" -Duration 480

# List timers
Get-PSMJScheduledTasks

# Start timer manually
Start-PSMJScheduledTask -TaskName "keep-awake-work"

# Stop timer
Stop-PSMJScheduledTask -TaskName "keep-awake-work"

# Remove timer
Remove-PSMJScheduledTask -TaskName "keep-awake-work"
```

### macOS launchd

```powershell
# Create daily launchd job (9 AM, 8-hour duration)
New-PSMJScheduledTask -TaskName "KeepAwakeWork" -StartTime "09:00" -Duration 480

# List jobs
Get-PSMJScheduledTasks

# Start job manually
Start-PSMJScheduledTask -TaskName "KeepAwakeWork"

# Stop job
Stop-PSMJScheduledTask -TaskName "KeepAwakeWork"

# Remove job
Remove-PSMJScheduledTask -TaskName "KeepAwakeWork"
```

---

## Platform-Specific Examples

### Windows Examples

**Example 1: Presentation Mode**

```powershell
# Use GUI for visual control
Show-PSMouseJigglerGUI

# Select: [Mouse] Basic Discrete profile
# - Random movements every 1 second
# - Incognito mode enabled
# - Runs until manually stopped
```

**Example 2: Overnight Build**

```powershell
# Maximum reliability with all methods
Start-KeepAwake -Methods @('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI') -Duration 480 -Incognito
```

**Example 3: Remote Desktop Session**

```powershell
# Keep RDP session active (System API only)
Start-KeepAwake -Methods @('SystemAPI') -Incognito
```

**Example 4: Scheduled Daily Activation**

```powershell
# Keep system awake during work hours (9 AM - 5 PM)
New-PSMJScheduledTask -TaskName "WorkHours-KeepAwake" -StartTime "09:00" -Duration 480
```

### Linux Examples

**Example 1: SSH Session Keep-Alive**

```powershell
# Launch TUI for terminal-based control
Show-PSMouseJigglerTUI

# Or use command-line
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 120
```

**Example 2: Long Download (X11)**

```powershell
# Check display server
echo $XDG_SESSION_TYPE  # x11

# Start keep-awake with xdotool
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Interval 30
```

**Example 3: Build Process (Wayland)**

```powershell
# Wayland with ydotool (may need sudo)
Start-KeepAwake -Methods @('SystemAPI') -Duration 60 -Incognito

# Or with elevated permissions
sudo pwsh -Command "Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 60"
```

**Example 4: Monitoring Dashboard**

```powershell
# Keep display active with systemd-inhibit only
Start-KeepAwake -Methods @('SystemAPI') -Incognito

# Verify inhibitor is active
systemd-inhibit --list
```

**Example 5: Scheduled Server Maintenance**

```powershell
# Create timer for daily 2 AM maintenance window
New-PSMJScheduledTask -TaskName "maintenance-keep-awake" -StartTime "02:00" -Duration 120

# Verify timer
systemctl --user list-timers
```

### macOS Examples

**Example 1: Video Rendering**

```powershell
# Launch TUI
Show-PSMouseJigglerTUI

# Select: Software Mouse + System API
# Set Duration: 180 minutes (3 hours)
```

**Example 2: Xcode Build**

```powershell
# Grant Accessibility permissions first (System Preferences)
# Then start keep-awake
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 60
```

**Example 3: Overnight Download**

```powershell
# Use caffeinate only (no Accessibility permissions needed)
Start-KeepAwake -Methods @('SystemAPI') -Duration 480 -Incognito
```

**Example 4: Presentation (no mouse movement)**

```powershell
# System API only, no visible cursor changes
Start-KeepAwake -Methods @('SystemAPI') -Incognito
```

**Example 5: Scheduled Daily Backup**

```powershell
# Create launchd job for 3 AM backups
New-PSMJScheduledTask -TaskName "BackupKeepAwake" -StartTime "03:00" -Duration 120

# Verify job
launchctl list | grep PSMouseJiggler
```

---

## Troubleshooting

### General Issues

**Module Won't Load**

```powershell
# Check PowerShell version
$PSVersionTable

# Windows: 5.1+ or 7+
# Linux/macOS: 7+ only

# Re-import module
Import-Module PSMouseJiggler -Force
```

**Function Not Found**

```powershell
# Verify module is loaded
Get-Module PSMouseJiggler

# If not loaded
Import-Module PSMouseJiggler

# List all functions
Get-Command -Module PSMouseJiggler
```

**Configuration Not Saving**

```powershell
# Check module config directory
$configPath = Join-Path $PSScriptRoot "config"
Test-Path $configPath

# Check file permissions
Get-Acl $configPath  # Windows
ls -la $configPath   # Linux/macOS
```

### Windows Issues

**GUI Doesn't Launch**

```powershell
# Check .NET Framework version
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" | Select-Object -Property Release, Version

# Minimum: 4.7.2 (Release 461808)
# Install from: https://dotnet.microsoft.com/download/dotnet-framework
```

**"Unapproved Verb" Warning**
- Safe to ignore. `Prevent-SystemIdle` uses non-standard verb but is intentional.

**Scheduled Task Fails**

```powershell
# Run PowerShell as Administrator
# Then recreate task
Remove-PSMJScheduledTask -TaskName "YourTask"
New-PSMJScheduledTask -TaskName "YourTask" -StartTime "09:00" -Duration 480
```

**Mouse Not Moving**
- Check if antivirus blocks input simulation
- Try different method: `Start-PSMouseJiggler` or `Start-KeepAwake -Methods @('MouseHardware')`

### Linux Issues

**"xdotool not found"**

```bash
# Install xdotool
sudo apt-get update && sudo apt-get install xdotool  # Ubuntu/Debian
sudo dnf install xdotool                              # Fedora/RHEL
sudo pacman -S xdotool                                # Arch Linux

# Verify
xdotool version
```

**Mouse Doesn't Move (Wayland)**

```bash
# Check display server
echo $XDG_SESSION_TYPE  # Should show: wayland

# Install ydotool
sudo apt-get install ydotool

# Add user to input group (may be required)
sudo usermod -aG input $USER
newgrp input  # Apply group change

# Or run with sudo
sudo pwsh -Command "Start-PSMouseJiggler"
```

**systemd-inhibit Not Found**

```bash
# Check systemd is installed
systemctl --version

# Most distributions include systemd by default
# If missing, install systemd package
```

**Permission Denied (ydotool)**

```bash
# Option 1: Add user to input group
sudo usermod -aG input $USER
newgrp input

# Option 2: Run with sudo
sudo pwsh -Command "Import-Module PSMouseJiggler; Start-PSMouseJiggler"
```

**Test Platform Capabilities**

```powershell
# Check available tools
Test-ExternalToolAvailable -Tool "xdotool"
Test-ExternalToolAvailable -Tool "ydotool"

# Check capabilities
Test-PlatformCapability -Capability XDoTool
Test-PlatformCapability -Capability YDoTool
Test-PlatformCapability -Capability SystemdInhibit
```

### macOS Issues

**"cliclick not found"**

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install cliclick
brew install cliclick

# Verify
cliclick -V
```

**Mouse Doesn't Move**

```plaintext
Grant Accessibility permissions:

1. Open System Preferences
2. Go to Security & Privacy → Privacy → Accessibility
3. Click lock icon and authenticate
4. Add Terminal or PowerShell to list
5. Check the box to enable
6. Restart PowerShell session

Test:
Start-PSMouseJiggler -Duration 3
```

**caffeinate Not Working**

```bash
# caffeinate is built-in on macOS 11+
# Check macOS version
sw_vers

# If older, consider upgrading
```

**Homebrew Not Installed**

```bash
# Install from official site
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Follow on-screen instructions
```

**Test Platform Capabilities**

```powershell
# Check available tools
Test-ExternalToolAvailable -Tool "cliclick"
Test-ExternalToolAvailable -Tool "caffeinate"

# Check capabilities
Test-PlatformCapability -Capability CliClick
Test-PlatformCapability -Capability Caffeinate
```

### TUI Issues

**TUI Doesn't Launch**

```powershell
# Install Microsoft.PowerShell.ConsoleGuiTools
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser

# Verify installation
Get-Module Microsoft.PowerShell.ConsoleGuiTools -ListAvailable

# Try launching again
Show-PSMouseJigglerTUI
```

**TUI Shows Wrong Methods**

```powershell
# Check platform detection
Get-OperatingSystemPlatform

# Verify capabilities
Test-PlatformCapability -Capability GUI           # Windows only
Test-PlatformCapability -Capability XDoTool       # Linux
Test-PlatformCapability -Capability CliClick      # macOS

# TUI automatically hides unavailable methods
```

### Getting Additional Help

**Command Help:**

```powershell
# Detailed help for any function
Get-Help Start-PSMouseJiggler -Detailed
Get-Help Show-PSMouseJigglerTUI -Examples
Get-Help Start-KeepAwake -Full
Get-Help Test-PlatformCapability -Parameter Capability

# List all parameters
Get-Help New-PSMJScheduledTask -Parameter *
```

**Documentation:**
- [Main README](../README.md) - Overview and quick start
- [Platform Support](PLATFORM_SUPPORT.md) - Platform-specific details and compatibility matrix
- [Manual Testing](MANUAL_TESTING.md) - Comprehensive testing procedures
- [Contributing](CONTRIBUTING.md) - Development guidelines

**Support Channels:**
- **GitHub Issues**: https://github.com/PowerShellYoungTeam/PSMouseJiggler/issues
- **GitHub Discussions**: https://github.com/PowerShellYoungTeam/PSMouseJiggler/discussions

---

**Document Version:** 2.0.0
**Last Updated:** November 2025
**Platforms:** Windows 10/11, Linux (Ubuntu 20.04+, Fedora 36+, Debian 11+, Arch, openSUSE), macOS 11+
