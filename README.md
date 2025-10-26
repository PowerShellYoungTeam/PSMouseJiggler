# PSMouseJiggler

PSMouseJiggler is a PowerShell module designed to simulate mouse movements to prevent your computer from going idle. This project provides both a command-line interface and a graphical user interface (GUI) for ease of use.

![CI](https://github.com/PowerShellYoungTeam/PSMouseJiggler/actions/workflows/ci.yml/badge.svg)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSMouseJiggler)](https://www.powershellgallery.com/packages/PSMouseJiggler)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSMouseJiggler)](https://www.powershellgallery.com/packages/PSMouseJiggler)

## Features

- **Mouse Movement Simulation**: Simulates mouse movements to keep your computer awake
- **Advanced Keep-Awake Methods**: Multiple techniques including hardware input, keyboard, and System API
- **Graphical User Interface**: Modern tabbed GUI with Basic, Advanced, and Quick Launch modes
- **Quick Launch Profiles**: Pre-configured profiles for common scenarios with one-click start
- **Custom Movement Patterns**: Choose from Random, Horizontal, Vertical, or Circular patterns
- **Incognito Mode**: Minimizes GUI and clears console for discreet operation
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
- **Advanced Mode**: Combine multiple keep-awake methods for maximum effectiveness
- **Quick Launch**: One-click pre-configured profiles for common scenarios

#### Command Line Usage

```powershell
# Basic mouse jiggling
Start-PSMouseJiggler

# With custom settings
Start-PSMouseJiggler -Interval 2000 -MovementPattern Circular -Duration 3600

# Incognito mode (discrete operation)
Start-PSMouseJiggler -Incognito

# Advanced keep-awake with multiple methods
Start-KeepAwake -Methods @('MouseHardware', 'Keyboard', 'SystemAPI') -Interval 30000

# Stop jiggling
Stop-PSMouseJiggler
```

### Available Commands

#### Core Functions
- `Start-PSMouseJiggler` - Start basic mouse jiggling with pattern-based movement
- `Stop-PSMouseJiggler` - Stop the currently running mouse jiggler or keep-awake
- `Start-KeepAwake` - Advanced multi-method keep-awake functionality
- `Show-PSMouseJigglerGUI` - Launch the graphical user interface

#### Configuration Functions
- `Get-Configuration` - Get current configuration settings
- `Save-Configuration` - Save configuration to file
- `Update-Configuration` - Update specific configuration values
- `Reset-Configuration` - Reset to default configuration

#### Scheduled Task Functions (with PSMJ prefix to avoid conflicts)
- `Get-PSMJScheduledTasks` - List PSMouseJiggler scheduled tasks
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
2. **[Lock] Maximum Security** - Hardware mouse + System API for strict security policies
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

- **Presentations**: Keep your screen active during long presentations
- **Remote Work**: Maintain active status in communication apps
- **Long Downloads**: Prevent sleep during large file transfers
- **Video Rendering**: Keep system awake during lengthy rendering processes
- **Monitoring**: Maintain visibility of monitoring dashboards
- **Testing**: Prevent idle during automated test runs

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

**Version**: 1.1.0
**Author**: Steven Wight (PowerShell Young Team)
**Last Updated**: October 2025
