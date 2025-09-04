# PSMouseJiggler Module

A PowerShell module to simulate mouse movements and prevent system idle. Includes GUI interface, configurable movement patterns, and scheduled task support.

## Installation

### From PowerShell Gallery (Recommended)
```powershell
Install-Module -Name PSMouseJiggler -Scope CurrentUser
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

# Stop mouse jiggling
Stop-PSMouseJiggler

# Show the GUI interface
Show-PSMouseJigglerGUI
```

## Features

- **Mouse Movement Simulation**: Simulates mouse movements to keep your computer awake
- **Multiple Movement Patterns**: Random, Horizontal, Vertical, and Circular patterns
- **GUI Interface**: User-friendly graphical interface for easy control
- **Configurable Settings**: Customizable intervals, patterns, and duration
- **Scheduled Tasks**: Create and manage scheduled jiggling tasks
- **PowerShell Gallery Ready**: Properly structured module with manifest

## Available Commands

### Core Functions
- `Start-PSMouseJiggler` - Start mouse jiggling
- `Stop-PSMouseJiggler` - Stop mouse jiggling
- `Show-PSMouseJigglerGUI` - Open the GUI interface

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

### Scheduled Task Functions
- `Get-ScheduledTasks` - Get PSMouseJiggler scheduled tasks
- `New-ScheduledTask` - Create new scheduled task
- `Remove-ScheduledTask` - Remove scheduled task
- `Start-ScheduledTask` - Start scheduled task
- `Stop-ScheduledTask` - Stop scheduled task

## Examples

### Basic Usage
```powershell
# Start with custom interval and pattern
Start-PSMouseJiggler -Interval 2000 -MovementPattern 'Circular'

# Start for specific duration (5 minutes)
Start-PSMouseJiggler -Duration 300
```

### GUI Usage
```powershell
# Open the GUI for interactive control
Show-PSMouseJigglerGUI
```

### Configuration Management
```powershell
# Get current configuration
$config = Get-Configuration

# Update a setting
Update-Configuration -Key "MovementSpeed" -Value 1500

# Reset to defaults
Reset-Configuration
```

### Scheduled Tasks
```powershell
# Create a scheduled task to start jiggling at 9 AM daily
New-ScheduledTask -TaskName "MorningJiggler" -Action "powershell.exe -Command 'Start-PSMouseJiggler -Duration 3600'" -StartTime (Get-Date "09:00")
```

## Requirements

- PowerShell 5.1 or later
- Windows operating system
- .NET Framework 4.7.2 or later
- System.Windows.Forms and System.Drawing assemblies

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
