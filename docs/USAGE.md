# PSMouseJiggler Usage Instructions

## Overview

PSMouseJiggler is a PowerShell-based tool designed to simulate mouse movements to prevent your computer from going to sleep or to keep your session active. This document provides instructions on how to install, configure, and use PSMouseJiggler.

## Installation

1. **Download the Repository**: Clone or download the Mouse Jiggler repository from GitHub.

   ```powershell
  git clone https://github.com/yourusername/PSMouseJiggler.git
   ```

1. **Run the Installation Script**: Open PowerShell as an administrator and navigate to the PSMouseJiggler directory. Execute the installation script to set up the necessary dependencies.

   ```powershell
  cd PSMouseJiggler
   .\install.ps1
   ```

## Usage

### Module Commands

After installation, you can use PSMouseJiggler through its module commands:

#### Starting PSMouseJiggler

```powershell
# Start with default settings
Start-PSMouseJiggler

# Start with custom interval (in milliseconds)
Start-PSMouseJiggler -Interval 2000

# Start with specific movement pattern
Start-PSMouseJiggler -MovementPattern 'Circular'

# Start for a specific duration (in seconds)
Start-PSMouseJiggler -Duration 300
```

#### Using the GUI

```powershell
# Launch the graphical interface
Show-PSMouseJigglerGUI
```

#### Stopping PSMouseJiggler

```powershell
# Stop the mouse jiggler
Stop-PSMouseJiggler
```

### Configuration

PSMouseJiggler provides several ways to manage configuration:

```powershell
# Get current configuration
$config = Get-Configuration

# Update a specific setting
Update-Configuration -Key "MovementSpeed" -Value 1500

# Reset to default settings
Reset-Configuration
```

Configuration settings include:
- **MovementSpeed**: Speed of mouse movements (in milliseconds)
- **MovementPattern**: Pattern type (Random, Horizontal, Vertical, Circular)
- **AutoJiggle**: Enable automatic jiggling
- **Duration**: How long to run (0 = indefinite)

### Movement Patterns

PSMouseJiggler supports several movement patterns:
- **Random**: Moves mouse to random positions
- **Horizontal**: Moves mouse left and right
- **Vertical**: Moves mouse up and down
- **Circular**: Moves mouse in circular patterns

### Scheduled Tasks

Create scheduled tasks for automatic jiggling:

```powershell
# Create a new scheduled task
New-PSMJScheduledTask -TaskName "MorningJiggler" -Action "powershell.exe -Command 'Start-PSMouseJiggler -Duration 3600'" -StartTime (Get-Date "09:00")

# List existing tasks
Get-PSMJScheduledTasks

# Remove a task
Remove-PSMJScheduledTask -TaskName "MorningJiggler"
```

## Advanced Keep-Awake Methods

PSMouseJiggler now includes advanced methods to prevent system sleep and screensaver activation, using multiple techniques:

### Using the Advanced Keep-Awake Feature

```powershell
# Keep system awake using all available methods
Start-KeepAwake

# Keep system awake for a specific duration (in seconds)
Start-KeepAwake -Duration 3600  # Run for 1 hour

# Specify which methods to use
Start-KeepAwake -Methods 'MouseHardware', 'SystemAPI'

# Customize the interval between actions (in milliseconds)
Start-KeepAwake -Interval 60000  # Perform actions every minute

## Troubleshooting

If you encounter issues, ensure that you have the necessary permissions to run PowerShell scripts. You may need to adjust your execution policy:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Common issues:
- **Module not found**: Ensure PSMouseJiggler is installed in your PowerShell modules directory
- **Functions not available**: Make sure you've imported the module with `Import-Module PSMouseJiggler`
- **Permission errors**: Run PowerShell as administrator or adjust execution policy

## Contribution

For guidelines on contributing to PSMouseJiggler, please refer to the `CONTRIBUTING.md` file in the `docs` directory.

## License

This project is licensed under the terms specified in the `LICENSE` file.