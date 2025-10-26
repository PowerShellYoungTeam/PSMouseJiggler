# PSMouseJiggler Module

A comprehensive PowerShell module to simulate mouse movements, keyboard input, and system power management to prevent system idle. Includes modern tabbed GUI interface, Quick Launch profiles, configurable movement patterns, advanced keep-awake methods, and scheduled task support.

## Installation

### From PowerShell Gallery (Recommended)

```powershell
Install-Module -Name PSMouseJiggler -Scope CurrentUser
Import-Module PSMouseJiggler
```

### Manual Installation

1. Download the module files
2. Copy the `PSMouseJiggler` folder to one of your PowerShell module paths:
   - `$env:USERPROFILE\Documents\PowerShell\Modules\` (PowerShell 7+)
   - `$env:USERPROFILE\Documents\WindowsPowerShell\Modules\` (Windows PowerShell 5.1)

## Quick Start

```powershell
# Import the module
Import-Module PSMouseJiggler

# Start mouse jiggling with default settings
Start-PSMouseJiggler

# Start with incognito mode (minimizes window, clears console)
Start-PSMouseJiggler -Incognito

# Use advanced keep-awake methods
Start-KeepAwake -Methods @('MouseHardware', 'SystemAPI')

# Stop any running jiggler
Stop-PSMouseJiggler

# Show the GUI interface with tabbed controls
Show-PSMouseJigglerGUI
```

## Features

- **Mouse Movement Simulation**: Software and hardware-level mouse movements to keep your computer awake
- **Advanced Keep-Awake Methods**: Multiple techniques to prevent sleep:
  - Software mouse movements (standard cursor control)
  - Hardware mouse input (SendInput API for low-level simulation)
  - Keyboard activity simulation (F15 key presses)
  - Direct Windows API calls (SetThreadExecutionState)
- **Modern Tabbed GUI Interface**:
  - Basic Mode: Simple mouse jiggling controls
  - Advanced Mode: Multi-method keep-awake configuration
  - Quick Launch: Five pre-configured profiles for common scenarios
- **Quick Launch Profiles**:
  - [Mouse] Basic Discrete: Random movements with incognito mode
  - [Lock] Maximum Security: Hardware + System API for strict policies
  - [Key] Keyboard Only: Non-visual keep-awake method
  - [API] System API Only: Minimal resource usage
  - [MAX] All Methods: Maximum reliability combining all techniques
- **Custom Movement Patterns**: Random, Horizontal, Vertical, and Circular patterns
- **Incognito Mode**: Minimizes GUI and clears console for discreet operation
- **Scheduled Jiggling**: Set up automatic jiggling at specified times using scheduled tasks
- **Configuration Management**: Load and save user preferences for a personalized experience
- **PowerShell Module**: Properly structured as a PowerShell module for easy installation and management
- **Testing Framework**: Includes Pester unit tests to ensure core functionalities work as expected
- **PSMJ-Prefixed Functions**: Scheduled task functions use PSMJ prefix to avoid conflicts with other modules

## Available Commands

### Core Functions

- `Start-PSMouseJiggler` - Start mouse jiggling with optional incognito mode
- `Start-KeepAwake` - Advanced multi-method keep-awake functionality
- `Stop-PSMouseJiggler` - Stop any running jiggler or keep-awake process
- `Show-PSMouseJigglerGUI` - Open the modern tabbed GUI interface

### Configuration Functions

- `Get-Configuration` - Get current configuration
- `Save-Configuration` - Save configuration to file
- `Update-Configuration` - Update specific configuration setting
- `Reset-Configuration` - Reset to default configuration

### Movement Functions

- `Get-RandomMovementPattern` - Get a random movement pattern
- `Move-Mouse` - Move mouse by relative coordinates
- `Start-MovementPattern` - Start movement pattern for duration
- `Stop-MovementPattern` - Stop movement pattern

### Scheduled Task Functions (PSMJ-Prefixed)

- `Get-PSMJScheduledTasks` - Get PSMouseJiggler scheduled tasks
- `New-PSMJScheduledTask` - Create new scheduled task
- `Remove-PSMJScheduledTask` - Remove scheduled task
- `Start-PSMJScheduledTask` - Start scheduled task
- `Stop-PSMJScheduledTask` - Stop scheduled task

### Advanced Keep-Awake Functions

- `Prevent-SystemIdle` - Direct Windows API call to prevent system idle
- `Send-KeyboardInput` - Send hardware-level keyboard input (F15 key)
- `Send-MouseInput` - Send hardware-level mouse input via SendInput API

## Examples

### Basic Usage

```powershell
# Start with custom interval and pattern
Start-PSMouseJiggler -Interval 2000 -MovementPattern 'Circular'

# Start for specific duration (5 minutes) with incognito mode
Start-PSMouseJiggler -Duration 300 -Incognito

# Use hardware mouse input for strict security policies
Start-KeepAwake -Methods @('MouseHardware') -Interval 30000
```

### Advanced Keep-Awake Usage

```powershell
# Use multiple methods for maximum reliability
Start-KeepAwake -Methods @('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI')

# Keyboard only (no visible movement)
Start-KeepAwake -Methods @('Keyboard') -Interval 30000 -Incognito

# System API only (minimal resource usage)
Start-KeepAwake -Methods @('SystemAPI') -Interval 60000
```

### GUI Usage

```powershell
# Open the GUI for interactive control
Show-PSMouseJigglerGUI

# GUI provides three tabs:
# - Basic: Simple mouse jiggling
# - Advanced: Multi-method keep-awake
# - Quick Launch: Pre-configured profiles
```

### Configuration Management

```powershell
# Get current configuration
$config = Get-Configuration

# Update a setting
Update-Configuration -MovementSpeed 1500

# Reset to defaults
Reset-Configuration
```

### Scheduled Tasks

```powershell
# Create a scheduled task to start jiggling at 9 AM daily
New-PSMJScheduledTask `
    -TaskName "MorningJiggler" `
    -Action "powershell.exe -Command 'Start-PSMouseJiggler -Duration 28800'" `
    -StartTime (Get-Date "09:00")

# List all PSMouseJiggler scheduled tasks
Get-PSMJScheduledTasks

# Remove a scheduled task
Remove-PSMJScheduledTask -TaskName "MorningJiggler"
```

## Requirements

- PowerShell 5.1 or later
- Windows operating system
- .NET Framework 4.7.2 or later (required for GUI and P/Invoke features)
- System.Windows.Forms and System.Drawing assemblies

## GUI Interface

The GUI provides three main tabs:

### Basic Mode

- Movement pattern selection (Random, Horizontal, Vertical, Circular)
- Interval and duration controls
- Mouse input method selection (Software, Hardware, Both)
- Incognito mode checkbox

### Advanced Mode

- Multiple keep-awake method selection (checkboxes for each method)
- Recommended 30-second interval
- Duration and incognito controls
- Info label explaining each method

### Quick Launch

- Five pre-configured profiles with one-click start
- Each profile optimized for specific use cases
- Descriptions and recommended scenarios included

## Version History

### Version 1.1.0 (October 2025)

- Added tabbed GUI interface (Basic, Advanced, Quick Launch)
- Implemented Quick Launch profiles for common scenarios
- Added incognito mode for discreet operation
- Implemented hardware-level mouse input (SendInput API)
- Added keyboard input simulation (F15 key)
- Implemented direct Windows power management (SetThreadExecutionState)
- Created Start-KeepAwake function with multi-method support
- Renamed scheduled task functions with PSMJ prefix to avoid conflicts
- Fixed emoji encoding issues in GUI
- Enhanced GUI state management
- Comprehensive documentation updates

### Version 1.0.3

- Renamed scheduled task functions to avoid module conflicts
- Improved test reliability

### Version 1.0.0

- Initial release with basic mouse jiggling functionality

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Support

- Report issues: [GitHub Issues](https://github.com/PowerShellYoungTeam/PSMouseJiggler/issues)
- Documentation: See README.md and docs/USAGE.md
- Contributing: See docs/CONTRIBUTING.md

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. See CONTRIBUTING.md for guidelines.

---

**Version**: 1.1.0
**Author**: Steven Wight
**Last Updated**: October 2025
