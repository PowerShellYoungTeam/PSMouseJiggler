# PSMouseJiggler Usage Instructions

## Overview

PSMouseJiggler is a comprehensive PowerShell module that prevents your computer from going idle through various methods including mouse movement simulation, keyboard input, and direct Windows power management control.

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [GUI Interface](#gui-interface)
4. [Command Line Usage](#command-line-usage)
5. [Advanced Features](#advanced-features)
6. [Configuration Management](#configuration-management)
7. [Scheduled Tasks](#scheduled-tasks)
8. [Examples](#examples)
9. [Troubleshooting](#troubleshooting)

## Installation

### From PowerShell Gallery

```powershell
Install-Module -Name PSMouseJiggler -Scope CurrentUser
Import-Module PSMouseJiggler
```

### Verify Installation

```powershell
Get-Module PSMouseJiggler -ListAvailable
Get-Command -Module PSMouseJiggler
```

## Getting Started

### Quick Start with GUI

The easiest way to get started is using the graphical interface:

```powershell
Show-PSMouseJigglerGUI
```

### Quick Start with Command Line

```powershell
# Basic usage - start jiggling
Start-PSMouseJiggler

# Stop jiggling
Stop-PSMouseJiggler
```

## GUI Interface

The GUI provides a modern tabbed interface with three main sections:

### Basic Mode Tab

Perfect for simple mouse jiggling needs:

**Settings:**

- **Movement Pattern**: Choose from Random, Horizontal, Vertical, or Circular
- **Interval**: Time between movements in milliseconds (default: 1000ms)
- **Duration**: How long to run (0 = run until stopped)
- **Mouse Input Method**:
  - Software (Standard): Most compatible, works with standard cursor control
  - Hardware (Low-level): Better for strict security policies using SendInput API
  - Both (Redundant): Maximum reliability using both methods
- **Incognito Mode**: Minimize window and clear console when started

### Advanced Mode Tab

For maximum effectiveness using multiple keep-awake techniques:

**Available Methods** (select one or more):

- **Software Mouse Movements**: Standard cursor position changes
- **Hardware Mouse Input**: Low-level input simulation (SendInput API)
- **Keyboard Input**: Sends non-disruptive F15 key presses
- **System API - SetThreadExecutionState**: Direct Windows power management control

**Settings:**

- **Interval**: Recommended 30000ms (30 seconds) for keep-awake methods
- **Duration**: How long to run (0 = run until stopped)
- **Incognito Mode**: Discreet operation

### Quick Launch Tab

One-click pre-configured profiles for common scenarios:

1. **[Mouse] Basic Discrete**
   - Random mouse movements every 1 second
   - Software method with incognito mode
   - Best for: General use, presentations

2. **[Lock] Maximum Security**
   - Hardware mouse + System API
   - 30 second interval
   - Best for: Strict security policies, enterprise environments

3. **[Key] Keyboard Only**
   - Keyboard input only (F15 key)
   - No mouse movement
   - 30 second interval
   - Best for: When mouse movement is disruptive

4. **[API] System API Only**
   - Direct Windows power management control
   - No input simulation
   - Best for: Minimal resource usage

5. **[MAX] All Methods**
   - All techniques combined
   - Maximum reliability
   - Best for: Critical scenarios, strict power management

## Command Line Usage

### Basic Mouse Jiggling

```powershell
# Start with default settings (Random pattern, 1 second interval)
Start-PSMouseJiggler

# Specify movement pattern
Start-PSMouseJiggler -MovementPattern Circular

# Set custom interval (2 seconds)
Start-PSMouseJiggler -Interval 2000

# Run for specific duration (1 hour = 3600 seconds)
Start-PSMouseJiggler -Duration 3600

# Incognito mode (clears console)
Start-PSMouseJiggler -Incognito

# Combine parameters
Start-PSMouseJiggler -Interval 1500 -MovementPattern Horizontal -Duration 7200 -Incognito
```

### Advanced Keep-Awake Methods

```powershell
# Use all methods
Start-KeepAwake -Methods @('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI')

# Use specific methods
Start-KeepAwake -Methods @('MouseHardware', 'SystemAPI') -Interval 30000

# Keyboard only with incognito mode
Start-KeepAwake -Methods @('Keyboard') -Interval 30000 -Incognito

# System API only (minimal resource usage)
Start-KeepAwake -Methods @('SystemAPI') -Interval 30000

# Custom interval (15 seconds)
Start-KeepAwake -Methods @('MouseSoftware', 'Keyboard') -Interval 15000 -Duration 3600
```

### Stopping Jiggling

```powershell
# Stop any running jiggler or keep-awake
Stop-PSMouseJiggler
```

## Advanced Features

### Movement Patterns

#### Random Pattern

```powershell
Start-PSMouseJiggler -MovementPattern Random
```

- Moves cursor randomly in all directions
- Most natural-looking movement
- Default pattern

#### Horizontal Pattern

```powershell
Start-PSMouseJiggler -MovementPattern Horizontal
```

- Moves cursor left and right only
- Minimal vertical displacement
- Good for wide screens

#### Vertical Pattern

```powershell
Start-PSMouseJiggler -MovementPattern Vertical
```

- Moves cursor up and down only
- Minimal horizontal displacement

#### Circular Pattern

```powershell
Start-PSMouseJiggler -MovementPattern Circular
```

- Smooth circular motion
- Most predictable pattern
- Good for testing

### Incognito Mode

Run discreetly without visible console output:

```powershell
# Command line incognito
Start-PSMouseJiggler -Incognito
Start-KeepAwake -Incognito

# GUI incognito - check the checkbox before starting
# - Minimizes window when started
# - Hides from taskbar
# - Clears console output
# - Auto-restores when stopped
```

### Direct System Control

Advanced functions for custom automation:

```powershell
# Prevent system idle directly
Prevent-SystemIdle

# Send keyboard input
Send-KeyboardInput

# Send hardware mouse input
Send-MouseInput

# Move mouse to specific coordinates
Move-Mouse -X 500 -Y 300
```

## Configuration Management

### View Current Configuration

```powershell
Get-Configuration
```

### Save Configuration

```powershell
# Save current settings
Save-Configuration

# Save with custom values
Save-Configuration -MovementSpeed 1500 -Pattern "Circular"
```

### Update Configuration

```powershell
# Update specific settings
Update-Configuration -MovementSpeed 2000
Update-Configuration -Pattern "Horizontal"
```

### Reset to Defaults

```powershell
Reset-Configuration
```

Configuration settings include:

- **MovementSpeed**: Speed of mouse movements (in milliseconds)
- **MovementPattern**: Pattern type (Random, Horizontal, Vertical, Circular)
- **AutoJiggle**: Enable automatic jiggling
- **Duration**: How long to run (0 = indefinite)

## Scheduled Tasks

PSMouseJiggler uses PSMJ-prefixed function names to avoid conflicts with other PowerShell modules.

### Create Scheduled Task

```powershell
# Create task to start jiggling at 9 AM daily
New-PSMJScheduledTask `
    -TaskName "MorningJiggler" `
    -Action "powershell.exe -Command 'Start-PSMouseJiggler -Duration 28800'" `
    -StartTime (Get-Date "09:00")

# Create repeating task (every 4 hours)
New-PSMJScheduledTask `
    -TaskName "PeriodicJiggler" `
    -Action "powershell.exe -Command 'Start-PSMouseJiggler -Duration 3600'" `
    -StartTime (Get-Date).AddMinutes(5) `
    -RepeatIntervalMinutes 240
```

### Manage Scheduled Tasks

```powershell
# List all PSMouseJiggler tasks
Get-PSMJScheduledTasks

# List specific task
Get-PSMJScheduledTasks -TaskName "MorningJiggler"

# Start task manually
Start-PSMJScheduledTask -TaskName "MorningJiggler"

# Stop running task
Stop-PSMJScheduledTask -TaskName "MorningJiggler"

# Remove a task
Remove-PSMJScheduledTask -TaskName "MorningJiggler"
```

## Examples

### Example 1: Presentation Mode

Keep screen active during a 2-hour presentation:

```powershell
Start-PSMouseJiggler -MovementPattern Random -Interval 1000 -Duration 7200 -Incognito
```

### Example 2: Maximum Security Environment

For systems with strict power policies:

```powershell
Start-KeepAwake -Methods @('MouseHardware', 'SystemAPI') -Interval 30000 -Incognito
```

### Example 3: Overnight Monitoring

Keep monitoring dashboard visible overnight:

```powershell
# Start at 6 PM
Start-PSMouseJiggler -MovementPattern Circular -Interval 30000

# Or use GUI Quick Launch: [Mouse] Basic Discrete
```

### Example 4: Minimal Resource Usage

System API only for minimum CPU usage:

```powershell
Start-KeepAwake -Methods @('SystemAPI') -Interval 60000
```

### Example 5: Scheduled Workday Jiggling

```powershell
# Create task for weekday work hours (9 AM - 5 PM)
New-PSMJScheduledTask `
    -TaskName "WorkHoursJiggler" `
    -Action "powershell.exe -Command 'Start-KeepAwake -Methods @(''MouseSoftware'', ''SystemAPI'') -Duration 28800 -Incognito'" `
    -StartTime (Get-Date "09:00")
```

### Example 6: Testing Different Methods

```powershell
# Test software mouse only
Start-PSMouseJiggler -Interval 1000 -Duration 60
Stop-PSMouseJiggler

# Test hardware mouse only
Start-KeepAwake -Methods @('MouseHardware') -Interval 1000 -Duration 60
Stop-PSMouseJiggler

# Test keyboard only
Start-KeepAwake -Methods @('Keyboard') -Interval 5000 -Duration 60
Stop-PSMouseJiggler
```

## Getting Help

### Command Help

```powershell
# Get detailed help for any command
Get-Help Start-PSMouseJiggler -Full
Get-Help Start-KeepAwake -Full
Get-Help Show-PSMouseJigglerGUI -Full

# Get examples only
Get-Help Start-PSMouseJiggler -Examples

# Get parameter descriptions
Get-Help Start-PSMouseJiggler -Parameter MovementPattern
```

### GUI Help

Click the "? Help" button in the GUI for comprehensive help information.

## Troubleshooting

### Issue: Module Not Found

```powershell
# Verify module is installed
Get-Module PSMouseJiggler -ListAvailable

# If not found, install it
Install-Module PSMouseJiggler -Scope CurrentUser

# Import module explicitly
Import-Module PSMouseJiggler -Force
```

### Issue: GUI Won't Start

```powershell
# Check if required assemblies are available
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# If errors occur, ensure .NET Framework 4.7.2+ is installed
```

### Issue: Already Running Error

```powershell
# Stop any existing instance first
Stop-PSMouseJiggler

# Then start new instance
Start-PSMouseJiggler
```

### Issue: Scheduled Task Conflicts

If you have conflicting scheduled task cmdlets from another module:

```powershell
# Always use PSMJ-prefixed versions
Get-PSMJScheduledTasks
New-PSMJScheduledTask
Start-PSMJScheduledTask
Stop-PSMJScheduledTask
Remove-PSMJScheduledTask
```

### Issue: Functions Not Recognized

```powershell
# Reimport module with force
Import-Module PSMouseJiggler -Force

# Verify functions are exported
Get-Command -Module PSMouseJiggler
```

### Issue: Incognito Mode Not Working

```powershell
# Ensure you have permission to minimize windows
# Run PowerShell as regular user (not elevated) for GUI features

# For console clearing, ensure console host supports Clear-Host
```

## Best Practices

1. **Start with GUI**: Learn the features using the graphical interface first
2. **Use Quick Launch**: Pre-configured profiles work well for most scenarios
3. **Test Duration**: Start with short durations to test before longer runs
4. **Choose Appropriate Method**:
   - Basic software mouse for general use
   - Hardware + System API for strict environments
   - Keyboard only when mouse movement is disruptive
5. **Use Incognito**: Enable incognito mode for discrete operation
6. **Monitor Resource Usage**: System API uses least resources
7. **Schedule Wisely**: Use scheduled tasks for predictable timing needs

## Security Considerations

- PSMouseJiggler simulates user activity but doesn't bypass security policies
- Some enterprise environments may restrict input simulation
- Use responsibly and in accordance with your organization's policies
- Incognito mode provides discretion but doesn't hide process from administrators

## Performance Notes

- **Software Mouse**: Minimal CPU usage, standard compatibility
- **Hardware Mouse**: Slightly higher CPU, better compatibility
- **Keyboard Input**: Very low CPU usage
- **System API**: Lowest CPU usage, most efficient
- **All Methods**: Higher CPU usage but maximum reliability

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Support

- Report issues: [GitHub Issues](https://github.com/PowerShellYoungTeam/PSMouseJiggler/issues)
- Documentation: README.md
- Contributing: CONTRIBUTING.md

---

**Version**: 1.1.0
**Last Updated**: October 2025
