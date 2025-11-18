# PSMouseJiggler - Cross-Platform PowerShell Mouse Jiggler & Keep-Awake Utility

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSMouseJiggler)](https://www.powershellgallery.com/packages/PSMouseJiggler)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/PSMouseJiggler)](https://www.powershellgallery.com/packages/PSMouseJiggler)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)]()
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-blue)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Keep your screen awake across Windows, Linux, and macOS!** PSMouseJiggler prevents your computer from going to sleep by simulating user activity through multiple configurable methods, including mouse movement, keyboard input, and system power management APIs.

---

## ✨ Features

### 🎯 Core Capabilities

- **Cross-Platform Support** - Works on Windows (PowerShell 5.1 or 7+), Linux (PowerShell 7+), and macOS (PowerShell 7+)
- **Multiple Keep-Awake Methods** - Mouse movement (software/hardware), keyboard input, and system APIs
- **Movement Patterns** - Random, Horizontal, Vertical, and Circular mouse movements
- **Incognito Mode** - Keep system awake with zero visible mouse cursor movement
- **Configurable Intervals** - Set custom timing between activities (default: 3 seconds)
- **Duration Control** - Run indefinitely or for a specific time period
- **Scheduled Tasks** - Create automated keep-awake schedules

### 🖥️ User Interfaces

- **Windows Forms GUI** (Windows only) - Modern graphical interface with preset profiles
- **Terminal UI (TUI)** (All platforms) - Cross-platform text-based interface using Microsoft.PowerShell.ConsoleGuiTools
- **Command-Line** (All platforms) - Full CLI control for automation and scripting

### 🌐 Platform-Specific Features

#### Windows
- 4 keep-awake methods: Software Mouse, Hardware Mouse, Keyboard (F15), System API
- Windows Forms GUI with 5 preset profiles
- Windows Task Scheduler integration
- No external dependencies required

#### Linux
- 2 keep-awake methods: Software Mouse (xdotool/ydotool), System API (systemd-inhibit)
- X11 and Wayland support
- systemd timer integration

#### macOS
- 2 keep-awake methods: Software Mouse (cliclick), System API (caffeinate)
- launchd integration
- Accessibility permission support

---

## 📋 Requirements

| Platform | PowerShell | Dependencies |
|----------|-----------|--------------|
| **Windows** | 5.1+ or 7+ | .NET Framework 4.7.2+ (for GUI) |
| **Linux** | 7+ | xdotool or ydotool, systemd-inhibit |
| **macOS** | 7+ | cliclick (Homebrew) |

**Optional Components:**

- **Microsoft.PowerShell.ConsoleGuiTools** (all platforms) - Required for Terminal UI
- **Windows GUI** (Windows only) - Requires .NET Framework 4.7.2+

---

## 🚀 Installation

### From PowerShell Gallery (Recommended)

```powershell
Install-Module -Name PSMouseJiggler -Scope CurrentUser
```

### Install Dependencies

The module includes an automated installer for platform-specific dependencies:

```powershell
# Run the dependency installer
./Install-PSMouseJigglerDependencies.ps1
```

**Manual Installation:**

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install xdotool
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install xdotool
```

**macOS:**
```bash
brew install cliclick
```

**Terminal UI (all platforms):**
```powershell
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
```

### Manual Module Installation

```powershell
# Download from GitHub
git clone https://github.com/PowerShellYoungTeam/PSMouseJiggler.git
cd PSMouseJiggler

# Import the module
Import-Module ./src/PSMouseJiggler/PSMouseJiggler.psd1
```

---

## 🎮 Quick Start

### Launch the GUI (Windows Only)

```powershell
Show-PSMouseJigglerGUI
```

Choose from 5 preset profiles:

1. **[Mouse] Basic Discrete** - Random movements every 1 second (incognito mode)
2. **[Lock] Maximum Security** - Hardware mouse + System API for strict policies
3. **[Key] Keyboard Only** - Keyboard input only, no mouse movement
4. **[API] System API Only** - Direct power management control
5. **[MAX] All Methods** - Maximum reliability using all techniques

### Launch the Terminal UI (All Platforms)

```powershell
Show-PSMouseJigglerTUI
```

Features:

- ✅ Granular keep-awake method selection (checkboxes for each available method)
- ✅ Movement pattern configuration (Random, Horizontal, Vertical, Circular)
- ✅ Incognito mode toggle
- ✅ Platform-aware interface (shows only methods available on your OS)

### Command-Line Usage

**Basic mouse jiggling:**
```powershell
# Start with default settings (random pattern, 3-second interval)
Start-PSMouseJiggler

# Run for specific duration (30 minutes)
Start-PSMouseJiggler -Duration 30

# Custom pattern and interval
Start-PSMouseJiggler -Pattern Circular -Interval 5

# Stop manually
Stop-PSMouseJiggler
```

**Advanced keep-awake with multiple methods:**
```powershell
# Use multiple methods (Windows)
Start-KeepAwake -Methods @('MouseSoftware', 'Keyboard', 'SystemAPI') -Interval 3

# Use incognito mode (no visible cursor movement)
Start-KeepAwake -Methods @('SystemAPI') -Incognito

# Platform-appropriate methods (Linux)
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 60

# Platform-appropriate methods (macOS)
Start-KeepAwake -Methods @('MouseSoftware', 'SystemAPI') -Duration 60

# Stop any running keep-awake
Stop-PSMouseJiggler
```

---

## 📖 Exported Functions

PSMouseJiggler exports **27 functions** for comprehensive control:

### Core Functions

- `Start-PSMouseJiggler` - Start basic mouse jiggling with pattern-based movement
- `Stop-PSMouseJiggler` - Stop the currently running mouse jiggler or keep-awake
- `Start-KeepAwake` - Advanced multi-method keep-awake functionality
- `Show-PSMouseJigglerGUI` - Launch the graphical user interface (Windows only)
- `Show-PSMouseJigglerTUI` - Launch the Terminal UI (all platforms)

### Configuration Functions

- `Get-Configuration` - Get current configuration settings
- `Save-Configuration` - Save configuration to file
- `Update-Configuration` - Update specific configuration values
- `Reset-Configuration` - Reset to default configuration

### Scheduled Task Functions

- `Get-PSMJScheduledTasks` - List PSMouseJiggler scheduled tasks
- `New-PSMJScheduledTask` - Create a new scheduled task
- `Remove-PSMJScheduledTask` - Remove a scheduled task
- `Start-PSMJScheduledTask` - Manually start a scheduled task
- `Stop-PSMJScheduledTask` - Stop a running scheduled task

### Platform Detection Functions

- `Get-OperatingSystemPlatform` - Detect current operating system (Windows/Linux/macOS)
- `Test-PlatformCapability` - Check if a specific capability is available on current platform
- `Test-ExternalToolAvailable` - Check if external tool is installed (xdotool, cliclick, etc.)
- `Show-DependencyInstallInstructions` - Display platform-specific installation instructions

### Advanced Functions

- `Prevent-SystemIdle` - Directly prevent system idle using platform-specific APIs
- `Send-KeyboardInput` - Send keyboard input (F15 key, Windows only)
- `Send-MouseInput` - Send hardware-level mouse input (Windows only)
- `Move-Mouse` - Move mouse cursor to specific coordinates
- `Get-NewMousePosition` - Calculate new mouse position based on pattern
- `Start-MovementPattern` - Start a custom movement pattern
- `Stop-MovementPattern` - Stop custom movement pattern
- `Invoke-MouseMove` - Cross-platform wrapper for mouse movement
- `Invoke-SystemIdlePrevention` - Cross-platform wrapper for system idle prevention

For detailed usage instructions and examples, see [docs/USAGE.md](docs/USAGE.md).

---

## 🌐 Platform Support

See [docs/PLATFORM_SUPPORT.md](docs/PLATFORM_SUPPORT.md) for comprehensive platform details, including:

- Platform capabilities matrix
- Tool version requirements
- Display server support (X11/Wayland on Linux)
- Accessibility permissions (macOS)
- Troubleshooting guides

**Quick Platform Check:**
```powershell
# Check your platform
Get-OperatingSystemPlatform

# Test available capabilities
Test-PlatformCapability -Capability GUI           # Windows only
Test-PlatformCapability -Capability WindowsAPI    # Windows only
Test-PlatformCapability -Capability XDoTool       # Linux (X11)
Test-PlatformCapability -Capability YDoTool       # Linux (Wayland)
Test-PlatformCapability -Capability CliClick      # macOS
Test-PlatformCapability -Capability SystemdInhibit # Linux
Test-PlatformCapability -Capability Caffeinate    # macOS
```

---

## 📁 Module Structure

```
PSMouseJiggler/
├── src/
│   └── PSMouseJiggler/
│       ├── PSMouseJiggler.psd1      # Module manifest (v2.0.0)
│       ├── PSMouseJiggler.psm1      # Main module (3577 lines, cross-platform)
│       ├── config/
│       │   └── default.json         # Default configuration
│       └── README.md                # Module documentation
├── tests/
│   └── PSMouseJiggler.Tests.ps1     # Pester tests (platform-specific)
├── docs/
│   ├── CONTRIBUTING.md              # Contribution guidelines
│   ├── USAGE.md                     # Detailed usage guide
│   ├── PLATFORM_SUPPORT.md          # Platform capabilities matrix
│   └── MANUAL_TESTING.md            # Manual testing procedures
├── .github/
│   └── workflows/
│       ├── ci.yml                   # Continuous integration
│       ├── test.yml                 # Multi-OS automated testing
│       └── publish.yml              # Publishing workflow
├── Install-PSMouseJigglerDependencies.ps1  # Dependency installer
├── QuickStart.ps1                   # Quick start demo script
├── Validate.ps1                     # Validation script
└── README.md                        # This file
```

---

## 💡 Use Cases

- **Presentations** - Keep your screen active during long presentations
- **Remote Work** - Maintain active status in communication apps (Teams, Slack, etc.)
- **Long Downloads** - Prevent sleep during large file transfers
- **Video Rendering** - Keep system awake during lengthy rendering processes
- **Monitoring** - Maintain visibility of monitoring dashboards
- **Testing** - Prevent idle during automated test runs
- **SSH Sessions** - Keep remote sessions active on Linux servers
- **macOS Development** - Prevent sleep during builds and deployments

---

## 🧪 Testing

### Automated Tests

The module includes a comprehensive Pester test suite with platform-specific tests:

```powershell
# Run all tests
Invoke-Pester ./tests/PSMouseJiggler.Tests.ps1

# Run platform-specific tests
Invoke-Pester ./tests/PSMouseJiggler.Tests.ps1 -Tag Windows
Invoke-Pester ./tests/PSMouseJiggler.Tests.ps1 -Tag Linux
Invoke-Pester ./tests/PSMouseJiggler.Tests.ps1 -Tag MacOS

# Run unit tests only
Invoke-Pester ./tests/PSMouseJiggler.Tests.ps1 -Tag Unit

# Run integration tests
Invoke-Pester ./tests/PSMouseJiggler.Tests.ps1 -Tag Integration
```

### Manual Testing

See [docs/MANUAL_TESTING.md](docs/MANUAL_TESTING.md) for comprehensive manual testing procedures, including:

- Platform-specific test suites (Windows, Linux, macOS)
- GUI and TUI functional testing
- Troubleshooting guides
- Test completion checklists

### CI/CD

GitHub Actions workflows test the module on all three platforms:

- **Windows**: windows-latest (Windows PowerShell 5.1 + PowerShell 7)
- **Linux**: ubuntu-latest (PowerShell 7, xdotool)
- **macOS**: macos-latest (PowerShell 7, cliclick)

---

## 🤝 Contributing

We welcome contributions! Please read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for:

- Development guidelines
- Code style conventions
- Testing requirements
- Pull request process

**Quick Start for Contributors:**

```powershell
# Clone the repository
git clone https://github.com/PowerShellYoungTeam/PSMouseJiggler.git
cd PSMouseJiggler

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes
# Run tests
Invoke-Pester ./tests/PSMouseJiggler.Tests.ps1

# Submit a pull request
```

---

## 🐛 Troubleshooting

### Windows

| Issue | Solution |
|-------|----------|
| GUI doesn't launch | Install .NET Framework 4.7.2+ |
| "Unapproved verb" warning | Safe to ignore (Prevent-SystemIdle uses non-standard verb) |
| Scheduled task fails | Run PowerShell as Administrator |
| Mouse not moving | Check if antivirus blocks input simulation |

### Linux

| Issue | Solution |
|-------|----------|
| "xdotool not found" | Install: `sudo apt install xdotool` |
| Mouse doesn't move (Wayland) | Install ydotool, may need sudo |
| systemd-inhibit not found | Ensure systemd is installed |
| Permission denied (ydotool) | Run with sudo or add user to input group |

### macOS

| Issue | Solution |
|-------|----------|
| "cliclick not found" | Install: `brew install cliclick` |
| Mouse doesn't move | Grant Accessibility permissions in System Preferences |
| caffeinate not working | Built-in on macOS 11+, check OS version |

### All Platforms

| Issue | Solution |
|-------|----------|
| TUI doesn't launch | Install: `Install-Module Microsoft.PowerShell.ConsoleGuiTools` |
| Module import fails | Check PowerShell version (5.1+ Windows, 7+ Linux/macOS) |
| Function not found | Verify module loaded: `Get-Module PSMouseJiggler` |
| Configuration not saving | Check file permissions in module config directory |

For detailed troubleshooting, see [docs/PLATFORM_SUPPORT.md](docs/PLATFORM_SUPPORT.md).

---

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- **Documentation**: [docs/USAGE.md](docs/USAGE.md) | [docs/PLATFORM_SUPPORT.md](docs/PLATFORM_SUPPORT.md)
- **Issues**: [GitHub Issues](https://github.com/PowerShellYoungTeam/PSMouseJiggler/issues)
- **Discussions**: [GitHub Discussions](https://github.com/PowerShellYoungTeam/PSMouseJiggler/discussions)
- **Pull Requests**: Contributions welcome!

**Get Command Help:**
```powershell
Get-Help Start-PSMouseJiggler -Detailed
Get-Help Show-PSMouseJigglerTUI -Examples
Get-Help Start-KeepAwake -Full
```

---

## 🎉 Acknowledgments

- **Terminal.Gui** - Cross-platform terminal UI framework
- **Microsoft.PowerShell.ConsoleGuiTools** - PowerShell wrapper for Terminal.Gui
- **xdotool** / **ydotool** - Linux X11/Wayland automation
- **cliclick** - macOS CLI mouse control
- PowerShell Community for cross-platform support

---

**Version**: 2.0.0
**Release Date**: November 2025
**Supported Platforms**: Windows 10/11, Linux (Ubuntu 20.04+, Fedora 36+, Debian 11+, Arch, openSUSE), macOS 11+
