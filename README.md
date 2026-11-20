# PSMouseJiggler

PSMouseJiggler is a PowerShell module that simulates mouse movements and offers other keep-awake methods to help reduce interruptions from system idle behavior. It provides both a command-line interface and a graphical user interface (GUI).

## Project History and Intended Use

PSMouseJiggler began as a slightly cheeky way to work around centrally configured sleep and screensaver settings while watching scripts run or giving presentations. Later, during authorised late-night network testing, it found a legitimate use helping keep VDI sessions active so idle timeouts were less likely to interrupt tests or produce misleading results. Its use grew from there to other situations where a system needs to remain active with permission.

PSMouseJiggler is not intended to fool workplace monitoring systems. Its interaction with those systems has not been tested, so we make no claim about whether it can or cannot bypass them. Use the tool only where you are authorised to do so and in accordance with applicable policies. Its effect on idle behavior depends on the system, configuration, and method used; it does not guarantee that a session will stay active.

![CI](https://github.com/PowerShellYoungTeam/PSMouseJiggler/actions/workflows/ci.yml/badge.svg)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSMouseJiggler)](https://www.powershellgallery.com/packages/PSMouseJiggler)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSMouseJiggler)](https://www.powershellgallery.com/packages/PSMouseJiggler)

## Features

- **Mouse Movement Simulation**: Simulates mouse movements to keep your computer awake
- **Advanced Keep-Awake Methods**: Multiple techniques including hardware input, keyboard, and System API
- **Graphical User Interface**: Modern tabbed GUI with Basic, Advanced, and Quick Launch modes
- **Quick Launch Profiles**: Pre-configured profiles for common scenarios with one-click start
- **Custom Movement Patterns**: Choose from Random, Horizontal, Vertical, or Circular patterns
- **Incognito Mode**: Minimizes the GUI and clears console output (useful for presentations, videos, script watching/getting console back)
- **Scheduled Jiggling**: Set up automatic jiggling at specified times using scheduled tasks
- **Configuration Management**: Load and save user preferences for a personalized experience
- **PowerShell Module**: Properly structured as a PowerShell module for easy installation and management
- **Testing Framework**: Includes unit tests to ensure core functionalities work as expected

## Getting Started

### Prerequisites

- PowerShell 5.1 or later
- Windows operating system
- .NET Framework 4.7.2 or later

### Installation

#### From PowerShell Gallery (Recommended)

```powershell
Install-Module -Name PSMouseJiggler -Scope CurrentUser
```

#### Using the Installer Script

```powershell
.\install.ps1
```

#### Manual Installation

1. Copy the `PSMouseJiggler` folder from [`src/PSMouseJiggler`](src/PSMouseJiggler) to your PowerShell modules directory:
   - Windows PowerShell: `$env:USERPROFILE\Documents\WindowsPowerShell\Modules\`
   - PowerShell Core: `$env:USERPROFILE\Documents\PowerShell\Modules\`

2. Import the module:
```powershell
Import-Module PSMouseJiggler
```

### Quick Start

#### Launch the GUI (Recommended for First-Time Users)

```powershell
Show-PSMouseJigglerGUI
```

The GUI provides three modes:
- **Basic Mode**: Simple mouse jiggling with pattern selection
- **Advanced Mode**: Combine multiple keep-awake methods; effectiveness depends on the environment
- **Quick Launch**: One-click pre-configured profiles for common scenarios

#### Command Line Usage

```powershell
# Basic mouse jiggling
Start-PSMouseJiggler

# With custom settings
Start-PSMouseJiggler -Interval 2000 -MovementPattern Circular -Duration 3600

# Incognito mode (minimizes the GUI and clears console output)
Start-PSMouseJiggler -Incognito

# Advanced keep-awake with multiple methods
Start-PSMouseJiggler -Methods @('MouseHardware', 'Keyboard', 'SystemAPI') -Interval 30000

# Keep some apps active without moving the mouse (SystemAPI + Keyboard)
Start-PSMouseJiggler -Strategy AppKeepAlive -Interval 30000

# Stop jiggling
Stop-PSMouseJiggler
```

### Available Commands

#### Core Functions
- `Start-PSMouseJiggler` - Start mouse jiggling and/or multi-method keep-awake (Methods/Strategy params)
- `Stop-PSMouseJiggler` - Stop the currently running jiggler
- `Get-PSMJRecommendedMethods` - Show methods selected by an intelligent strategy
- `Show-PSMouseJigglerGUI` - Launch the graphical user interface

#### Configuration Functions
- `Get-Configuration` - Get current configuration settings
- `Save-Configuration` - Save configuration to file
- `Update-Configuration` - Update specific configuration values
- `Reset-Configuration` - Reset to default configuration
- `Get-PSMJProfile` - List saved profiles or retrieve one by name
- `Save-PSMJProfile` - Save or replace a named profile
- `Remove-PSMJProfile` - Remove a saved profile
- `Start-PSMJProfile` - Start a saved profile
- `Get-PSMJDiagnostics` - Report runtime, configuration, and profile health

Example saved profile:

```powershell
$profile = [PSCustomObject]@{
   Interval        = 1500
   Duration        = 3600
   MovementPattern = 'Circular'
   Incognito       = $true
}

Save-PSMJProfile -Name 'Presentation' -Profile $profile
Get-PSMJProfile -Name 'Presentation'
Start-PSMJProfile -Name 'Presentation'
Get-PSMJDiagnostics | Format-List
Remove-PSMJProfile -Name 'Presentation'
```

Keep-awake strategies are opt-in. The default `Manual` strategy uses whatever `-Methods` you pass in (or plain mouse jiggling if omitted). Use `Adaptive` to select a low-disruption method combination for the current Windows environment, `LowImpact` to use the Windows power API only, `Compatibility` to use standard software mouse movement, or `AppKeepAlive` to combine System API + Keyboard (keeps some Windows apps active without moving the mouse):

```powershell
Get-PSMJRecommendedMethods -Strategy Adaptive
Start-PSMouseJiggler -Strategy Adaptive -Interval 30000
Start-PSMouseJiggler -Strategy LowImpact -Duration 3600
Start-PSMouseJiggler -Strategy AppKeepAlive -Duration 3600
```

#### Scheduled Task Functions (with PSMJ prefix to avoid conflicts)
- `Get-PSMJScheduledTasks` - List PSMouseJiggler scheduled tasks
- `Get-PSMJScheduledTaskStatus` - Return normalized task status for monitoring or GUI use
- `New-PSMJScheduledProfileTask` - Schedule a saved profile by name
- `New-PSMJScheduledTask` - Create a new scheduled task
- `Remove-PSMJScheduledTask` - Remove a scheduled task
- `Start-PSMJScheduledTask` - Manually start a scheduled task
- `Stop-PSMJScheduledTask` - Stop a running scheduled task

#### Advanced Functions
- `Prevent-SystemIdle` - Directly prevent system idle using Windows API
- `Send-KeyboardInput` - Send keyboard input (F15 key)
- `Send-MouseInput` - Send hardware-level mouse input
- `Move-Mouse` - Move mouse cursor to specific coordinates
- `Get-NewMousePosition` - Calculate new mouse position based on pattern
- `Start-MovementPattern` - Start a custom movement pattern
- `Stop-MovementPattern` - Stop custom movement pattern

For detailed usage instructions, please refer to the USAGE.md file.

## Quick Launch Profiles

The GUI includes five pre-configured profiles for common scenarios:

1. **[Mouse] Basic Discrete** - Random mouse movements every 1 second with incognito mode
2. **[Lock] Maximum Security** - Hardware mouse + System API; effectiveness depends on the environment and applicable policies
3. **[Key] Keyboard Only** - Keyboard input only, no mouse movement
4. **[API] System API Only** - Direct Windows power management control
5. **[MAX] All Methods** - Maximum reliability using all available techniques

## Module Structure

```
PSMouseJiggler/
├── src/
│   └── PSMouseJiggler/
│       ├── PSMouseJiggler.psd1      # Module manifest
│       ├── PSMouseJiggler.psm1      # Main module file
│       ├── config/
│       │   └── default.json         # Default configuration
│       └── README.md                # Module documentation
├── tests/
│   └── PSMouseJiggler.Tests.ps1     # Pester tests
├── docs/
│   ├── CONTRIBUTING.md              # Contribution guidelines
│   └── USAGE.md                     # Detailed usage guide
├── .github/
│   └── workflows/
│       ├── ci.yml                   # Continuous integration
│       └── publish.yml              # Publishing workflow
├── QuickStart.ps1                   # Quick start demo script
├── Validate.ps1                     # Validation script
└── README.md                        # This file
```

## Use Cases

- **Presentations and scripts**: Help reduce idle interruptions while presenting or watching a script run
- **Authorised network testing**: Help keep a VDI session active during a test so an idle timeout is less likely to interrupt it or affect results
- **Long-running tasks**: Help reduce idle interruptions during downloads, rendering, or dashboard monitoring

These are use cases, not guarantees; behavior depends on the system and its settings.

## Contributing

We welcome contributions! Please read the CONTRIBUTING.md file for guidelines on how to contribute to the project.

## Troubleshooting

### Module Won't Load
Ensure you're running PowerShell 5.1 or later and have the required .NET Framework version installed.

### GUI Doesn't Appear
Check that `System.Windows.Forms` and `System.Drawing` assemblies are available on your system.

### Functions Not Found
Make sure the module is imported: `Import-Module PSMouseJiggler -Force`

### Scheduled Task Conflicts
If you have other modules with scheduled task functions, use the PSMJ-prefixed versions: `Get-PSMJScheduledTasks`, etc.

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file for more details.

## Support

- Report issues on [GitHub Issues](https://github.com/PowerShellYoungTeam/PSMouseJiggler/issues)
- View documentation in [`docs/USAGE.md`](docs/USAGE.md)
- Get help: `Get-Help <CommandName> -Full`

## Acknowledgments

Thanks to the PowerShell community for their support and contributions to the PSMouseJiggler project!

---

**Version**: 2.0.0
**Author**: Steven Wight (PowerShell Young Team)
**Last Updated**: August 2026
