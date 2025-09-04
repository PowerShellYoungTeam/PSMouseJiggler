# PSMouseJiggler

PSMouseJiggler is a PowerShell-based utility designed to simulate mouse movements to prevent your computer from going idle. This project provides both a command-line interface and a graphical user interface (GUI) for ease of use.

## Features

- **Mouse Movement Simulation**: Simulates mouse movements to keep your computer awake.
- **Graphical User Interface**: A user-friendly GUI to start/stop jiggling and configure settings.
- **Custom Movement Patterns**: Choose from various predefined movement patterns for the mouse.
- **Scheduled Jiggling**: Set up automatic jiggling at specified times using scheduled tasks.
- **Configuration Management**: Load and save user preferences for a personalized experience.
- **Testing Framework**: Includes unit tests to ensure core functionalities work as expected.

## Getting Started

### Prerequisites

- PowerShell 5.1 or later
- Windows operating system

### Installation

To install PSMouseJiggler, run the following command in PowerShell:

```powershell
.\install.ps1
```

### Usage

For detailed usage instructions, please refer to the [USAGE.md](docs/USAGE.md) file.

## Contributing

We welcome contributions! Please read the [CONTRIBUTING.md](docs/CONTRIBUTING.md) file for guidelines on how to contribute to the project.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## CI/CD Pipeline

This project includes a CI/CD pipeline defined in the `.github/workflows` directory. The `ci.yml` file handles continuous integration, while the `release.yml` file manages the deployment process.

## Acknowledgments

Thanks to the community for their support and contributions to the PSMouseJiggler project!