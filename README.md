# PSMouseJiggler

PSMouseJiggler is a PowerShell module designed to simulate mouse movements to prevent your computer from going idle. This project provides both a command-line interface and a graphical user interface (GUI) for ease of use.

![CI](https://github.com/PowerShellYoungTeam/PSMouseJiggler/actions/workflows/ci.yml/badge.svg)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSMouseJiggler)](https://www.powershellgallery.com/packages/PSMouseJiggler)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSMouseJiggler)](https://www.powershellgallery.com/packages/PSMouseJiggler)

## Features

- **Mouse Movement Simulation**: Simulates mouse movements to keep your computer awake.
- **Graphical User Interface**: A user-friendly GUI to start/stop jiggling and configure settings.
- **Custom Movement Patterns**: Choose from various predefined movement patterns for the mouse.
- **Scheduled Jiggling**: Set up automatic jiggling at specified times using scheduled tasks.
- **Configuration Management**: Load and save user preferences for a personalized experience.
- **PowerShell Module**: Properly structured as a PowerShell module for easy installation and management.
- **Testing Framework**: Includes unit tests to ensure core functionalities work as expected.

## Getting Started

### Prerequisites

- PowerShell 5.1 or later
- Windows operating system

### Installation

#### PowerShell Gallery (Recommended)

```powershell
Install-Module -Name PSMouseJiggler -Scope CurrentUser
```

#### Using the installer script
To install PSMouseJiggler, run the following command in PowerShell:

```powershell
.\install.ps1
```

#### Manual installation

1. Copy the `PSMouseJiggler` folder from `src\PSMouseJiggler` to your PowerShell modules directory:
   - Windows PowerShell: `$env:USERPROFILE\Documents\WindowsPowerShell\Modules\`
   - PowerShell Core: `$env:USERPROFILE\Documents\PowerShell\Modules\`

2. Import the module:
```powershell
Import-Module PSMouseJiggler
```

### Usage

#### Command Line Interface
```powershell
# Start the mouse jiggler
Start-PSMouseJiggler

# Stop the mouse jiggler
Stop-PSMouseJiggler

# Show the GUI interface
Show-PSMouseJigglerGUI

# Get help for any command
Get-Help Start-PSMouseJiggler -Full
```

#### Available Commands
- `Start-PSMouseJiggler` - Start mouse jiggling with specified parameters
- `Stop-PSMouseJiggler` - Stop the currently running mouse jiggler
- `Show-PSMouseJigglerGUI` - Launch the graphical user interface
- `Get-PSMouseJigglerConfig` - Get current configuration settings
- `Set-PSMouseJigglerConfig` - Set configuration options
- `New-PSMouseJigglerScheduledTask` - Create a scheduled task for automatic jiggling

For detailed usage instructions, please refer to the [USAGE.md](docs/USAGE.md) file.

## Module Structure

```
src/
└── PSMouseJiggler/
    ├── PSMouseJiggler.psd1      # Module manifest
    ├── PSMouseJiggler.psm1      # Main module file
    ├── config/
    │   └── default.json         # Default configuration
    └── README.md                # Module documentation
tests/
├── PSMouseJiggler.Module.Tests.ps1  # Module tests
├── PSMouseJiggler.Tests.ps1         # Legacy tests
└── Pester.ps1                       # Test runner
docs/
├── CONTRIBUTING.md
└── USAGE.md
```

## Contributing

We welcome contributions! Please read the [CONTRIBUTING.md](docs/CONTRIBUTING.md) file for guidelines on how to contribute to the project.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## CI/CD Pipeline

This project includes a CI/CD pipeline defined in the `.github/workflows` directory. The `ci.yml` file handles continuous integration, while the `release.yml` file manages the deployment process.

## Acknowledgments

Thanks to the community for their support and contributions to the PSMouseJiggler project!
