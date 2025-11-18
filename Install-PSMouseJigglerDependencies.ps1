<#
.SYNOPSIS
    Installs external dependencies required for PSMouseJiggler cross-platform support.

.DESCRIPTION
    This script automatically detects the operating system and package manager,
    then installs the required external tools for PSMouseJiggler:

    - Linux: xdotool (X11) or ydotool (Wayland), systemd-inhibit
    - macOS: cliclick via Homebrew

    Windows does not require any external dependencies.

.PARAMETER SkipSystemdInhibit
    On Linux, skip installing systemd-inhibit (usually pre-installed with systemd).

.PARAMETER PreferYDoTool
    On Linux, prefer ydotool over xdotool for Wayland compatibility.

.PARAMETER Force
    Force reinstallation even if tools are already installed.

.EXAMPLE
    .\Install-PSMouseJigglerDependencies.ps1
    Automatically detects platform and installs required dependencies.

.EXAMPLE
    .\Install-PSMouseJigglerDependencies.ps1 -PreferYDoTool
    On Linux, installs ydotool instead of xdotool.

.EXAMPLE
    .\Install-PSMouseJigglerDependencies.ps1 -Force
    Reinstalls dependencies even if already present.

.NOTES
    Requires elevated privileges (sudo on Linux/macOS, Run as Administrator on Windows).
    Windows users do not need to run this script.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [switch]$SkipSystemdInhibit,

    [Parameter()]
    [switch]$PreferYDoTool,

    [Parameter()]
    [switch]$Force
)

#region Helper Functions

function Get-OperatingSystemPlatform {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsWindows) { return 'Windows' }
        if ($IsLinux) { return 'Linux' }
        if ($IsMacOS) { return 'macOS' }
    }
    else {
        # PowerShell 5.1 - assume Windows
        return 'Windows'
    }
    return 'Unknown'
}

function Test-CommandAvailable {
    param([string]$CommandName)
    $null -ne (Get-Command $CommandName -ErrorAction SilentlyContinue)
}

function Get-LinuxPackageManager {
    $packageManagers = @{
        'apt-get' = 'Debian/Ubuntu'
        'dnf'     = 'Fedora/RHEL 8+'
        'yum'     = 'RHEL/CentOS 7'
        'pacman'  = 'Arch Linux'
        'zypper'  = 'openSUSE'
    }

    foreach ($pm in $packageManagers.Keys) {
        if (Test-CommandAvailable $pm) {
            return @{
                Command     = $pm
                Description = $packageManagers[$pm]
            }
        }
    }
    return $null
}

function Test-IsElevated {
    $platform = Get-OperatingSystemPlatform

    if ($platform -eq 'Windows') {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    else {
        # Linux/macOS: Check if running as root or can use sudo
        $canSudo = (& bash -c 'command -v sudo' 2>&1) -and ($env:USER -ne 'root')
        return ($env:USER -eq 'root') -or $canSudo
    }
}

function Install-LinuxDependencies {
    param(
        [bool]$SkipSystemd,
        [bool]$PreferYDoTool,
        [bool]$ForceInstall
    )

    Write-Host "`n=== Installing Linux Dependencies ===" -ForegroundColor Cyan

    $packageManager = Get-LinuxPackageManager
    if (-not $packageManager) {
        Write-Error "Could not detect a supported package manager. Please install dependencies manually."
        return $false
    }

    Write-Host "Detected package manager: $($packageManager.Description) ($($packageManager.Command))" -ForegroundColor Green

    # Determine which mouse control tool to install
    $mouseToolInstalled = $false

    if ($PreferYDoTool) {
        Write-Host "`nInstalling ydotool (Wayland support)..." -ForegroundColor Yellow
        $ydotoolPackage = switch ($packageManager.Command) {
            'apt-get' { 'ydotool' }
            'dnf' { 'ydotool' }
            'pacman' { 'ydotool' }
            'zypper' { 'ydotool' }
            default { 'ydotool' }
        }

        if ($ForceInstall -or -not (Test-CommandAvailable 'ydotool')) {
            if ($PSCmdlet.ShouldProcess("ydotool", "Install")) {
                $installCmd = switch ($packageManager.Command) {
                    'apt-get' { "sudo apt-get update && sudo apt-get install -y $ydotoolPackage" }
                    'dnf' { "sudo dnf install -y $ydotoolPackage" }
                    'yum' { "sudo yum install -y $ydotoolPackage" }
                    'pacman' { "sudo pacman -S --noconfirm $ydotoolPackage" }
                    'zypper' { "sudo zypper install -y $ydotoolPackage" }
                }

                Write-Verbose "Executing: $installCmd"
                Invoke-Expression $installCmd

                if (Test-CommandAvailable 'ydotool') {
                    Write-Host "✓ ydotool installed successfully" -ForegroundColor Green
                    $mouseToolInstalled = $true
                }
                else {
                    Write-Warning "ydotool installation may have failed. Falling back to xdotool..."
                }
            }
        }
        else {
            Write-Host "✓ ydotool already installed" -ForegroundColor Green
            $mouseToolInstalled = $true
        }
    }

    # Install xdotool if ydotool not installed or not preferred
    if (-not $mouseToolInstalled) {
        Write-Host "`nInstalling xdotool (X11 support)..." -ForegroundColor Yellow

        if ($ForceInstall -or -not (Test-CommandAvailable 'xdotool')) {
            if ($PSCmdlet.ShouldProcess("xdotool", "Install")) {
                $installCmd = switch ($packageManager.Command) {
                    'apt-get' { "sudo apt-get update && sudo apt-get install -y xdotool" }
                    'dnf' { "sudo dnf install -y xdotool" }
                    'yum' { "sudo yum install -y xdotool" }
                    'pacman' { "sudo pacman -S --noconfirm xdotool" }
                    'zypper' { "sudo zypper install -y xdotool" }
                }

                Write-Verbose "Executing: $installCmd"
                Invoke-Expression $installCmd

                if (Test-CommandAvailable 'xdotool') {
                    Write-Host "✓ xdotool installed successfully" -ForegroundColor Green
                }
                else {
                    Write-Error "Failed to install xdotool"
                    return $false
                }
            }
        }
        else {
            Write-Host "✓ xdotool already installed" -ForegroundColor Green
        }
    }

    # Check for systemd-inhibit (usually pre-installed)
    if (-not $SkipSystemd) {
        Write-Host "`nChecking systemd-inhibit..." -ForegroundColor Yellow

        if (Test-CommandAvailable 'systemd-inhibit') {
            Write-Host "✓ systemd-inhibit available" -ForegroundColor Green
        }
        else {
            Write-Warning "systemd-inhibit not found. It's usually included with systemd."
            Write-Host "Installing systemd package..." -ForegroundColor Yellow

            if ($PSCmdlet.ShouldProcess("systemd", "Install")) {
                $installCmd = switch ($packageManager.Command) {
                    'apt-get' { "sudo apt-get install -y systemd" }
                    'dnf' { "sudo dnf install -y systemd" }
                    'yum' { "sudo yum install -y systemd" }
                    'pacman' { "sudo pacman -S --noconfirm systemd" }
                    'zypper' { "sudo zypper install -y systemd" }
                }

                Write-Verbose "Executing: $installCmd"
                Invoke-Expression $installCmd

                if (Test-CommandAvailable 'systemd-inhibit') {
                    Write-Host "✓ systemd-inhibit installed successfully" -ForegroundColor Green
                }
                else {
                    Write-Warning "systemd-inhibit still not available. SystemAPI method may not work."
                }
            }
        }
    }

    return $true
}

function Install-MacOSDependencies {
    param([bool]$ForceInstall)

    Write-Host "`n=== Installing macOS Dependencies ===" -ForegroundColor Cyan

    # Check for Homebrew
    if (-not (Test-CommandAvailable 'brew')) {
        Write-Error "Homebrew is not installed. Please install Homebrew first:"
        Write-Host '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' -ForegroundColor Yellow
        return $false
    }

    Write-Host "✓ Homebrew detected" -ForegroundColor Green

    # Install cliclick
    Write-Host "`nInstalling cliclick..." -ForegroundColor Yellow

    if ($ForceInstall -or -not (Test-CommandAvailable 'cliclick')) {
        if ($PSCmdlet.ShouldProcess("cliclick", "Install via Homebrew")) {
            & brew install cliclick

            if (Test-CommandAvailable 'cliclick') {
                Write-Host "✓ cliclick installed successfully" -ForegroundColor Green
            }
            else {
                Write-Error "Failed to install cliclick"
                return $false
            }
        }
    }
    else {
        Write-Host "✓ cliclick already installed" -ForegroundColor Green

        # Optionally upgrade
        if ($ForceInstall) {
            Write-Host "Upgrading cliclick..." -ForegroundColor Yellow
            & brew upgrade cliclick 2>&1 | Out-Null
        }
    }

    # Check for caffeinate (built-in to macOS)
    Write-Host "`nChecking caffeinate..." -ForegroundColor Yellow
    if (Test-CommandAvailable 'caffeinate') {
        Write-Host "✓ caffeinate available (built-in)" -ForegroundColor Green
    }
    else {
        Write-Warning "caffeinate not found. This is unusual as it should be built into macOS."
    }

    return $true
}

#endregion

#region Main Script

Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   PSMouseJiggler Dependency Installer                    ║
║   Version 2.0.0                                           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# Detect platform
$platform = Get-OperatingSystemPlatform
Write-Host "Detected platform: $platform" -ForegroundColor Green

# Check if Windows (no dependencies needed)
if ($platform -eq 'Windows') {
    Write-Host "`nWindows does not require external dependencies for PSMouseJiggler." -ForegroundColor Green
    Write-Host "The module uses native Windows APIs (System.Windows.Forms)." -ForegroundColor Gray
    Write-Host "`nYou can start using PSMouseJiggler immediately:" -ForegroundColor Yellow
    Write-Host "  Import-Module PSMouseJiggler" -ForegroundColor White
    Write-Host "  Start-PSMouseJiggler" -ForegroundColor White
    exit 0
}

# Check for elevation
if (-not (Test-IsElevated)) {
    Write-Warning "This script requires elevated privileges."
    Write-Host "`nPlease run with sudo:" -ForegroundColor Yellow
    Write-Host "  sudo pwsh -File '$PSCommandPath'" -ForegroundColor White
    exit 1
}

# Install dependencies based on platform
$success = $false

switch ($platform) {
    'Linux' {
        $success = Install-LinuxDependencies -SkipSystemd:$SkipSystemdInhibit -PreferYDoTool:$PreferYDoTool -ForceInstall:$Force
    }
    'macOS' {
        $success = Install-MacOSDependencies -ForceInstall:$Force
    }
    default {
        Write-Error "Unsupported platform: $platform"
        exit 1
    }
}

# Summary
Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan

if ($success) {
    Write-Host "`n✓ All dependencies installed successfully!" -ForegroundColor Green
    Write-Host "`nYou can now use PSMouseJiggler:" -ForegroundColor Yellow
    Write-Host "  Import-Module PSMouseJiggler" -ForegroundColor White
    Write-Host "  Start-PSMouseJiggler" -ForegroundColor White
    Write-Host "`nFor platform-specific information, run:" -ForegroundColor Yellow
    Write-Host "  Get-Help Start-PSMouseJiggler -Full" -ForegroundColor White
    exit 0
}
else {
    Write-Error "`nDependency installation failed. Please check the errors above."
    Write-Host "`nFor manual installation instructions, visit:" -ForegroundColor Yellow
    Write-Host "  https://github.com/PowerShellYoungTeam/PSMouseJiggler" -ForegroundColor White
    exit 1
}

#endregion
