# PSMouseJiggler Usage Instructions

## Overview
PSMouseJiggler is a PowerShell-based tool designed to simulate mouse movements to prevent your computer from going to sleep or to keep your session active. This document provides instructions on how to install, configure, and use PSMouseJiggler.

## Installation
1. **Download the Repository**: Clone or download the Mouse Jiggler repository from GitHub.
   ```
  git clone https://github.com/yourusername/PSMouseJiggler.git
   ```

2. **Run the Installation Script**: Open PowerShell as an administrator and navigate to the PSMouseJiggler directory. Execute the installation script to set up the necessary dependencies.
   ```
  cd PSMouseJiggler
   .\install.ps1
   ```

## Usage
### Starting PSMouseJiggler
- To start PSMouseJiggler, run the main script:
  ```powershell
  .\src\PSMouseJiggler.ps1
  ```

### Using the GUI
- If you prefer a graphical interface, you can launch the GUI version:
  ```powershell
  .\src\PSMouseJigglerGUI.ps1
  ```
- The GUI allows you to start and stop the jiggling process and configure settings easily.

### Configuration
- Configuration settings can be adjusted in the `config/default.json` file. This includes options such as movement speed and patterns.
- You can also modify settings through the GUI, which will update the configuration file automatically.

### Movement Patterns
- PSMouseJiggler supports various movement patterns defined in the `MovementPatterns.psm1` module. You can select different styles of mouse movement through the GUI or by modifying the configuration file.

### Scheduled Tasks
- To set up automatic jiggling at specified times, use the `ScheduledTasks.psm1` module. This allows you to create scheduled tasks that will run PSMouseJiggler at your desired intervals.

## Stopping PSMouseJiggler
- To stop the jiggling process, you can either close the GUI or terminate the PowerShell script running PSMouseJiggler.

## Troubleshooting
- If you encounter issues, ensure that you have the necessary permissions to run PowerShell scripts. You may need to adjust your execution policy:
  ```
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

## Contribution
For guidelines on contributing to PSMouseJiggler, please refer to the `CONTRIBUTING.md` file in the `docs` directory.

## License
This project is licensed under the terms specified in the `LICENSE` file.