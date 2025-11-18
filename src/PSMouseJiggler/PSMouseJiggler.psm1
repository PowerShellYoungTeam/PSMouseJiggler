#
# PSMouseJiggler Module
# A PowerShell module to simulate mouse movements and prevent system idle
# Version 2.0.0 - Cross-Platform Support
#

#region Platform Detection and Compatibility

<#
.SYNOPSIS
    Detects the current operating system platform.

.DESCRIPTION
    Returns 'Windows', 'Linux', or 'macOS' based on the current PowerShell environment.

.OUTPUTS
    String - The platform name ('Windows', 'Linux', or 'macOS')
#>
function Get-OperatingSystemPlatform {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    # PowerShell 6+ has built-in platform detection variables
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsWindows) { return 'Windows' }
        if ($IsLinux) { return 'Linux' }
        if ($IsMacOS) { return 'macOS' }
    }

    # PowerShell 5.1 is Windows-only
    return 'Windows'
}

<#
.SYNOPSIS
    Tests if a specific platform capability is available.

.DESCRIPTION
    Checks if the current platform supports specific features like GUI, P/Invoke, etc.

.PARAMETER Capability
    The capability to test: 'GUI', 'WindowsAPI', 'SystemdInhibit', 'Caffeinate', etc.

.OUTPUTS
    Boolean - True if the capability is available
#>
function Test-PlatformCapability {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('GUI', 'WindowsAPI', 'XDoTool', 'YDoTool', 'CliClick', 'SystemdInhibit', 'Caffeinate', 'ScheduledTasks', 'LaunchD', 'SystemdTimers')]
        [string]$Capability
    )

    $platform = Get-OperatingSystemPlatform

    switch ($Capability) {
        'GUI' {
            return ($platform -eq 'Windows')
        }
        'WindowsAPI' {
            return ($platform -eq 'Windows')
        }
        'XDoTool' {
            return ($platform -eq 'Linux') -and (Test-ExternalToolAvailable -ToolName 'xdotool')
        }
        'YDoTool' {
            return ($platform -eq 'Linux') -and (Test-ExternalToolAvailable -ToolName 'ydotool')
        }
        'CliClick' {
            return ($platform -eq 'macOS') -and (Test-ExternalToolAvailable -ToolName 'cliclick')
        }
        'SystemdInhibit' {
            return ($platform -eq 'Linux') -and (Test-ExternalToolAvailable -ToolName 'systemd-inhibit')
        }
        'Caffeinate' {
            return ($platform -eq 'macOS') -and (Test-ExternalToolAvailable -ToolName 'caffeinate')
        }
        'ScheduledTasks' {
            return ($platform -eq 'Windows')
        }
        'LaunchD' {
            return ($platform -eq 'macOS')
        }
        'SystemdTimers' {
            return ($platform -eq 'Linux') -and (Test-ExternalToolAvailable -ToolName 'systemctl')
        }
    }

    return $false
}

<#
.SYNOPSIS
    Tests if an external tool is available on the system.

.DESCRIPTION
    Checks if a command-line tool is installed and accessible in the PATH.

.PARAMETER ToolName
    The name of the tool to check (e.g., 'xdotool', 'cliclick', 'systemd-inhibit')

.OUTPUTS
    Boolean - True if the tool is available
#>
function Test-ExternalToolAvailable {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$ToolName
    )

    try {
        $null = Get-Command $ToolName -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

<#
.SYNOPSIS
    Displays installation instructions for missing dependencies.

.DESCRIPTION
    Provides clear guidance on how to install required tools for the current platform.

.PARAMETER MissingTools
    Array of missing tool names
#>
function Show-DependencyInstallInstructions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$MissingTools
    )

    $platform = Get-OperatingSystemPlatform

    Write-Host "`nMissing required dependencies: $($MissingTools -join ', ')" -ForegroundColor Yellow
    Write-Host "`nTo install these tools, you can:" -ForegroundColor Cyan

    switch ($platform) {
        'Linux' {
            Write-Host "`n1. Run the automated installer:" -ForegroundColor Green
            Write-Host "   & (Join-Path `$PSScriptRoot 'Install-PSMouseJigglerDependencies.ps1')" -ForegroundColor White
            Write-Host "`n2. Or install manually:" -ForegroundColor Green
            foreach ($tool in $MissingTools) {
                switch ($tool) {
                    'xdotool' {
                        Write-Host "   Ubuntu/Debian: sudo apt-get install xdotool" -ForegroundColor White
                        Write-Host "   Fedora/RHEL:   sudo dnf install xdotool" -ForegroundColor White
                        Write-Host "   Arch:          sudo pacman -S xdotool" -ForegroundColor White
                    }
                    'ydotool' {
                        Write-Host "   ydotool (Wayland support - optional):" -ForegroundColor White
                        Write-Host "   Follow instructions at: https://github.com/ReimuNotMoe/ydotool" -ForegroundColor White
                    }
                    'systemd-inhibit' {
                        Write-Host "   systemd-inhibit: Usually pre-installed with systemd" -ForegroundColor White
                    }
                }
            }
        }
        'macOS' {
            Write-Host "`n1. Run the automated installer:" -ForegroundColor Green
            Write-Host "   & (Join-Path `$PSScriptRoot 'Install-PSMouseJigglerDependencies.ps1')" -ForegroundColor White
            Write-Host "`n2. Or install manually via Homebrew:" -ForegroundColor Green
            foreach ($tool in $MissingTools) {
                switch ($tool) {
                    'cliclick' {
                        Write-Host "   brew install cliclick" -ForegroundColor White
                    }
                    'caffeinate' {
                        Write-Host "   caffeinate: Built into macOS (should already be available)" -ForegroundColor White
                    }
                }
            }
            Write-Host "`nNote: You may need to grant accessibility permissions in System Preferences > Security & Privacy > Privacy > Accessibility" -ForegroundColor Yellow
        }
    }

    Write-Host "`nFor more information, see: https://github.com/PowerShellYoungTeam/PSMouseJiggler/blob/main/docs/PLATFORM_SUPPORT.md" -ForegroundColor Cyan
}

#endregion

#region Assembly Loading

# Conditionally load Windows-specific assemblies
$platform = Get-OperatingSystemPlatform
if ($platform -eq 'Windows') {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        Write-Verbose "Loaded Windows Forms and Drawing assemblies"
    }
    catch {
        Write-Warning "Failed to load Windows Forms assemblies: $($_.Exception.Message)"
    }
}
else {
    Write-Verbose "Non-Windows platform detected. Windows Forms GUI will not be available. Use Show-PSMouseJigglerTUI instead."
}

#endregion

# Global variable to track jiggling state
$script:JigglingJob = $null
$script:JigglingActive = $false

#region Platform-Specific Implementations

#region Windows-Specific Functions

<#
.SYNOPSIS
    Starts the PSMouseJiggler on Windows using Windows Forms API.

.DESCRIPTION
    Windows-specific implementation using System.Windows.Forms for mouse control.
    This is the original implementation moved to a platform-specific function.

.PARAMETER Interval
    Time in milliseconds between mouse movements.

.PARAMETER MovementPattern
    The pattern for mouse movement.

.PARAMETER Duration
    Duration in seconds to run the jiggler.

.PARAMETER Incognito
    When enabled, clears the console after starting.
#>
function Start-PSMouseJiggler-Windows {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$Interval = 1000,

        [Parameter()]
        [ValidateSet('Random', 'Horizontal', 'Vertical', 'Circular')]
        [string]$MovementPattern = 'Random',

        [Parameter()]
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
    )

    if ($script:JigglingActive) {
        Write-Warning "PSMouseJiggler is already running. Use Stop-PSMouseJiggler to stop it first."
        return
    }

    Write-Host "Starting PSMouseJiggler (Windows) with $MovementPattern pattern, interval: $Interval ms" -ForegroundColor Green

    $script:JigglingActive = $true
    $startTime = Get-Date

    $script:JigglingJob = Start-Job -ScriptBlock {
        param($Interval, $MovementPattern, $Duration, $StartTime)

        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $endTime = if ($Duration -gt 0) { $StartTime.AddSeconds($Duration) } else { [DateTime]::MaxValue }

        while ((Get-Date) -lt $endTime) {
            $currentPos = [System.Windows.Forms.Cursor]::Position

            # Determine movement pattern
            switch ($MovementPattern) {
                'Random' {
                    $xOffset = Get-Random -Minimum -10 -Maximum 11
                    $yOffset = Get-Random -Minimum -10 -Maximum 11
                }
                'Horizontal' {
                    $xOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
                    $yOffset = 0
                }
                'Vertical' {
                    $xOffset = 0
                    $yOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
                }
                'Circular' {
                    $angle = (Get-Date).Millisecond / 1000 * 2 * [Math]::PI
                    $xOffset = [Math]::Round([Math]::Sin($angle) * 10)
                    $yOffset = [Math]::Round([Math]::Cos($angle) * 10)
                }
                default {
                    $xOffset = Get-Random -Minimum -5 -Maximum 6
                    $yOffset = Get-Random -Minimum -5 -Maximum 6
                }
            }

            # Move the mouse
            $newPos = New-Object System.Drawing.Point($currentPos.X + $xOffset, $currentPos.Y + $yOffset)
            [System.Windows.Forms.Cursor]::Position = $newPos

            # Wait for the specified interval
            Start-Sleep -Milliseconds $Interval
        }
    } -ArgumentList $Interval, $MovementPattern, $Duration, $startTime

    if ($Duration -gt 0) {
        Write-Host "PSMouseJiggler will run for $Duration seconds" -ForegroundColor Yellow
    }
    else {
        Write-Host "PSMouseJiggler is running indefinitely. Use Stop-PSMouseJiggler to stop." -ForegroundColor Yellow
    }

    # Clear console if incognito mode is enabled
    if ($Incognito) {
        Clear-Host
    }
}

<#
.SYNOPSIS
    Stops the PSMouseJiggler on Windows.

.DESCRIPTION
    Windows-specific implementation for stopping the jiggler.
#>
function Stop-PSMouseJiggler-Windows {
    [CmdletBinding()]
    param()

    if (-not $script:JigglingActive) {
        Write-Warning "PSMouseJiggler is not currently running."
        return
    }

    if ($script:JigglingJob) {
        # Add type checking to handle both real jobs and mock objects used in testing
        if ($script:JigglingJob -is [System.Management.Automation.Job]) {
            Stop-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
            Remove-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
        }
        else {
            Write-Verbose "Stopping non-Job object (likely a test mock)"
        }
        $script:JigglingJob = $null
    }

    $script:JigglingActive = $false
    Write-Host "PSMouseJiggler stopped." -ForegroundColor Green
}

<#
.SYNOPSIS
    Moves the mouse cursor on Windows.

.DESCRIPTION
    Windows-specific implementation using System.Windows.Forms.Cursor.

.PARAMETER X
    Horizontal offset in pixels.

.PARAMETER Y
    Vertical offset in pixels.
#>
function Move-Mouse-Windows {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$X,

        [Parameter(Mandatory)]
        [int]$Y
    )

    $currentPos = [System.Windows.Forms.Cursor]::Position
    $newPos = [System.Drawing.Point]::new($currentPos.X + $X, $currentPos.Y + $Y)
    [System.Windows.Forms.Cursor]::Position = $newPos
}

<#
.SYNOPSIS
    Starts keep-awake functionality on Windows.

.DESCRIPTION
    Windows-specific implementation using P/Invoke and Windows APIs.

.PARAMETER Methods
    Array of methods to use for keeping system awake.

.PARAMETER Interval
    Time in milliseconds between keep-awake actions.

.PARAMETER Duration
    Duration in seconds to run keep-awake.

.PARAMETER Incognito
    When enabled, clears the console after starting.
#>
function Start-KeepAwake-Windows {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI', 'All')]
        [string[]]$Methods = @('All'),

        [Parameter()]
        [int]$Interval = 30000,

        [Parameter()]
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
    )

    if ($script:JigglingActive) {
        Write-Warning "PSMouseJiggler is already running. Use Stop-PSMouseJiggler to stop it first."
        return
    }

    Write-Host "Starting PSMouseJiggler KeepAwake (Windows) with multiple methods, interval: $Interval ms" -ForegroundColor Green

    $script:JigglingActive = $true
    $startTime = Get-Date

    # If 'All' is specified, use all methods
    if ($Methods -contains 'All') {
        $Methods = @('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI')
    }

    # Start the prevention immediately using the API
    if ($Methods -contains 'SystemAPI') {
        Prevent-SystemIdle
    }

    $script:JigglingJob = Start-Job -ScriptBlock {
        param($Interval, $Methods, $Duration, $StartTime)

        # Import required assemblies
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        # Define required P/Invoke structures and methods
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;

        public static class DisplayState {
            [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
            public static extern uint SetThreadExecutionState(uint esFlags);

            public const uint ES_CONTINUOUS = 0x80000000;
            public const uint ES_SYSTEM_REQUIRED = 0x00000001;
            public const uint ES_DISPLAY_REQUIRED = 0x00000002;
        }

        public static class MouseSimulator {
            [StructLayout(LayoutKind.Sequential)]
            public struct MOUSEINPUT {
                public int dx;
                public int dy;
                public uint mouseData;
                public uint dwFlags;
                public uint time;
                public IntPtr dwExtraInfo;
            }

            [StructLayout(LayoutKind.Sequential)]
            public struct INPUT {
                public uint type;
                public MOUSEINPUT mi;
            }

            [DllImport("user32.dll", SetLastError = true)]
            public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

            public const int INPUT_MOUSE = 0;
            public const int MOUSEEVENTF_MOVE = 0x0001;
        }
"@

        $endTime = if ($Duration -gt 0) { $StartTime.AddSeconds($Duration) } else { [DateTime]::MaxValue }

        while ((Get-Date) -lt $endTime) {
            # Randomly select a method from the provided methods
            $method = $Methods | Get-Random

            switch ($method) {
                'MouseSoftware' {
                    # Move mouse using software method
                    $currentPos = [System.Windows.Forms.Cursor]::Position
                    $xOffset = Get-Random -Minimum -10 -Maximum 11
                    $yOffset = Get-Random -Minimum -10 -Maximum 11
                    $newPos = [System.Drawing.Point]::new($currentPos.X + $xOffset, $currentPos.Y + $yOffset)
                    [System.Windows.Forms.Cursor]::Position = $newPos

                    # Move back to original position after a short delay to minimize disruption
                    Start-Sleep -Milliseconds 100
                    [System.Windows.Forms.Cursor]::Position = $currentPos
                }
                'MouseHardware' {
                    # Use hardware-level mouse movement
                    $mouseInputStructure = New-Object MouseSimulator+INPUT
                    $mouseInputStructure.type = [MouseSimulator]::INPUT_MOUSE
                    $mouseInputStructure.mi.dx = Get-Random -Minimum -5 -Maximum 6
                    $mouseInputStructure.mi.dy = Get-Random -Minimum -5 -Maximum 6
                    $mouseInputStructure.mi.dwFlags = [MouseSimulator]::MOUSEEVENTF_MOVE
                    $mouseInputStructure.mi.time = 0
                    $mouseInputStructure.mi.dwExtraInfo = [IntPtr]::Zero

                    $inputArray = @($mouseInputStructure)
                    [MouseSimulator]::SendInput(1, $inputArray, [System.Runtime.InteropServices.Marshal]::SizeOf([type][MouseSimulator+INPUT])) | Out-Null
                }
                'Keyboard' {
                    # Press a non-disruptive key (F15 is rarely used)
                    [System.Windows.Forms.SendKeys]::SendWait("{F15}")
                }
                'SystemAPI' {
                    # Directly tell Windows to stay awake
                    [DisplayState]::SetThreadExecutionState(
                        [DisplayState]::ES_CONTINUOUS -bor
                        [DisplayState]::ES_SYSTEM_REQUIRED -bor
                        [DisplayState]::ES_DISPLAY_REQUIRED)
                }
            }

            # Wait for the specified interval
            Start-Sleep -Milliseconds $Interval
        }

        # Reset execution state if we used the API
        if ($Methods -contains 'SystemAPI') {
            [DisplayState]::SetThreadExecutionState([DisplayState]::ES_CONTINUOUS)
        }
    } -ArgumentList $Interval, $Methods, $Duration, $startTime

    if ($Duration -gt 0) {
        Write-Host "PSMouseJiggler KeepAwake will run for $Duration seconds" -ForegroundColor Yellow
    }
    else {
        Write-Host "PSMouseJiggler KeepAwake is running indefinitely. Use Stop-PSMouseJiggler to stop." -ForegroundColor Yellow
    }

    # Clear console if incognito mode is enabled
    if ($Incognito) {
        Clear-Host
    }
}

#endregion

#region Linux-Specific Functions

<#
.SYNOPSIS
    Helper function to invoke xdotool or ydotool commands.

.DESCRIPTION
    Detects whether to use xdotool (X11) or ydotool (Wayland) and executes the command.
    Includes version detection and warnings for outdated tools.

.PARAMETER Command
    The command to execute (without the tool prefix).

.EXAMPLE
    Invoke-XDoTool -Command "mousemove_relative -- 10 5"
#>
function Invoke-XDoTool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Command
    )

    # Check for xdotool first (X11)
    if (Get-Command xdotool -ErrorAction SilentlyContinue) {
        # Check version and warn if outdated
        try {
            $versionOutput = & xdotool --version 2>&1 | Select-Object -First 1
            if ($versionOutput -match 'xdotool version (\d+)\.(\d+)') {
                $major = [int]$matches[1]
                $minor = [int]$matches[2]
                $version = "$major.$minor"

                if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 20180117)) {
                    Write-Warning "xdotool version $version detected. Version 3.20180117 or higher recommended for best compatibility."
                }
                Write-Verbose "Using xdotool version $version"
            }
        }
        catch {
            Write-Verbose "Could not determine xdotool version"
        }

        $fullCommand = "xdotool $Command"
        Write-Verbose "Executing: $fullCommand"
        Invoke-Expression $fullCommand
    }
    # Check for ydotool (Wayland)
    elseif (Get-Command ydotool -ErrorAction SilentlyContinue) {
        # Check version and warn if outdated
        try {
            $versionOutput = & ydotool --version 2>&1 | Select-Object -First 1
            if ($versionOutput -match 'ydotool version (\d+)\.(\d+)\.(\d+)') {
                $version = "$($matches[1]).$($matches[2]).$($matches[3])"

                # Warn if version is below 1.0.0
                if ([int]$matches[1] -lt 1) {
                    Write-Warning "ydotool version $version detected. Version 1.0.0 or higher recommended for stability."
                }
                Write-Verbose "Using ydotool version $version"
            }
        }
        catch {
            Write-Verbose "Could not determine ydotool version"
        }

        # Note: ydotool syntax is slightly different, need to adapt
        $fullCommand = "ydotool $Command"
        Write-Verbose "Executing: $fullCommand"
        Invoke-Expression $fullCommand
    }
    else {
        Write-Error "Neither xdotool nor ydotool found. Please install one of these tools."
        throw "Required tool not found"
    }
}

<#
.SYNOPSIS
    Starts the PSMouseJiggler on Linux using xdotool/ydotool.

.DESCRIPTION
    Linux-specific implementation using external tools for mouse control.
    Supports both X11 (xdotool) and Wayland (ydotool) display servers.

.PARAMETER Interval
    Time in milliseconds between mouse movements.

.PARAMETER MovementPattern
    The pattern for mouse movement.

.PARAMETER Duration
    Duration in seconds to run the jiggler.

.PARAMETER Incognito
    When enabled, clears the console after starting.
#>
function Start-PSMouseJiggler-Linux {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$Interval = 1000,

        [Parameter()]
        [ValidateSet('Random', 'Horizontal', 'Vertical', 'Circular')]
        [string]$MovementPattern = 'Random',

        [Parameter()]
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
    )

    if ($script:JigglingActive) {
        Write-Warning "PSMouseJiggler is already running. Use Stop-PSMouseJiggler to stop it first."
        return
    }

    # Verify xdotool or ydotool is available
    if (-not (Test-PlatformCapability -Capability 'XDoTool')) {
        Write-Error "Linux support requires xdotool (X11) or ydotool (Wayland). Install using your package manager:"
        Write-Host "  Ubuntu/Debian: sudo apt-get install xdotool" -ForegroundColor Yellow
        Write-Host "  Fedora: sudo dnf install xdotool" -ForegroundColor Yellow
        Write-Host "  Arch: sudo pacman -S xdotool" -ForegroundColor Yellow
        Write-Host "  For Wayland: Install ydotool from your package manager" -ForegroundColor Yellow
        return
    }

    Write-Host "Starting PSMouseJiggler (Linux) with $MovementPattern pattern, interval: $Interval ms" -ForegroundColor Green

    $script:JigglingActive = $true
    $startTime = Get-Date

    $script:JigglingJob = Start-Job -ScriptBlock {
        param($Interval, $MovementPattern, $Duration, $StartTime, $ModulePath)

        # Import helper function in job context
        . $ModulePath

        $endTime = if ($Duration -gt 0) { $StartTime.AddSeconds($Duration) } else { [DateTime]::MaxValue }

        while ((Get-Date) -lt $endTime) {
            # Determine movement pattern
            switch ($MovementPattern) {
                'Random' {
                    $xOffset = Get-Random -Minimum -10 -Maximum 11
                    $yOffset = Get-Random -Minimum -10 -Maximum 11
                }
                'Horizontal' {
                    $xOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
                    $yOffset = 0
                }
                'Vertical' {
                    $xOffset = 0
                    $yOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
                }
                'Circular' {
                    $angle = (Get-Date).Millisecond / 1000 * 2 * [Math]::PI
                    $xOffset = [Math]::Round([Math]::Sin($angle) * 10)
                    $yOffset = [Math]::Round([Math]::Cos($angle) * 10)
                }
                default {
                    $xOffset = Get-Random -Minimum -5 -Maximum 6
                    $yOffset = Get-Random -Minimum -5 -Maximum 6
                }
            }

            # Move the mouse using xdotool/ydotool
            try {
                if (Get-Command xdotool -ErrorAction SilentlyContinue) {
                    & xdotool mousemove_relative -- $xOffset $yOffset 2>&1 | Out-Null
                }
                elseif (Get-Command ydotool -ErrorAction SilentlyContinue) {
                    # ydotool uses different syntax: mousemove -x X -y Y (absolute positioning)
                    # For relative movement, we need to get current position first
                    # This is a limitation of ydotool - we'll do best effort
                    & ydotool mousemove -r $xOffset $yOffset 2>&1 | Out-Null
                }
            }
            catch {
                Write-Warning "Failed to move mouse: $_"
            }

            # Wait for the specified interval
            Start-Sleep -Milliseconds $Interval
        }
    } -ArgumentList $Interval, $MovementPattern, $Duration, $startTime, $PSCommandPath

    if ($Duration -gt 0) {
        Write-Host "PSMouseJiggler will run for $Duration seconds" -ForegroundColor Yellow
    }
    else {
        Write-Host "PSMouseJiggler is running indefinitely. Use Stop-PSMouseJiggler to stop." -ForegroundColor Yellow
    }

    # Clear console if incognito mode is enabled
    if ($Incognito) {
        Clear-Host
    }
}

<#
.SYNOPSIS
    Stops the PSMouseJiggler on Linux.

.DESCRIPTION
    Linux-specific implementation for stopping the jiggler.
    Handles job cleanup and state management.
#>
function Stop-PSMouseJiggler-Linux {
    [CmdletBinding()]
    param()

    if (-not $script:JigglingActive) {
        Write-Warning "PSMouseJiggler is not currently running."
        return
    }

    if ($script:JigglingJob) {
        if ($script:JigglingJob -is [System.Management.Automation.Job]) {
            Stop-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
            Remove-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
        }
        else {
            Write-Verbose "Stopping non-Job object (likely a test mock)"
        }
        $script:JigglingJob = $null
    }

    $script:JigglingActive = $false
    Write-Host "PSMouseJiggler stopped." -ForegroundColor Green
}

<#
.SYNOPSIS
    Moves the mouse cursor on Linux.

.DESCRIPTION
    Linux-specific implementation using xdotool or ydotool for cursor movement.
    Uses relative positioning to move the cursor by the specified offsets.

.PARAMETER X
    Horizontal offset in pixels.

.PARAMETER Y
    Vertical offset in pixels.
#>
function Move-Mouse-Linux {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$X,

        [Parameter(Mandatory)]
        [int]$Y
    )

    try {
        if (Get-Command xdotool -ErrorAction SilentlyContinue) {
            # xdotool supports relative movement with mousemove_relative
            & xdotool mousemove_relative -- $X $Y 2>&1 | Out-Null
            Write-Verbose "Moved mouse using xdotool: X=$X, Y=$Y"
        }
        elseif (Get-Command ydotool -ErrorAction SilentlyContinue) {
            # ydotool uses -r flag for relative movement
            & ydotool mousemove -r $X $Y 2>&1 | Out-Null
            Write-Verbose "Moved mouse using ydotool: X=$X, Y=$Y"
        }
        else {
            Write-Error "Neither xdotool nor ydotool found. Please install one of these tools."
        }
    }
    catch {
        Write-Error "Failed to move mouse on Linux: $_"
    }
}

<#
.SYNOPSIS
    Starts keep-awake functionality on Linux.

.DESCRIPTION
    Linux-specific implementation using xdotool for mouse simulation and systemd-inhibit for idle prevention.
    Note: MouseHardware and Keyboard methods are mapped to MouseSoftware on Linux.

.PARAMETER Methods
    Array of methods to use. Supported on Linux: MouseSoftware, SystemAPI.

.PARAMETER Interval
    Time in milliseconds between keep-awake actions.

.PARAMETER Duration
    Duration in seconds to run keep-awake.

.PARAMETER Incognito
    When enabled, clears the console after starting.
#>
function Start-KeepAwake-Linux {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI', 'All')]
        [string[]]$Methods = @('All'),

        [Parameter()]
        [int]$Interval = 30000,

        [Parameter()]
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
    )

    if ($script:JigglingActive) {
        Write-Warning "PSMouseJiggler is already running. Use Stop-PSMouseJiggler to stop it first."
        return
    }

    Write-Host "Starting PSMouseJiggler KeepAwake (Linux) with multiple methods, interval: $Interval ms" -ForegroundColor Green

    # Map unsupported methods to MouseSoftware on Linux
    if ($Methods -contains 'All') {
        $Methods = @('MouseSoftware', 'SystemAPI')
    }
    else {
        # Map MouseHardware and Keyboard to MouseSoftware
        $Methods = $Methods | ForEach-Object {
            if ($_ -in @('MouseHardware', 'Keyboard')) {
                Write-Warning "$_ method not directly supported on Linux. Using MouseSoftware instead."
                'MouseSoftware'
            }
            else {
                $_
            }
        } | Select-Object -Unique
    }

    $script:JigglingActive = $true
    $startTime = Get-Date

    # If using SystemAPI, start systemd-inhibit wrapper
    $inhibitJob = $null
    if ($Methods -contains 'SystemAPI') {
        if (Get-Command systemd-inhibit -ErrorAction SilentlyContinue) {
            Write-Verbose "Starting systemd-inhibit to prevent idle"

            # Start systemd-inhibit in background
            $inhibitDuration = if ($Duration -gt 0) { $Duration } else { 86400 } # Default to 24 hours if indefinite
            $inhibitJob = Start-Job -ScriptBlock {
                param($Duration)
                # systemd-inhibit blocks idle, sleep, and shutdown
                & systemd-inhibit --what=idle:sleep --who="PSMouseJiggler" --why="Preventing system idle" sleep $Duration 2>&1
            } -ArgumentList $inhibitDuration

            Write-Verbose "systemd-inhibit started (Job ID: $($inhibitJob.Id))"
        }
        else {
            Write-Warning "systemd-inhibit not found. SystemAPI method will not be effective. Install systemd."
        }
    }

    $script:JigglingJob = Start-Job -ScriptBlock {
        param($Interval, $Methods, $Duration, $StartTime)

        $endTime = if ($Duration -gt 0) { $StartTime.AddSeconds($Duration) } else { [DateTime]::MaxValue }

        while ((Get-Date) -lt $endTime) {
            # Randomly select a method from the provided methods
            $method = $Methods | Get-Random

            switch ($method) {
                'MouseSoftware' {
                    # Move mouse using xdotool/ydotool
                    try {
                        $xOffset = Get-Random -Minimum -10 -Maximum 11
                        $yOffset = Get-Random -Minimum -10 -Maximum 11

                        if (Get-Command xdotool -ErrorAction SilentlyContinue) {
                            & xdotool mousemove_relative -- $xOffset $yOffset 2>&1 | Out-Null
                            Start-Sleep -Milliseconds 100
                            & xdotool mousemove_relative -- (-$xOffset) (-$yOffset) 2>&1 | Out-Null
                        }
                        elseif (Get-Command ydotool -ErrorAction SilentlyContinue) {
                            & ydotool mousemove -r $xOffset $yOffset 2>&1 | Out-Null
                            Start-Sleep -Milliseconds 100
                            & ydotool mousemove -r (-$xOffset) (-$yOffset) 2>&1 | Out-Null
                        }
                    }
                    catch {
                        Write-Warning "Mouse movement failed: $_"
                    }
                }
                'SystemAPI' {
                    # systemd-inhibit is running in separate job, just continue
                    Write-Verbose "SystemAPI active via systemd-inhibit"
                }
            }

            # Wait for the specified interval
            Start-Sleep -Milliseconds $Interval
        }
    } -ArgumentList $Interval, $Methods, $Duration, $startTime

    # Store inhibit job reference if created
    if ($inhibitJob) {
        $script:JigglingJob | Add-Member -NotePropertyName 'InhibitJob' -NotePropertyValue $inhibitJob -Force
    }

    if ($Duration -gt 0) {
        Write-Host "PSMouseJiggler KeepAwake will run for $Duration seconds" -ForegroundColor Yellow
    }
    else {
        Write-Host "PSMouseJiggler KeepAwake is running indefinitely. Use Stop-PSMouseJiggler to stop." -ForegroundColor Yellow
    }

    # Clear console if incognito mode is enabled
    if ($Incognito) {
        Clear-Host
    }
}

#endregion

#region macOS-Specific Functions

<#
.SYNOPSIS
    Helper function to invoke cliclick commands on macOS.

.DESCRIPTION
    Detects and executes cliclick commands with version checking.
    Includes version detection and warnings for outdated tools.

.PARAMETER Command
    The cliclick command to execute.

.EXAMPLE
    Invoke-CliClick -Command "m:+10,+5"
#>
function Invoke-CliClick {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Command
    )

    if (Get-Command cliclick -ErrorAction SilentlyContinue) {
        # Check version and warn if outdated
        try {
            $versionOutput = & cliclick -V 2>&1 | Select-Object -First 1
            if ($versionOutput -match 'cliclick (\d+)\.(\d+)(\.\d+)?') {
                $major = [int]$matches[1]
                $minor = [int]$matches[2]
                $version = "$major.$minor"

                if ($major -lt 5) {
                    Write-Warning "cliclick version $version detected. Version 5.0 or higher recommended for best compatibility."
                }
                Write-Verbose "Using cliclick version $version"
            }
        }
        catch {
            Write-Verbose "Could not determine cliclick version"
        }

        $fullCommand = "cliclick $Command"
        Write-Verbose "Executing: $fullCommand"
        Invoke-Expression $fullCommand
    }
    else {
        Write-Error "cliclick not found. Please install it via Homebrew: brew install cliclick"
        throw "Required tool not found"
    }
}

<#
.SYNOPSIS
    Starts the PSMouseJiggler on macOS using cliclick.

.DESCRIPTION
    macOS-specific implementation using cliclick for mouse control.
    Supports all movement patterns and background execution.

.PARAMETER Interval
    Time in milliseconds between mouse movements.

.PARAMETER MovementPattern
    The pattern for mouse movement.

.PARAMETER Duration
    Duration in seconds to run the jiggler.

.PARAMETER Incognito
    When enabled, clears the console after starting.
#>
function Start-PSMouseJiggler-MacOS {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$Interval = 1000,

        [Parameter()]
        [ValidateSet('Random', 'Horizontal', 'Vertical', 'Circular')]
        [string]$MovementPattern = 'Random',

        [Parameter()]
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
    )

    if ($script:JigglingActive) {
        Write-Warning "PSMouseJiggler is already running. Use Stop-PSMouseJiggler to stop it first."
        return
    }

    # Verify cliclick is available
    if (-not (Test-PlatformCapability -Capability 'CliClick')) {
        Write-Error "macOS support requires cliclick. Install using Homebrew:"
        Write-Host "  brew install cliclick" -ForegroundColor Yellow
        return
    }

    Write-Host "Starting PSMouseJiggler (macOS) with $MovementPattern pattern, interval: $Interval ms" -ForegroundColor Green

    $script:JigglingActive = $true
    $startTime = Get-Date

    $script:JigglingJob = Start-Job -ScriptBlock {
        param($Interval, $MovementPattern, $Duration, $StartTime)

        $endTime = if ($Duration -gt 0) { $StartTime.AddSeconds($Duration) } else { [DateTime]::MaxValue }

        while ((Get-Date) -lt $endTime) {
            # Determine movement pattern
            switch ($MovementPattern) {
                'Random' {
                    $xOffset = Get-Random -Minimum -10 -Maximum 11
                    $yOffset = Get-Random -Minimum -10 -Maximum 11
                }
                'Horizontal' {
                    $xOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
                    $yOffset = 0
                }
                'Vertical' {
                    $xOffset = 0
                    $yOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
                }
                'Circular' {
                    $angle = (Get-Date).Millisecond / 1000 * 2 * [Math]::PI
                    $xOffset = [Math]::Round([Math]::Sin($angle) * 10)
                    $yOffset = [Math]::Round([Math]::Cos($angle) * 10)
                }
                default {
                    $xOffset = Get-Random -Minimum -5 -Maximum 6
                    $yOffset = Get-Random -Minimum -5 -Maximum 6
                }
            }

            # Move the mouse using cliclick (relative movement)
            try {
                if (Get-Command cliclick -ErrorAction SilentlyContinue) {
                    # cliclick uses m:+X,+Y for relative movement
                    $moveCmd = "m:+$xOffset,+$yOffset"
                    & cliclick $moveCmd 2>&1 | Out-Null
                }
            }
            catch {
                Write-Warning "Failed to move mouse: $_"
            }

            # Wait for the specified interval
            Start-Sleep -Milliseconds $Interval
        }
    } -ArgumentList $Interval, $MovementPattern, $Duration, $startTime

    if ($Duration -gt 0) {
        Write-Host "PSMouseJiggler will run for $Duration seconds" -ForegroundColor Yellow
    }
    else {
        Write-Host "PSMouseJiggler is running indefinitely. Use Stop-PSMouseJiggler to stop." -ForegroundColor Yellow
    }

    # Clear console if incognito mode is enabled
    if ($Incognito) {
        Clear-Host
    }
}

<#
.SYNOPSIS
    Stops the PSMouseJiggler on macOS.

.DESCRIPTION
    macOS-specific implementation for stopping the jiggler.
    Handles job cleanup and state management.
#>
function Stop-PSMouseJiggler-MacOS {
    [CmdletBinding()]
    param()

    if (-not $script:JigglingActive) {
        Write-Warning "PSMouseJiggler is not currently running."
        return
    }

    if ($script:JigglingJob) {
        if ($script:JigglingJob -is [System.Management.Automation.Job]) {
            Stop-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
            Remove-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
        }
        else {
            Write-Verbose "Stopping non-Job object (likely a test mock)"
        }
        $script:JigglingJob = $null
    }

    $script:JigglingActive = $false
    Write-Host "PSMouseJiggler stopped." -ForegroundColor Green
}

<#
.SYNOPSIS
    Moves the mouse cursor on macOS.

.DESCRIPTION
    macOS-specific implementation using cliclick for cursor movement.
    Uses relative positioning to move the cursor by the specified offsets.

.PARAMETER X
    Horizontal offset in pixels.

.PARAMETER Y
    Vertical offset in pixels.
#>
function Move-Mouse-MacOS {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$X,

        [Parameter(Mandatory)]
        [int]$Y
    )

    try {
        if (Get-Command cliclick -ErrorAction SilentlyContinue) {
            # cliclick uses m:+X,+Y for relative movement
            $moveCmd = "m:+$X,+$Y"
            & cliclick $moveCmd 2>&1 | Out-Null
            Write-Verbose "Moved mouse using cliclick: X=$X, Y=$Y"
        }
        else {
            Write-Error "cliclick not found. Please install it via Homebrew: brew install cliclick"
        }
    }
    catch {
        Write-Error "Failed to move mouse on macOS: $_"
    }
}

<#
.SYNOPSIS
    Starts keep-awake functionality on macOS.

.DESCRIPTION
    macOS-specific implementation using cliclick for mouse simulation and caffeinate for idle prevention.
    Note: MouseHardware and Keyboard methods are mapped to MouseSoftware on macOS.

.PARAMETER Methods
    Array of methods to use. Supported on macOS: MouseSoftware, SystemAPI.

.PARAMETER Interval
    Time in milliseconds between keep-awake actions.

.PARAMETER Duration
    Duration in seconds to run keep-awake.

.PARAMETER Incognito
    When enabled, clears the console after starting.
#>
function Start-KeepAwake-MacOS {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI', 'All')]
        [string[]]$Methods = @('All'),

        [Parameter()]
        [int]$Interval = 30000,

        [Parameter()]
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
    )

    if ($script:JigglingActive) {
        Write-Warning "PSMouseJiggler is already running. Use Stop-PSMouseJiggler to stop it first."
        return
    }

    Write-Host "Starting PSMouseJiggler KeepAwake (macOS) with multiple methods, interval: $Interval ms" -ForegroundColor Green

    # Map unsupported methods to MouseSoftware on macOS
    if ($Methods -contains 'All') {
        $Methods = @('MouseSoftware', 'SystemAPI')
    }
    else {
        # Map MouseHardware and Keyboard to MouseSoftware
        $Methods = $Methods | ForEach-Object {
            if ($_ -in @('MouseHardware', 'Keyboard')) {
                Write-Warning "$_ method not directly supported on macOS. Using MouseSoftware instead."
                'MouseSoftware'
            }
            else {
                $_
            }
        } | Select-Object -Unique
    }

    $script:JigglingActive = $true
    $startTime = Get-Date

    # If using SystemAPI, start caffeinate wrapper
    $caffeinateJob = $null
    if ($Methods -contains 'SystemAPI') {
        if (Get-Command caffeinate -ErrorAction SilentlyContinue) {
            Write-Verbose "Starting caffeinate to prevent idle"

            # Start caffeinate in background
            # -d prevents display sleep, -i prevents idle sleep
            $caffeinateDuration = if ($Duration -gt 0) { $Duration } else { 86400 } # Default to 24 hours if indefinite
            $caffeinateJob = Start-Job -ScriptBlock {
                param($Duration)
                # caffeinate blocks system idle and display sleep
                & caffeinate -d -i -t $Duration 2>&1
            } -ArgumentList $caffeinateDuration

            Write-Verbose "caffeinate started (Job ID: $($caffeinateJob.Id))"
        }
        else {
            Write-Warning "caffeinate not found (should be built-in to macOS). SystemAPI method may not work."
        }
    }

    $script:JigglingJob = Start-Job -ScriptBlock {
        param($Interval, $Methods, $Duration, $StartTime)

        $endTime = if ($Duration -gt 0) { $StartTime.AddSeconds($Duration) } else { [DateTime]::MaxValue }

        while ((Get-Date) -lt $endTime) {
            # Randomly select a method from the provided methods
            $method = $Methods | Get-Random

            switch ($method) {
                'MouseSoftware' {
                    # Move mouse using cliclick
                    try {
                        $xOffset = Get-Random -Minimum -10 -Maximum 11
                        $yOffset = Get-Random -Minimum -10 -Maximum 11

                        if (Get-Command cliclick -ErrorAction SilentlyContinue) {
                            $moveCmd = "m:+$xOffset,+$yOffset"
                            & cliclick $moveCmd 2>&1 | Out-Null
                            Start-Sleep -Milliseconds 100
                            $moveBackCmd = "m:+$(-$xOffset),+$(-$yOffset)"
                            & cliclick $moveBackCmd 2>&1 | Out-Null
                        }
                    }
                    catch {
                        Write-Warning "Mouse movement failed: $_"
                    }
                }
                'SystemAPI' {
                    # caffeinate is running in separate job, just continue
                    Write-Verbose "SystemAPI active via caffeinate"
                }
            }

            # Wait for the specified interval
            Start-Sleep -Milliseconds $Interval
        }
    } -ArgumentList $Interval, $Methods, $Duration, $startTime

    # Store caffeinate job reference if created
    if ($caffeinateJob) {
        $script:JigglingJob | Add-Member -NotePropertyName 'CaffeinateJob' -NotePropertyValue $caffeinateJob -Force
    }

    if ($Duration -gt 0) {
        Write-Host "PSMouseJiggler KeepAwake will run for $Duration seconds" -ForegroundColor Yellow
    }
    else {
        Write-Host "PSMouseJiggler KeepAwake is running indefinitely. Use Stop-PSMouseJiggler to stop." -ForegroundColor Yellow
    }

    # Clear console if incognito mode is enabled
    if ($Incognito) {
        Clear-Host
    }
}

#endregion

#endregion

#region Cross-Platform Wrapper Functions

<#
.SYNOPSIS
    Starts the PSMouseJiggler to simulate mouse movements.

.DESCRIPTION
    Cross-platform wrapper that starts mouse jiggling with specified interval and movement pattern to prevent the system from going idle.
    Automatically detects the operating system and dispatches to the appropriate platform-specific implementation.

    - Windows: Uses System.Windows.Forms API (Windows PowerShell 5.1 or PowerShell 7+)
    - Linux: Uses xdotool/ydotool (Requires PowerShell 7+)
    - macOS: Uses cliclick (Requires PowerShell 7+)

.PARAMETER Interval
    Time in milliseconds between mouse movements. Default is 1000ms.

.PARAMETER MovementPattern
    The pattern for mouse movement. Valid values: 'Random', 'Horizontal', 'Vertical', 'Circular'. Default is 'Random'.

.PARAMETER Duration
    Duration in seconds to run the jiggler. If not specified, runs indefinitely until stopped.

.PARAMETER Incognito
    When enabled, clears the console after starting to maintain privacy/discretion.

.EXAMPLE
    Start-PSMouseJiggler
    Starts mouse jiggling with default settings on the detected platform.

.EXAMPLE
    Start-PSMouseJiggler -Interval 2000 -MovementPattern 'Circular' -Duration 300
    Starts mouse jiggling every 2 seconds using circular pattern for 5 minutes.

.NOTES
    Requires PowerShell 7+ for Linux and macOS support.
    Windows PowerShell 5.1 is supported on Windows only.
#>
function Start-PSMouseJiggler {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$Interval = 1000,

        [Parameter()]
        [ValidateSet('Random', 'Horizontal', 'Vertical', 'Circular')]
        [string]$MovementPattern = 'Random',

        [Parameter()]
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
    )

    $platform = Get-OperatingSystemPlatform

    Write-Verbose "Detected platform: $platform"

    switch ($platform) {
        'Windows' {
            Start-PSMouseJiggler-Windows @PSBoundParameters
        }
        'Linux' {
            # Check for required tools
            if (-not (Test-PlatformCapability -Capability 'XDoTool')) {
                Write-Error "Linux support requires xdotool or ydotool. Please install using your package manager."
                Show-DependencyInstallInstructions -Platform 'Linux'
                return
            }
            Start-PSMouseJiggler-Linux @PSBoundParameters
        }
        'macOS' {
            # Check for required tools
            if (-not (Test-PlatformCapability -Capability 'CliClick')) {
                Write-Error "macOS support requires cliclick. Install via: brew install cliclick"
                Show-DependencyInstallInstructions -Platform 'macOS'
                return
            }
            Start-PSMouseJiggler-MacOS @PSBoundParameters
        }
        default {
            Write-Error "Unsupported platform: $platform"
        }
    }
}

<#
.SYNOPSIS
    Stops the PSMouseJiggler.

.DESCRIPTION
    Cross-platform wrapper that stops any running mouse jiggling job.
    Automatically detects the operating system and dispatches to the appropriate platform-specific implementation.

.EXAMPLE
    Stop-PSMouseJiggler
    Stops the currently running mouse jiggler on the detected platform.

.NOTES
    Works on Windows, Linux, and macOS.
#>
function Stop-PSMouseJiggler {
    [CmdletBinding()]
    param()

    $platform = Get-OperatingSystemPlatform

    Write-Verbose "Stopping jiggler on platform: $platform"

    switch ($platform) {
        'Windows' {
            Stop-PSMouseJiggler-Windows
        }
        'Linux' {
            Stop-PSMouseJiggler-Linux
        }
        'macOS' {
            Stop-PSMouseJiggler-MacOS
        }
        default {
            Write-Error "Unsupported platform: $platform"
        }
    }
}

<#
.SYNOPSIS
    Calculates a new mouse position based on current position and pattern.

.DESCRIPTION
    Internal function to determine new mouse coordinates based on movement pattern.

.PARAMETER CurrentPosition
    The current mouse position as a System.Drawing.Point.

.PARAMETER Pattern
    The movement pattern to use.

.EXAMPLE
    $newPos = Get-NewMousePosition -CurrentPosition $currentPos -Pattern 'Random'
#>
function Get-NewMousePosition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Drawing.Point]$CurrentPosition,

        [Parameter(Mandatory)]
        [string]$Pattern
    )

    switch ($Pattern) {
        'Random' {
            $xOffset = Get-Random -Minimum -10 -Maximum 11
            $yOffset = Get-Random -Minimum -10 -Maximum 11
            return New-Object System.Drawing.Point($CurrentPosition.X + $xOffset, $CurrentPosition.Y + $yOffset)
        }
        'Horizontal' {
            $xOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
            return New-Object System.Drawing.Point($CurrentPosition.X + $xOffset, $CurrentPosition.Y)
        }
        'Vertical' {
            $yOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
            return New-Object System.Drawing.Point($CurrentPosition.X, $CurrentPosition.Y + $yOffset)
        }
        'Circular' {
            $angle = (Get-Date).Millisecond / 1000 * 2 * [Math]::PI
            $xOffset = [Math]::Round([Math]::Sin($angle) * 10)
            $yOffset = [Math]::Round([Math]::Cos($angle) * 10)
            return New-Object System.Drawing.Point($CurrentPosition.X + $xOffset, $CurrentPosition.Y + $yOffset)
        }
        default {
            $xOffset = Get-Random -Minimum -5 -Maximum 6
            $yOffset = Get-Random -Minimum -5 -Maximum 6
            return New-Object System.Drawing.Point($CurrentPosition.X + $xOffset, $CurrentPosition.Y + $yOffset)
        }
    }
}

#endregion

#region GUI Functions

<#
.SYNOPSIS
    Shows the PSMouseJiggler GUI interface with tabbed controls.

.DESCRIPTION
    Displays a modern graphical user interface with three main tabs:
    - Basic: Simple mouse jiggling with movement patterns and input methods
    - Advanced: Multi-method keep-awake with configurable techniques
    - Quick Launch: Five pre-configured profiles for common scenarios

    The GUI provides comprehensive controls including incognito mode, duration settings,
    and detailed help information about each feature.

.EXAMPLE
    Show-PSMouseJigglerGUI
    Opens the GUI interface with all tabs available.

.EXAMPLE
    Show-PSMouseJigglerGUI
    # Use the Quick Launch tab for one-click start with pre-configured profiles:
    # - [Mouse] Basic Discrete
    # - [Lock] Maximum Security
    # - [Key] Keyboard Only
    # - [API] System API Only
    # - [MAX] All Methods
#>
function Show-PSMouseJigglerGUI {
    [CmdletBinding()]
    param()

    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "PSMouseJiggler v1.1.0"
    $form.Size = New-Object System.Drawing.Size(600, 550)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

    # Create TabControl
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Location = New-Object System.Drawing.Point(10, 10)
    $tabControl.Size = New-Object System.Drawing.Size(560, 420)
    $form.Controls.Add($tabControl)

    #region Basic Tab
    $basicTab = New-Object System.Windows.Forms.TabPage
    $basicTab.Text = "Basic Mode"
    $basicTab.BackColor = [System.Drawing.Color]::White
    $tabControl.Controls.Add($basicTab)

    # Status Panel
    $statusGroupBox = New-Object System.Windows.Forms.GroupBox
    $statusGroupBox.Text = "Current Status"
    $statusGroupBox.Location = New-Object System.Drawing.Point(20, 20)
    $statusGroupBox.Size = New-Object System.Drawing.Size(500, 70)
    $basicTab.Controls.Add($statusGroupBox)

    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Status: Stopped"
    $statusLabel.Location = New-Object System.Drawing.Point(15, 25)
    $statusLabel.Size = New-Object System.Drawing.Size(470, 20)
    $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $statusLabel.ForeColor = [System.Drawing.Color]::DarkRed
    $statusGroupBox.Controls.Add($statusLabel)

    $statusDetailsLabel = New-Object System.Windows.Forms.Label
    $statusDetailsLabel.Text = "Ready to start mouse jiggling"
    $statusDetailsLabel.Location = New-Object System.Drawing.Point(15, 45)
    $statusDetailsLabel.Size = New-Object System.Drawing.Size(470, 20)
    $statusDetailsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $statusDetailsLabel.ForeColor = [System.Drawing.Color]::Gray
    $statusGroupBox.Controls.Add($statusDetailsLabel)

    # Settings GroupBox
    $settingsGroupBox = New-Object System.Windows.Forms.GroupBox
    $settingsGroupBox.Text = "Basic Settings"
    $settingsGroupBox.Location = New-Object System.Drawing.Point(20, 100)
    $settingsGroupBox.Size = New-Object System.Drawing.Size(500, 200)
    $basicTab.Controls.Add($settingsGroupBox)

    # Movement Pattern
    $patternLabel = New-Object System.Windows.Forms.Label
    $patternLabel.Text = "Movement Pattern:"
    $patternLabel.Location = New-Object System.Drawing.Point(15, 30)
    $patternLabel.Size = New-Object System.Drawing.Size(120, 20)
    $settingsGroupBox.Controls.Add($patternLabel)

    $patternComboBox = New-Object System.Windows.Forms.ComboBox
    $patternComboBox.Location = New-Object System.Drawing.Point(150, 28)
    $patternComboBox.Size = New-Object System.Drawing.Size(150, 20)
    $patternComboBox.DropDownStyle = "DropDownList"
    $patternComboBox.Items.AddRange(@("Random", "Horizontal", "Vertical", "Circular"))
    $patternComboBox.SelectedIndex = 0
    $settingsGroupBox.Controls.Add($patternComboBox)

    $patternDescLabel = New-Object System.Windows.Forms.Label
    $patternDescLabel.Text = "Simulates natural mouse movements"
    $patternDescLabel.Location = New-Object System.Drawing.Point(310, 30)
    $patternDescLabel.Size = New-Object System.Drawing.Size(180, 20)
    $patternDescLabel.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $patternDescLabel.ForeColor = [System.Drawing.Color]::Gray
    $settingsGroupBox.Controls.Add($patternDescLabel)

    # Update description based on pattern selection
    $patternComboBox.Add_SelectedIndexChanged({
            switch ($patternComboBox.SelectedItem.ToString()) {
                'Random' { $patternDescLabel.Text = "Random movements in all directions" }
                'Horizontal' { $patternDescLabel.Text = "Left-right movements only" }
                'Vertical' { $patternDescLabel.Text = "Up-down movements only" }
                'Circular' { $patternDescLabel.Text = "Smooth circular motion pattern" }
            }
        })

    # Interval
    $intervalLabel = New-Object System.Windows.Forms.Label
    $intervalLabel.Text = "Interval (milliseconds):"
    $intervalLabel.Location = New-Object System.Drawing.Point(15, 65)
    $intervalLabel.Size = New-Object System.Drawing.Size(130, 20)
    $settingsGroupBox.Controls.Add($intervalLabel)

    $intervalTextBox = New-Object System.Windows.Forms.TextBox
    $intervalTextBox.Text = "1000"
    $intervalTextBox.Location = New-Object System.Drawing.Point(150, 63)
    $intervalTextBox.Size = New-Object System.Drawing.Size(80, 20)
    $settingsGroupBox.Controls.Add($intervalTextBox)

    $intervalDescLabel = New-Object System.Windows.Forms.Label
    $intervalDescLabel.Text = "Time between movements (1000 = 1 second)"
    $intervalDescLabel.Location = New-Object System.Drawing.Point(240, 65)
    $intervalDescLabel.Size = New-Object System.Drawing.Size(250, 20)
    $intervalDescLabel.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $intervalDescLabel.ForeColor = [System.Drawing.Color]::Gray
    $settingsGroupBox.Controls.Add($intervalDescLabel)

    # Duration
    $durationLabel = New-Object System.Windows.Forms.Label
    $durationLabel.Text = "Duration (seconds):"
    $durationLabel.Location = New-Object System.Drawing.Point(15, 100)
    $durationLabel.Size = New-Object System.Drawing.Size(120, 20)
    $settingsGroupBox.Controls.Add($durationLabel)

    $durationTextBox = New-Object System.Windows.Forms.TextBox
    $durationTextBox.Text = "0"
    $durationTextBox.Location = New-Object System.Drawing.Point(150, 98)
    $durationTextBox.Size = New-Object System.Drawing.Size(80, 20)
    $settingsGroupBox.Controls.Add($durationTextBox)

    $durationDescLabel = New-Object System.Windows.Forms.Label
    $durationDescLabel.Text = "How long to run (0 = run until stopped)"
    $durationDescLabel.Location = New-Object System.Drawing.Point(240, 100)
    $durationDescLabel.Size = New-Object System.Drawing.Size(250, 20)
    $durationDescLabel.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $durationDescLabel.ForeColor = [System.Drawing.Color]::Gray
    $settingsGroupBox.Controls.Add($durationDescLabel)

    # Mouse Movement Type (linking basic to advanced mouse methods)
    $mouseTypeLabel = New-Object System.Windows.Forms.Label
    $mouseTypeLabel.Text = "Mouse Input Method:"
    $mouseTypeLabel.Location = New-Object System.Drawing.Point(15, 135)
    $mouseTypeLabel.Size = New-Object System.Drawing.Size(130, 20)
    $settingsGroupBox.Controls.Add($mouseTypeLabel)

    $mouseTypeComboBox = New-Object System.Windows.Forms.ComboBox
    $mouseTypeComboBox.Location = New-Object System.Drawing.Point(150, 133)
    $mouseTypeComboBox.Size = New-Object System.Drawing.Size(150, 20)
    $mouseTypeComboBox.DropDownStyle = "DropDownList"
    $mouseTypeComboBox.Items.AddRange(@("Software (Standard)", "Hardware (Low-level)", "Both (Redundant)"))
    $mouseTypeComboBox.SelectedIndex = 0
    $settingsGroupBox.Controls.Add($mouseTypeComboBox)

    $mouseTypeDescLabel = New-Object System.Windows.Forms.Label
    $mouseTypeDescLabel.Text = "Standard method for most systems"
    $mouseTypeDescLabel.Location = New-Object System.Drawing.Point(310, 135)
    $mouseTypeDescLabel.Size = New-Object System.Drawing.Size(180, 20)
    $mouseTypeDescLabel.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $mouseTypeDescLabel.ForeColor = [System.Drawing.Color]::Gray
    $settingsGroupBox.Controls.Add($mouseTypeDescLabel)

    $mouseTypeComboBox.Add_SelectedIndexChanged({
            switch ($mouseTypeComboBox.SelectedIndex) {
                0 { $mouseTypeDescLabel.Text = "Standard method for most systems" }
                1 { $mouseTypeDescLabel.Text = "Better for strict security policies" }
                2 { $mouseTypeDescLabel.Text = "Maximum reliability (both methods)" }
            }
        })

    # Incognito mode checkbox
    $incognitoCheckbox = New-Object System.Windows.Forms.CheckBox
    $incognitoCheckbox.Text = "Incognito Mode (minimize window & clear console)"
    $incognitoCheckbox.Location = New-Object System.Drawing.Point(15, 165)
    $incognitoCheckbox.Size = New-Object System.Drawing.Size(350, 20)
    $settingsGroupBox.Controls.Add($incognitoCheckbox)
    #endregion

    #region Advanced Tab
    $advancedTab = New-Object System.Windows.Forms.TabPage
    $advancedTab.Text = "Advanced Mode"
    $advancedTab.BackColor = [System.Drawing.Color]::White
    $tabControl.Controls.Add($advancedTab)

    # Advanced Info Label
    $advancedInfoLabel = New-Object System.Windows.Forms.Label
    $advancedInfoLabel.Text = "Advanced mode combines multiple methods to prevent sleep/screensaver activation"
    $advancedInfoLabel.Location = New-Object System.Drawing.Point(20, 20)
    $advancedInfoLabel.Size = New-Object System.Drawing.Size(500, 30)
    $advancedInfoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $advancedInfoLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 102, 204)
    $advancedTab.Controls.Add($advancedInfoLabel)

    # Method Selection GroupBox
    $methodsGroupBox = New-Object System.Windows.Forms.GroupBox
    $methodsGroupBox.Text = "Keep-Awake Methods (Select one or more)"
    $methodsGroupBox.Location = New-Object System.Drawing.Point(20, 60)
    $methodsGroupBox.Size = New-Object System.Drawing.Size(500, 180)
    $advancedTab.Controls.Add($methodsGroupBox)

    # Mouse Software Checkbox
    $mouseSoftwareCheckbox = New-Object System.Windows.Forms.CheckBox
    $mouseSoftwareCheckbox.Text = "Software Mouse Movements"
    $mouseSoftwareCheckbox.Location = New-Object System.Drawing.Point(15, 25)
    $mouseSoftwareCheckbox.Size = New-Object System.Drawing.Size(220, 20)
    $mouseSoftwareCheckbox.Checked = $true
    $methodsGroupBox.Controls.Add($mouseSoftwareCheckbox)

    $mouseSoftwareDesc = New-Object System.Windows.Forms.Label
    $mouseSoftwareDesc.Text = "Standard cursor position changes"
    $mouseSoftwareDesc.Location = New-Object System.Drawing.Point(240, 25)
    $mouseSoftwareDesc.Size = New-Object System.Drawing.Size(250, 20)
    $mouseSoftwareDesc.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $mouseSoftwareDesc.ForeColor = [System.Drawing.Color]::Gray
    $methodsGroupBox.Controls.Add($mouseSoftwareDesc)

    # Mouse Hardware Checkbox
    $mouseHardwareCheckbox = New-Object System.Windows.Forms.CheckBox
    $mouseHardwareCheckbox.Text = "Hardware Mouse Input"
    $mouseHardwareCheckbox.Location = New-Object System.Drawing.Point(15, 55)
    $mouseHardwareCheckbox.Size = New-Object System.Drawing.Size(220, 20)
    $mouseHardwareCheckbox.Checked = $true
    $methodsGroupBox.Controls.Add($mouseHardwareCheckbox)

    $mouseHardwareDesc = New-Object System.Windows.Forms.Label
    $mouseHardwareDesc.Text = "Low-level input simulation (SendInput API)"
    $mouseHardwareDesc.Location = New-Object System.Drawing.Point(240, 55)
    $mouseHardwareDesc.Size = New-Object System.Drawing.Size(250, 20)
    $mouseHardwareDesc.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $mouseHardwareDesc.ForeColor = [System.Drawing.Color]::Gray
    $methodsGroupBox.Controls.Add($mouseHardwareDesc)

    # Keyboard Checkbox
    $keyboardCheckbox = New-Object System.Windows.Forms.CheckBox
    $keyboardCheckbox.Text = "Keyboard Input (F15 key)"
    $keyboardCheckbox.Location = New-Object System.Drawing.Point(15, 85)
    $keyboardCheckbox.Size = New-Object System.Drawing.Size(220, 20)
    $keyboardCheckbox.Checked = $true
    $methodsGroupBox.Controls.Add($keyboardCheckbox)

    $keyboardDesc = New-Object System.Windows.Forms.Label
    $keyboardDesc.Text = "Sends non-disruptive key press"
    $keyboardDesc.Location = New-Object System.Drawing.Point(240, 85)
    $keyboardDesc.Size = New-Object System.Drawing.Size(250, 20)
    $keyboardDesc.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $keyboardDesc.ForeColor = [System.Drawing.Color]::Gray
    $methodsGroupBox.Controls.Add($keyboardDesc)

    # System API Checkbox
    $systemApiCheckbox = New-Object System.Windows.Forms.CheckBox
    $systemApiCheckbox.Text = "System API (SetThreadExecutionState)"
    $systemApiCheckbox.Location = New-Object System.Drawing.Point(15, 115)
    $systemApiCheckbox.Size = New-Object System.Drawing.Size(250, 20)
    $systemApiCheckbox.Checked = $true
    $methodsGroupBox.Controls.Add($systemApiCheckbox)

    $systemApiDesc = New-Object System.Windows.Forms.Label
    $systemApiDesc.Text = "Directly prevents Windows power management"
    $systemApiDesc.Location = New-Object System.Drawing.Point(270, 115)
    $systemApiDesc.Size = New-Object System.Drawing.Size(220, 20)
    $systemApiDesc.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $systemApiDesc.ForeColor = [System.Drawing.Color]::Gray
    $methodsGroupBox.Controls.Add($systemApiDesc)

    # Advanced Interval
    $advIntervalLabel = New-Object System.Windows.Forms.Label
    $advIntervalLabel.Text = "Interval (milliseconds):"
    $advIntervalLabel.Location = New-Object System.Drawing.Point(15, 145)
    $advIntervalLabel.Size = New-Object System.Drawing.Size(130, 20)
    $methodsGroupBox.Controls.Add($advIntervalLabel)

    $advIntervalTextBox = New-Object System.Windows.Forms.TextBox
    $advIntervalTextBox.Text = "30000"
    $advIntervalTextBox.Location = New-Object System.Drawing.Point(150, 143)
    $advIntervalTextBox.Size = New-Object System.Drawing.Size(80, 20)
    $methodsGroupBox.Controls.Add($advIntervalTextBox)

    $advIntervalDesc = New-Object System.Windows.Forms.Label
    $advIntervalDesc.Text = "30000 = 30 seconds (recommended for keep-awake)"
    $advIntervalDesc.Location = New-Object System.Drawing.Point(240, 145)
    $advIntervalDesc.Size = New-Object System.Drawing.Size(250, 20)
    $advIntervalDesc.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $advIntervalDesc.ForeColor = [System.Drawing.Color]::Gray
    $methodsGroupBox.Controls.Add($advIntervalDesc)

    # Advanced Duration
    $advDurationGroupBox = New-Object System.Windows.Forms.GroupBox
    $advDurationGroupBox.Text = "Duration Settings"
    $advDurationGroupBox.Location = New-Object System.Drawing.Point(20, 250)
    $advDurationGroupBox.Size = New-Object System.Drawing.Size(500, 80)
    $advancedTab.Controls.Add($advDurationGroupBox)

    $advDurationLabel = New-Object System.Windows.Forms.Label
    $advDurationLabel.Text = "Duration (seconds):"
    $advDurationLabel.Location = New-Object System.Drawing.Point(15, 25)
    $advDurationLabel.Size = New-Object System.Drawing.Size(120, 20)
    $advDurationGroupBox.Controls.Add($advDurationLabel)

    $advDurationTextBox = New-Object System.Windows.Forms.TextBox
    $advDurationTextBox.Text = "0"
    $advDurationTextBox.Location = New-Object System.Drawing.Point(150, 23)
    $advDurationTextBox.Size = New-Object System.Drawing.Size(80, 20)
    $advDurationGroupBox.Controls.Add($advDurationTextBox)

    $advDurationDesc = New-Object System.Windows.Forms.Label
    $advDurationDesc.Text = "0 = run until manually stopped"
    $advDurationDesc.Location = New-Object System.Drawing.Point(240, 25)
    $advDurationDesc.Size = New-Object System.Drawing.Size(250, 20)
    $advDurationDesc.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $advDurationDesc.ForeColor = [System.Drawing.Color]::Gray
    $advDurationGroupBox.Controls.Add($advDurationDesc)

    # Advanced Incognito
    $advIncognitoCheckbox = New-Object System.Windows.Forms.CheckBox
    $advIncognitoCheckbox.Text = "Incognito Mode"
    $advIncognitoCheckbox.Location = New-Object System.Drawing.Point(15, 50)
    $advIncognitoCheckbox.Size = New-Object System.Drawing.Size(200, 20)
    $advDurationGroupBox.Controls.Add($advIncognitoCheckbox)
    #endregion

    #region Favorites Tab
    $favoritesTab = New-Object System.Windows.Forms.TabPage
    $favoritesTab.Text = "Quick Launch"
    $favoritesTab.BackColor = [System.Drawing.Color]::White
    $tabControl.Controls.Add($favoritesTab)

    # Favorites Info
    $favInfoLabel = New-Object System.Windows.Forms.Label
    $favInfoLabel.Text = "Quick launch pre-configured profiles for common scenarios"
    $favInfoLabel.Location = New-Object System.Drawing.Point(20, 20)
    $favInfoLabel.Size = New-Object System.Drawing.Size(500, 20)
    $favInfoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $favInfoLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 102, 204)
    $favoritesTab.Controls.Add($favInfoLabel)

    # Quick Launch Buttons
    $quickLaunchGroupBox = New-Object System.Windows.Forms.GroupBox
    $quickLaunchGroupBox.Text = "Quick Launch Profiles"
    $quickLaunchGroupBox.Location = New-Object System.Drawing.Point(20, 50)
    $quickLaunchGroupBox.Size = New-Object System.Drawing.Size(500, 320)
    $favoritesTab.Controls.Add($quickLaunchGroupBox)

    # Profile 1: Basic Discrete
    $profile1Button = New-Object System.Windows.Forms.Button
    $profile1Button.Text = "[Mouse] Basic Discrete"
    $profile1Button.Location = New-Object System.Drawing.Point(20, 30)
    $profile1Button.Size = New-Object System.Drawing.Size(220, 50)
    $profile1Button.BackColor = [System.Drawing.Color]::FromArgb(230, 240, 255)
    $quickLaunchGroupBox.Controls.Add($profile1Button)

    $profile1Desc = New-Object System.Windows.Forms.Label
    $profile1Desc.Text = "Random mouse movements every 1 second`nSoftware method, incognito mode"
    $profile1Desc.Location = New-Object System.Drawing.Point(250, 30)
    $profile1Desc.Size = New-Object System.Drawing.Size(230, 40)
    $profile1Desc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $quickLaunchGroupBox.Controls.Add($profile1Desc)

    $profile1Button.Add_Click({
            try {
                Start-PSMouseJiggler -Interval 1000 -MovementPattern 'Random' -Duration 0 -Incognito
                $statusLabel.Text = "Status: Running (Basic Discrete)"
                $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
                $statusDetailsLabel.Text = "Profile: Basic Discrete | Random movement, 1s interval"
                $startButton.Enabled = $false
                $stopButton.Enabled = $true
                $tabControl.SelectedIndex = 0
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
            }
        })

    # Profile 2: Maximum Security
    $profile2Button = New-Object System.Windows.Forms.Button
    $profile2Button.Text = "[Lock] Maximum Security"
    $profile2Button.Location = New-Object System.Drawing.Point(20, 95)
    $profile2Button.Size = New-Object System.Drawing.Size(220, 50)
    $profile2Button.BackColor = [System.Drawing.Color]::FromArgb(255, 240, 230)
    $quickLaunchGroupBox.Controls.Add($profile2Button)

    $profile2Desc = New-Object System.Windows.Forms.Label
    $profile2Desc.Text = "Hardware mouse + System API`nBest for strict security policies, 30s interval"
    $profile2Desc.Location = New-Object System.Drawing.Point(250, 95)
    $profile2Desc.Size = New-Object System.Drawing.Size(230, 40)
    $profile2Desc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $quickLaunchGroupBox.Controls.Add($profile2Desc)

    $profile2Button.Add_Click({
            try {
                Start-KeepAwake -Methods @('MouseHardware', 'SystemAPI') -Interval 30000 -Duration 0 -Incognito
                $statusLabel.Text = "Status: Running (Maximum Security)"
                $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
                $statusDetailsLabel.Text = "Profile: Maximum Security | Hardware + System API, 30s interval"
                $startButton.Enabled = $false
                $stopButton.Enabled = $true
                $tabControl.SelectedIndex = 0
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
            }
        })

    # Profile 3: Keyboard Only
    $profile3Button = New-Object System.Windows.Forms.Button
    $profile3Button.Text = "[Key] Keyboard Only"
    $profile3Button.Location = New-Object System.Drawing.Point(20, 160)
    $profile3Button.Size = New-Object System.Drawing.Size(220, 50)
    $profile3Button.BackColor = [System.Drawing.Color]::FromArgb(240, 255, 240)
    $quickLaunchGroupBox.Controls.Add($profile3Button)

    $profile3Desc = New-Object System.Windows.Forms.Label
    $profile3Desc.Text = "Keyboard input only (F15 key)`nNo mouse movement, 30s interval"
    $profile3Desc.Location = New-Object System.Drawing.Point(250, 160)
    $profile3Desc.Size = New-Object System.Drawing.Size(230, 40)
    $profile3Desc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $quickLaunchGroupBox.Controls.Add($profile3Desc)

    $profile3Button.Add_Click({
            try {
                Start-KeepAwake -Methods @('Keyboard') -Interval 30000 -Duration 0 -Incognito
                $statusLabel.Text = "Status: Running (Keyboard Only)"
                $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
                $statusDetailsLabel.Text = "Profile: Keyboard Only | F15 key press, 30s interval"
                $startButton.Enabled = $false
                $stopButton.Enabled = $true
                $tabControl.SelectedIndex = 0
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
            }
        })

    # Profile 4: System API Only
    $profile4Button = New-Object System.Windows.Forms.Button
    $profile4Button.Text = "[API] System API Only"
    $profile4Button.Location = New-Object System.Drawing.Point(20, 225)
    $profile4Button.Size = New-Object System.Drawing.Size(220, 50)
    $profile4Button.BackColor = [System.Drawing.Color]::FromArgb(255, 250, 230)
    $quickLaunchGroupBox.Controls.Add($profile4Button)

    $profile4Desc = New-Object System.Windows.Forms.Label
    $profile4Desc.Text = "System API only (SetThreadExecutionState)`nDirect Windows power management control"
    $profile4Desc.Location = New-Object System.Drawing.Point(250, 225)
    $profile4Desc.Size = New-Object System.Drawing.Size(230, 40)
    $profile4Desc.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $quickLaunchGroupBox.Controls.Add($profile4Desc)

    $profile4Button.Add_Click({
            try {
                Start-KeepAwake -Methods @('SystemAPI') -Interval 30000 -Duration 0 -Incognito
                $statusLabel.Text = "Status: Running (System API Only)"
                $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
                $statusDetailsLabel.Text = "Profile: System API | Direct power management control"
                $startButton.Enabled = $false
                $stopButton.Enabled = $true
                $tabControl.SelectedIndex = 0
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
            }
        })

    # Profile 5: All Methods
    $profile5Button = New-Object System.Windows.Forms.Button
    $profile5Button.Text = "[MAX] All Methods (Maximum)"
    $profile5Button.Location = New-Object System.Drawing.Point(20, 285)
    $profile5Button.Size = New-Object System.Drawing.Size(460, 25)
    $profile5Button.BackColor = [System.Drawing.Color]::FromArgb(255, 220, 220)
    $profile5Button.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $quickLaunchGroupBox.Controls.Add($profile5Button)

    $profile5Button.Add_Click({
            try {
                Start-KeepAwake -Methods @('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI') -Interval 30000 -Duration 0 -Incognito
                $statusLabel.Text = "Status: Running (All Methods)"
                $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
                $statusDetailsLabel.Text = "Profile: All Methods | Maximum reliability with all techniques"
                $startButton.Enabled = $false
                $stopButton.Enabled = $true
                $tabControl.SelectedIndex = 0
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
            }
        })
    #endregion

    #region Control Buttons
    # Start button
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Text = "> Start Jiggling"
    $startButton.Location = New-Object System.Drawing.Point(50, 445)
    $startButton.Size = New-Object System.Drawing.Size(150, 40)
    $startButton.BackColor = [System.Drawing.Color]::FromArgb(76, 175, 80)
    $startButton.ForeColor = [System.Drawing.Color]::White
    $startButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $startButton.FlatStyle = "Flat"
    $startButton.Add_Click({
            try {
                if ($tabControl.SelectedIndex -eq 0) {
                    # Basic mode
                    $interval = [int]$intervalTextBox.Text
                    $duration = [int]$durationTextBox.Text
                    $pattern = $patternComboBox.SelectedItem.ToString()
                    $incognito = $incognitoCheckbox.Checked

                    # Determine mouse methods based on selection
                    if ($mouseTypeComboBox.SelectedIndex -eq 1) {
                        # Hardware only
                        Start-KeepAwake -Methods @('MouseHardware') -Interval $interval -Duration $duration -Incognito:$incognito
                        $statusDetailsLabel.Text = "Mode: Basic | Pattern: $pattern | Method: Hardware Mouse"
                    }
                    elseif ($mouseTypeComboBox.SelectedIndex -eq 2) {
                        # Both methods
                        Start-KeepAwake -Methods @('MouseSoftware', 'MouseHardware') -Interval $interval -Duration $duration -Incognito:$incognito
                        $statusDetailsLabel.Text = "Mode: Basic | Pattern: $pattern | Method: Both (Software + Hardware)"
                    }
                    else {
                        # Software (standard)
                        Start-PSMouseJiggler -Interval $interval -MovementPattern $pattern -Duration $duration -Incognito:$incognito
                        $statusDetailsLabel.Text = "Mode: Basic | Pattern: $pattern | Method: Software Mouse"
                    }

                    $statusLabel.Text = "Status: Running"
                    $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
                }
                else {
                    # Advanced mode
                    $methods = @()
                    if ($mouseSoftwareCheckbox.Checked) { $methods += 'MouseSoftware' }
                    if ($mouseHardwareCheckbox.Checked) { $methods += 'MouseHardware' }
                    if ($keyboardCheckbox.Checked) { $methods += 'Keyboard' }
                    if ($systemApiCheckbox.Checked) { $methods += 'SystemAPI' }

                    if ($methods.Count -eq 0) {
                        [System.Windows.Forms.MessageBox]::Show("Please select at least one keep-awake method.", "Error", "OK", "Error")
                        return
                    }

                    $interval = [int]$advIntervalTextBox.Text
                    $duration = [int]$advDurationTextBox.Text
                    $incognito = $advIncognitoCheckbox.Checked

                    Start-KeepAwake -Methods $methods -Interval $interval -Duration $duration -Incognito:$incognito
                    $statusLabel.Text = "Status: Running (Advanced)"
                    $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
                    $statusDetailsLabel.Text = "Mode: Advanced | Methods: $($methods -join ', ')"
                }

                $startButton.Enabled = $false
                $stopButton.Enabled = $true

                # If incognito mode is enabled, minimize the form
                if ($incognito -or $advIncognitoCheckbox.Checked) {
                    $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
                    $form.ShowInTaskbar = $false
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
            }
        })
    $form.Controls.Add($startButton)

    # Stop button
    $stopButton = New-Object System.Windows.Forms.Button
    $stopButton.Text = "[] Stop Jiggling"
    $stopButton.Location = New-Object System.Drawing.Point(230, 445)
    $stopButton.Size = New-Object System.Drawing.Size(150, 40)
    $stopButton.Enabled = $false
    $stopButton.BackColor = [System.Drawing.Color]::FromArgb(244, 67, 54)
    $stopButton.ForeColor = [System.Drawing.Color]::White
    $stopButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $stopButton.FlatStyle = "Flat"
    $stopButton.Add_Click({
            Stop-PSMouseJiggler
            $statusLabel.Text = "Status: Stopped"
            $statusLabel.ForeColor = [System.Drawing.Color]::DarkRed
            $statusDetailsLabel.Text = "Ready to start mouse jiggling"
            $startButton.Enabled = $true
            $stopButton.Enabled = $false

            # Restore form if it was minimized
            if ($form.WindowState -eq [System.Windows.Forms.FormWindowState]::Minimized) {
                $form.WindowState = [System.Windows.Forms.FormWindowState]::Normal
                $form.ShowInTaskbar = $true
                $form.Activate()
            }
        })
    $form.Controls.Add($stopButton)

    # Help button
    $helpButton = New-Object System.Windows.Forms.Button
    $helpButton.Text = "? Help"
    $helpButton.Location = New-Object System.Drawing.Point(410, 445)
    $helpButton.Size = New-Object System.Drawing.Size(100, 40)
    $helpButton.BackColor = [System.Drawing.Color]::FromArgb(158, 158, 158)
    $helpButton.ForeColor = [System.Drawing.Color]::White
    $helpButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $helpButton.FlatStyle = "Flat"
    $helpButton.Add_Click({
            $helpMessage = @"
PSMouseJiggler Help

BASIC MODE:
- Choose movement pattern (Random recommended)
- Set interval between movements (1000ms = 1 second)
- Set duration (0 = run until stopped)
- Choose mouse input method:
  * Software: Standard method (most compatible)
  * Hardware: Low-level input (better for strict policies)
  * Both: Maximum reliability

ADVANCED MODE:
- Select multiple methods for maximum effectiveness
- Mouse methods prevent screen timeout
- Keyboard sends non-disruptive F15 key
- System API directly controls Windows power settings
- Longer interval recommended (30 seconds)

QUICK LAUNCH:
- Pre-configured profiles for common scenarios
- One-click start with optimal settings
- All profiles use incognito mode

INCOGNITO MODE:
- Minimizes window when started
- Clears console output
- Runs discreetly in background
"@
            [System.Windows.Forms.MessageBox]::Show($helpMessage, "PSMouseJiggler Help", "OK", "Information")
        })
    $form.Controls.Add($helpButton)
    #endregion

    # Timer to update status
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.Add_Tick({
            if (-not $script:JigglingActive -and $stopButton.Enabled) {
                $statusLabel.Text = "Status: Stopped"
                $statusLabel.ForeColor = [System.Drawing.Color]::DarkRed
                $statusDetailsLabel.Text = "Ready to start mouse jiggling"
                $startButton.Enabled = $true
                $stopButton.Enabled = $false

                # Restore form if it was minimized
                if ($form.WindowState -eq [System.Windows.Forms.FormWindowState]::Minimized) {
                    $form.WindowState = [System.Windows.Forms.FormWindowState]::Normal
                    $form.ShowInTaskbar = $true
                    $form.Activate()
                }
            }
        })
    $timer.Start()

    # Add form shown event to check initial state
    $form.Add_Shown({
            # Check if jiggling is already active when GUI opens
            if ($script:JigglingActive) {
                $statusLabel.Text = "Status: Running (Started from Console)"
                $statusLabel.ForeColor = [System.Drawing.Color]::DarkGreen
                $statusDetailsLabel.Text = "Started from command line - use Stop button to halt"
                $startButton.Enabled = $false
                $stopButton.Enabled = $true

                # Restore form if it was minimized
                if ($form.WindowState -eq [System.Windows.Forms.FormWindowState]::Minimized) {
                    $form.WindowState = [System.Drawing.Color]::Normal
                    $form.ShowInTaskbar = $true
                }
            }
            $form.Activate()
        })

    $form.Add_FormClosed({ $timer.Stop() })
    [void]$form.ShowDialog()
}

<#
.SYNOPSIS
    Displays a cross-platform Terminal User Interface (TUI) for PSMouseJiggler.

.DESCRIPTION
    Shows a text-based interactive interface using Terminal.Gui that works on all platforms.
    Provides controls for:
    - Starting/stopping mouse jiggling with different patterns (Random, Horizontal, Vertical, Circular)
    - Configuring interval and duration
    - Incognito mode checkbox (minimizes window and clears console output for discrete operation)
    - Selecting individual keep-awake methods (Software Mouse, Hardware Mouse, Keyboard, System API)
    - Platform-specific method availability based on OS capabilities

    Requires the Terminal.Gui PowerShell module (provided by Microsoft.PowerShell.ConsoleGuiTools):
    Install-Module -Name Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser

.EXAMPLE
    Show-PSMouseJigglerTUI
    Displays the interactive TUI interface with all available controls.

.NOTES
    - Works on Windows, Linux, and macOS with PowerShell 7+
    - Available keep-awake methods vary by platform:
      * Windows: Software Mouse, Hardware Mouse, Keyboard, System API
      * Linux: Software Mouse, System API (systemd-inhibit)
      * macOS: Software Mouse, System API (caffeinate)
    - Press ESC to quit, TAB to navigate, SPACE to toggle checkboxes, ENTER to activate buttons
    - Falls back to command-line instructions if Terminal.Gui is not available
    - Requires Microsoft.PowerShell.ConsoleGuiTools module (includes Terminal.Gui)
#>
function Show-PSMouseJigglerTUI {
    [CmdletBinding()]
    param()

    # Check if Terminal.Gui is available (via ConsoleGuiTools or standalone)
    $hasConsoleGuiTools = Get-Module -ListAvailable -Name Microsoft.PowerShell.ConsoleGuiTools
    $hasTerminalGui = Get-Module -ListAvailable -Name Terminal.Gui

    if (-not $hasConsoleGuiTools -and -not $hasTerminalGui) {
        Write-Host @"

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   Terminal.Gui Module Not Found                              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

The Terminal.Gui module is required for the TUI interface.

RECOMMENDED: Install Microsoft.PowerShell.ConsoleGuiTools (includes Terminal.Gui):
  Install-Module -Name Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser

Alternative: Install Terminal.Gui directly:
  Install-Module -Name Terminal.Gui -Scope CurrentUser

After installation, restart your PowerShell session and try again.

In the meantime, you can use PSMouseJiggler from the command line:
  Start-PSMouseJiggler -Interval 1000 -MovementPattern Random
  Stop-PSMouseJiggler

For platform-specific information:
  Get-OperatingSystemPlatform
  Test-PlatformCapability -Capability GUI
  Show-DependencyInstallInstructions

"@ -ForegroundColor Yellow
        return
    }

    # Load Terminal.Gui assembly
    try {
        # Try to load from ConsoleGuiTools first (recommended)
        if ($hasConsoleGuiTools) {
            $consoleGuiToolsPath = (Get-Module -ListAvailable Microsoft.PowerShell.ConsoleGuiTools | Select-Object -First 1).ModuleBase
            $terminalGuiDll = Join-Path $consoleGuiToolsPath "Terminal.Gui.dll"
            if (Test-Path $terminalGuiDll) {
                Add-Type -Path $terminalGuiDll -ErrorAction Stop
            }
            else {
                throw "Terminal.Gui.dll not found in ConsoleGuiTools module"
            }
        }
        # Fall back to standalone Terminal.Gui module
        elseif ($hasTerminalGui) {
            Import-Module Terminal.Gui -ErrorAction Stop
        }
    }
    catch {
        Write-Error "Failed to load Terminal.Gui: $_"
        Write-Host "Try reinstalling: Install-Module -Name Microsoft.PowerShell.ConsoleGuiTools -Force" -ForegroundColor Yellow
        return
    }

    # Initialize Terminal.Gui
    [Terminal.Gui.Application]::Init()

    try {
        # Create main window
        $top = [Terminal.Gui.Application]::Top

        # Create window
        $win = [Terminal.Gui.Window]@{
            X      = 0
            Y      = 1
            Width  = [Terminal.Gui.Dim]::Fill()
            Height = [Terminal.Gui.Dim]::Fill()
            Title  = "PSMouseJiggler v2.0.0 - Cross-Platform Mouse Jiggler"
        }

        # Status frame
        $statusFrame = [Terminal.Gui.FrameView]@{
            X      = 1
            Y      = 1
            Width  = [Terminal.Gui.Dim]::Fill() - 2
            Height = 3
            Title  = "Status"
        }

        $statusLabel = [Terminal.Gui.Label]@{
            X    = 1
            Y    = 0
            Text = "Stopped"
        }
        $statusFrame.Add($statusLabel)
        $win.Add($statusFrame)

        # Platform info frame
        $platformFrame = [Terminal.Gui.FrameView]@{
            X      = 1
            Y      = 4
            Width  = [Terminal.Gui.Dim]::Fill() - 2
            Height = 3
            Title  = "Platform"
        }

        $platform = Get-OperatingSystemPlatform
        $platformLabel = [Terminal.Gui.Label]@{
            X    = 1
            Y    = 0
            Text = "OS: $platform | PowerShell: $($PSVersionTable.PSVersion)"
        }
        $platformFrame.Add($platformLabel)
        $win.Add($platformFrame)

        # Configuration frame
        $configFrame = [Terminal.Gui.FrameView]@{
            X      = 1
            Y      = 7
            Width  = [Terminal.Gui.Dim]::Fill() - 2
            Height = 10
            Title  = "Mouse Jiggler Configuration"
        }

        # Interval
        $intervalLabel = [Terminal.Gui.Label]@{
            X    = 1
            Y    = 0
            Text = "Interval (ms):"
        }
        $configFrame.Add($intervalLabel)

        $intervalField = [Terminal.Gui.TextField]@{
            X     = 20
            Y     = 0
            Width = 10
            Text  = "1000"
        }
        $configFrame.Add($intervalField)

        # Pattern
        $patternLabel = [Terminal.Gui.Label]@{
            X    = 1
            Y    = 2
            Text = "Movement Pattern:"
        }
        $configFrame.Add($patternLabel)

        $patternRadio = [Terminal.Gui.RadioGroup]@{
            X            = 20
            Y            = 2
            Width        = 20
            Height       = 4
            RadioLabels  = @('Random', 'Horizontal', 'Vertical', 'Circular')
            SelectedItem = 0
        }
        $configFrame.Add($patternRadio)

        # Duration
        $durationLabel = [Terminal.Gui.Label]@{
            X    = 1
            Y    = 7
            Text = "Duration (sec, 0=indefinite):"
        }
        $configFrame.Add($durationLabel)

        $durationField = [Terminal.Gui.TextField]@{
            X     = 32
            Y     = 7
            Width = 10
            Text  = "0"
        }
        $configFrame.Add($durationField)

        # Incognito mode checkbox
        $incognitoCheckbox = [Terminal.Gui.CheckBox]@{
            X       = 45
            Y       = 7
            Text    = "Incognito Mode"
            Checked = $false
        }
        $configFrame.Add($incognitoCheckbox)

        $win.Add($configFrame)

        # Keep-Awake Methods frame
        $methodsFrame = [Terminal.Gui.FrameView]@{
            X      = 1
            Y      = 17
            Width  = [Terminal.Gui.Dim]::Fill() - 2
            Height = 7
            Title  = "Keep-Awake Methods (for Keep Awake button)"
        }

        $methodsLabel = [Terminal.Gui.Label]@{
            X    = 1
            Y    = 0
            Text = "Select methods to use:"
        }
        $methodsFrame.Add($methodsLabel)

        # Detect available methods based on platform
        $availableMethods = @()

        # Mouse movements available on all platforms with appropriate tools
        if ((Test-PlatformCapability -Capability XDoTool) -or
            (Test-PlatformCapability -Capability YDoTool) -or
            (Test-PlatformCapability -Capability CliClick) -or
            (Test-PlatformCapability -Capability WindowsAPI)) {
            $availableMethods += 'MouseSoftware'
        }

        # Windows-specific methods
        if (Test-PlatformCapability -Capability WindowsAPI) {
            $availableMethods += 'MouseHardware'
            $availableMethods += 'Keyboard'
            $availableMethods += 'SystemAPI'
        }

        # Linux system API (systemd-inhibit)
        if (Test-PlatformCapability -Capability SystemdInhibit) {
            if (-not ($availableMethods -contains 'SystemAPI')) {
                $availableMethods += 'SystemAPI'
            }
        }

        # macOS system API (caffeinate)
        if (Test-PlatformCapability -Capability Caffeinate) {
            if (-not ($availableMethods -contains 'SystemAPI')) {
                $availableMethods += 'SystemAPI'
            }
        }

        # Create checkboxes for available methods
        $methodCheckboxes = @{}
        $yPos = 1

        if ($availableMethods -contains 'MouseSoftware') {
            $chk = [Terminal.Gui.CheckBox]@{
                X       = 2
                Y       = $yPos
                Text    = "Software Mouse Movements"
                Checked = $true
            }
            $methodsFrame.Add($chk)
            $methodCheckboxes['MouseSoftware'] = $chk
            $yPos++
        }

        if ($availableMethods -contains 'MouseHardware') {
            $chk = [Terminal.Gui.CheckBox]@{
                X       = 2
                Y       = $yPos
                Text    = "Hardware Mouse Input"
                Checked = $false
            }
            $methodsFrame.Add($chk)
            $methodCheckboxes['MouseHardware'] = $chk
            $yPos++
        }

        if ($availableMethods -contains 'Keyboard') {
            $chk = [Terminal.Gui.CheckBox]@{
                X       = 2
                Y       = $yPos
                Text    = "Keyboard Input (F15)"
                Checked = $false
            }
            $methodsFrame.Add($chk)
            $methodCheckboxes['Keyboard'] = $chk
            $yPos++
        }

        if ($availableMethods -contains 'SystemAPI') {
            $methodLabel = "System API"
            if ($platform -eq 'Windows') {
                $methodLabel = "System API (SetThreadExecutionState)"
            }
            elseif ($platform -eq 'Linux') {
                $methodLabel = "System API (systemd-inhibit)"
            }
            elseif ($platform -eq 'macOS') {
                $methodLabel = "System API (caffeinate)"
            }

            $chk = [Terminal.Gui.CheckBox]@{
                X       = 2
                Y       = $yPos
                Text    = $methodLabel
                Checked = $true
            }
            $methodsFrame.Add($chk)
            $methodCheckboxes['SystemAPI'] = $chk
        }

        $win.Add($methodsFrame)

        # Buttons frame
        $buttonFrame = [Terminal.Gui.FrameView]@{
            X      = 1
            Y      = 24
            Width  = [Terminal.Gui.Dim]::Fill() - 2
            Height = 5
            Title  = "Controls"
        }

        # Start button
        $startButton = [Terminal.Gui.Button]@{
            X    = 2
            Y    = 1
            Text = "Start"
        }

        $startButton.add_Clicked({
                try {
                    $interval = [int]$intervalField.Text.ToString()
                    $pattern = @('Random', 'Horizontal', 'Vertical', 'Circular')[$patternRadio.SelectedItem]
                    $duration = [int]$durationField.Text.ToString()
                    $incognito = $incognitoCheckbox.Checked

                    if ($incognito) {
                        Start-PSMouseJiggler -Interval $interval -MovementPattern $pattern -Duration $duration -Incognito
                    }
                    else {
                        Start-PSMouseJiggler -Interval $interval -MovementPattern $pattern -Duration $duration
                    }

                    $modeText = if ($incognito) { " (Incognito)" } else { "" }
                    $statusLabel.Text = "Running - Pattern: $pattern, Interval: ${interval}ms$modeText"
                    $startButton.Enabled = $false
                    $stopButton.Enabled = $true
                }
                catch {
                    $statusLabel.Text = "Error: $($_.Exception.Message)"
                }
            })
        $buttonFrame.Add($startButton)

        # Stop button
        $stopButton = [Terminal.Gui.Button]@{
            X       = 12
            Y       = 1
            Text    = "Stop"
            Enabled = $false
        }

        $stopButton.add_Clicked({
                try {
                    Stop-PSMouseJiggler
                    $statusLabel.Text = "Stopped"
                    $startButton.Enabled = $true
                    $stopButton.Enabled = $false
                }
                catch {
                    $statusLabel.Text = "Error: $($_.Exception.Message)"
                }
            })
        $buttonFrame.Add($stopButton)

        # Keep Awake button
        $keepAwakeButton = [Terminal.Gui.Button]@{
            X    = 22
            Y    = 1
            Text = "Keep Awake"
        }

        $keepAwakeButton.add_Clicked({
                try {
                    $interval = [int]$intervalField.Text.ToString()
                    $duration = [int]$durationField.Text.ToString()
                    $incognito = $incognitoCheckbox.Checked

                    # Collect selected methods from checkboxes
                    $selectedMethods = @()
                    foreach ($methodName in $methodCheckboxes.Keys) {
                        if ($methodCheckboxes[$methodName].Checked) {
                            $selectedMethods += $methodName
                        }
                    }

                    if ($selectedMethods.Count -eq 0) {
                        $statusLabel.Text = "Error: Please select at least one keep-awake method"
                        return
                    }

                    if ($incognito) {
                        Start-KeepAwake -Methods $selectedMethods -Interval $interval -Duration $duration -Incognito
                    }
                    else {
                        Start-KeepAwake -Methods $selectedMethods -Interval $interval -Duration $duration
                    }

                    $methodsList = $selectedMethods -join ', '
                    $modeText = if ($incognito) { " (Incognito)" } else { "" }
                    $statusLabel.Text = "Keep Awake Running - Methods: $methodsList$modeText"
                    $startButton.Enabled = $false
                    $stopButton.Enabled = $true
                }
                catch {
                    $statusLabel.Text = "Error: $($_.Exception.Message)"
                }
            })
        $buttonFrame.Add($keepAwakeButton)

        # Quit button
        $quitButton = [Terminal.Gui.Button]@{
            X    = 38
            Y    = 1
            Text = "Quit"
        }

        $quitButton.add_Clicked({
                if ($script:JigglingActive) {
                    Stop-PSMouseJiggler
                }
                [Terminal.Gui.Application]::RequestStop()
            })
        $buttonFrame.Add($quitButton)

        $win.Add($buttonFrame)

        # Help text
        $helpLabel = [Terminal.Gui.Label]@{
            X    = 1
            Y    = 29
            Text = "Press ESC to quit | TAB to navigate | SPACE to toggle checkbox | ENTER to activate button"
        }
        $win.Add($helpLabel)

        # Add window to top
        $top.Add($win)

        # Handle ESC key to quit
        $top.add_KeyPress({
                param($e)
                if ($e.KeyEvent.Key -eq [Terminal.Gui.Key]::Esc) {
                    if ($script:JigglingActive) {
                        Stop-PSMouseJiggler
                    }
                    [Terminal.Gui.Application]::RequestStop()
                }
            })

        # Run the application
        [Terminal.Gui.Application]::Run()
    }
    finally {
        # Cleanup
        [Terminal.Gui.Application]::Shutdown()
    }
}

#endregion

#region Configuration Functions

<#
.SYNOPSIS
    Gets configuration settings from the config file.

.DESCRIPTION
    Loads configuration from the default.json file or creates default settings.

.PARAMETER ConfigFilePath
    Path to the configuration file. If not specified, uses the default location.

.EXAMPLE
    $config = Get-Configuration
    Gets the current configuration.
#>
function Get-Configuration {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ConfigFilePath
    )

    if (-not $ConfigFilePath) {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        $ConfigFilePath = Join-Path $moduleRoot "config\default.json"
    }

    if (Test-Path $ConfigFilePath) {
        try {
            $config = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
            Write-Verbose "Configuration loaded from $ConfigFilePath"
            return $config
        }
        catch {
            Write-Warning "Error loading configuration: $($_.Exception.Message)"
            return Get-DefaultConfiguration
        }
    }
    else {
        Write-Verbose "Configuration file not found, using defaults"
        return Get-DefaultConfiguration
    }
}

<#
.SYNOPSIS
    Saves configuration settings to the config file.

.DESCRIPTION
    Saves the provided configuration object to the JSON config file.

.PARAMETER Configuration
    The configuration object to save.

.PARAMETER ConfigFilePath
    Path to save the configuration file.

.EXAMPLE
    Save-Configuration -Configuration $config
    Saves the configuration to the default location.
#>
function Save-Configuration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$Configuration,

        [Parameter()]
        [string]$ConfigFilePath
    )

    if (-not $ConfigFilePath) {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        $ConfigFilePath = Join-Path $moduleRoot "config\default.json"
    }

    try {
        $configDir = Split-Path -Parent $ConfigFilePath
        if (-not (Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }
        $Configuration | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigFilePath -Force
        Write-Verbose "Configuration saved to $ConfigFilePath"
    }
    catch {
        Write-Error "Failed to save configuration: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Updates a specific configuration setting.

.DESCRIPTION
    Updates a single configuration key with a new value.

.PARAMETER Key
    The configuration key to update.

.PARAMETER Value
    The new value for the key.

.PARAMETER ConfigFilePath
    Path to the configuration file.

.EXAMPLE
    Update-Configuration -Key "MovementSpeed" -Value 150
    Updates the MovementSpeed setting to 150.
#>
function Update-Configuration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [object]$Value,

        [Parameter()]
        [string]$ConfigFilePath
    )

    $config = Get-Configuration -ConfigFilePath $ConfigFilePath
    $config | Add-Member -MemberType NoteProperty -Name $Key -Value $Value -Force
    Save-Configuration -Configuration $config -ConfigFilePath $ConfigFilePath
}

<#
.SYNOPSIS
    Resets configuration to default values.

.DESCRIPTION
    Creates a new configuration file with default settings.

.PARAMETER ConfigFilePath
    Path to the configuration file.

.EXAMPLE
    Reset-Configuration
    Resets configuration to defaults.
#>
function Reset-Configuration {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ConfigFilePath
    )

    $defaultConfig = Get-DefaultConfiguration
    Save-Configuration -Configuration $defaultConfig -ConfigFilePath $ConfigFilePath
    Write-Host "Configuration reset to defaults" -ForegroundColor Green
}

function Get-DefaultConfiguration {
    return [PSCustomObject]@{
        MovementSpeed        = 1000
        MovementPattern      = "Random"
        JiggleInterval       = 1000
        EnableScheduledTasks = $false
        ScheduledTimes       = @()
        AutoJiggle           = $false
        Duration             = 0
        GuiSettings          = @{
            WindowPosition   = @{
                X = 0
                Y = 0
            }
            RememberSettings = $true
        }
    }
}

#endregion

#region Movement Pattern Functions

<#
.SYNOPSIS
    Gets a random movement pattern function.

.DESCRIPTION
    Returns a scriptblock that represents a random movement pattern.

.EXAMPLE
    $pattern = Get-RandomMovementPattern
    & $pattern
#>
function Get-RandomMovementPattern {
    [CmdletBinding()]
    param()

    $patterns = @(
        {
            $xOffset = Get-Random -Minimum -10 -Maximum 11
            $yOffset = Get-Random -Minimum -10 -Maximum 11
            Move-Mouse -X $xOffset -Y $yOffset
        },
        {
            $xOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
            Move-Mouse -X $xOffset -Y 0
        },
        {
            $yOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
            Move-Mouse -X 0 -Y $yOffset
        },
        {
            $angle = (Get-Date).Millisecond / 1000 * 2 * [Math]::PI
            $xOffset = [Math]::Round([Math]::Sin($angle) * 10)
            $yOffset = [Math]::Round([Math]::Cos($angle) * 10)
            Move-Mouse -X $xOffset -Y $yOffset
        }
    )
    return Get-Random -InputObject $patterns
}

<#
.SYNOPSIS
    Moves the mouse cursor by relative coordinates.

.DESCRIPTION
    Moves the mouse cursor by the specified X and Y offsets.

.PARAMETER X
    Horizontal offset in pixels.

.PARAMETER Y
    Vertical offset in pixels.

.EXAMPLE
    Move-Mouse -X 10 -Y -5
    Moves the mouse 10 pixels right and 5 pixels up.
#>
<#
.SYNOPSIS
    Moves the mouse cursor by a relative offset.

.DESCRIPTION
    Cross-platform wrapper that moves the mouse cursor by the specified X and Y offsets.
    Automatically detects the operating system and dispatches to the appropriate platform-specific implementation.

.PARAMETER X
    Horizontal offset in pixels (positive = right, negative = left).

.PARAMETER Y
    Vertical offset in pixels (positive = down, negative = up).

.EXAMPLE
    Move-Mouse -X 10 -Y 5
    Moves the mouse cursor 10 pixels right and 5 pixels down.

.NOTES
    - Windows: Uses System.Windows.Forms.Cursor
    - Linux: Uses xdotool or ydotool
    - macOS: Uses cliclick
#>
function Move-Mouse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$X,

        [Parameter(Mandatory)]
        [int]$Y
    )

    $platform = Get-OperatingSystemPlatform

    Write-Verbose "Moving mouse on platform: $platform (X: $X, Y: $Y)"

    switch ($platform) {
        'Windows' {
            Move-Mouse-Windows -X $X -Y $Y
        }
        'Linux' {
            if (-not (Test-PlatformCapability -Capability 'XDoTool')) {
                Write-Error "Linux support requires xdotool or ydotool."
                return
            }
            Move-Mouse-Linux -X $X -Y $Y
        }
        'macOS' {
            if (-not (Test-PlatformCapability -Capability 'CliClick')) {
                Write-Error "macOS support requires cliclick."
                return
            }
            Move-Mouse-MacOS -X $X -Y $Y
        }
        default {
            Write-Error "Unsupported platform: $platform"
        }
    }
}

<#
.SYNOPSIS
    Starts a movement pattern for a specified duration.

.DESCRIPTION
    Executes random movement patterns for the specified duration.

.PARAMETER DurationInSeconds
    Duration to run movement patterns in seconds.

.EXAMPLE
    Start-MovementPattern -DurationInSeconds 60
    Runs movement patterns for 60 seconds.
#>
function Start-MovementPattern {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$DurationInSeconds
    )

    $endTime = (Get-Date).AddSeconds($DurationInSeconds)
    Write-Host "Starting movement pattern for $DurationInSeconds seconds" -ForegroundColor Green

    while ((Get-Date) -lt $endTime) {
        $pattern = Get-RandomMovementPattern
        & $pattern
        Start-Sleep -Milliseconds 1000
    }

    Write-Host "Movement pattern completed" -ForegroundColor Green
}

<#
.SYNOPSIS
    Stops the movement pattern.

.DESCRIPTION
    Placeholder function for stopping movement patterns.

.EXAMPLE
    Stop-MovementPattern
#>
function Stop-MovementPattern {
    [CmdletBinding()]
    param()

    Write-Host "Movement pattern stopped." -ForegroundColor Yellow
}

#endregion

#region Scheduled Task Functions

<#
.SYNOPSIS
    Gets scheduled tasks related to PSMouseJiggler.

.DESCRIPTION
    Retrieves scheduled tasks that match the specified task name pattern.

.PARAMETER TaskName
    Name or pattern to search for in task names.

.EXAMPLE
    Get-PSMJScheduledTasks -TaskName "PSMouseJiggler"
    Gets all tasks with "PSMouseJiggler" in the name.
#>
function Get-PSMJScheduledTasks {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$TaskName = "PSMouseJiggler*"
    )

    try {
        $tasks = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        return $tasks
    }
    catch {
        Write-Warning "Error getting scheduled tasks: $($_.Exception.Message)"
        return @()
    }
}

<#
.SYNOPSIS
    Creates a new scheduled task for PSMouseJiggler.

.DESCRIPTION
    Creates a scheduled task to run PSMouseJiggler at specified times.

.PARAMETER TaskName
    Name for the scheduled task.

.PARAMETER Action
    Command or script to execute.

.PARAMETER StartTime
    When to start the task.

.PARAMETER RepeatIntervalMinutes
    How often to repeat the task in minutes.

.EXAMPLE
    New-PSMJScheduledTask -TaskName "MyJiggler" -Action "powershell.exe -Command 'Start-PSMouseJiggler'" -StartTime (Get-Date).AddMinutes(5)
    Creates a task to start jiggling in 5 minutes.
#>
function New-PSMJScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName,

        [Parameter(Mandatory)]
        [string]$Action,

        [Parameter(Mandatory)]
        [DateTime]$StartTime,

        [Parameter()]
        [int]$RepeatIntervalMinutes = 0
    )

    try {
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command `"$Action`""

        if ($RepeatIntervalMinutes -gt 0) {
            $trigger = New-ScheduledTaskTrigger -Once -At $StartTime -RepetitionInterval (New-TimeSpan -Minutes $RepeatIntervalMinutes)
        }
        else {
            $trigger = New-ScheduledTaskTrigger -Once -At $StartTime
        }

        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Force

        Write-Host "Scheduled task '$TaskName' created successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create scheduled task: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Removes a scheduled task.

.DESCRIPTION
    Removes the specified scheduled task.

.PARAMETER TaskName
    Name of the task to remove.

.EXAMPLE
    Remove-PSMJScheduledTask -TaskName "MyJiggler"
    Removes the MyJiggler scheduled task.
#>
function Remove-PSMJScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName
    )

    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Scheduled task '$TaskName' removed" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to remove scheduled task: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Starts a scheduled task.

.DESCRIPTION
    Manually starts the specified scheduled task.

.PARAMETER TaskName
    Name of the task to start.

.EXAMPLE
    Start-PSMJScheduledTask -TaskName "MyJiggler"
    Starts the MyJiggler scheduled task.
#>
function Start-PSMJScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName
    )

    try {
        Start-ScheduledTask -TaskName $TaskName
        Write-Host "Scheduled task '$TaskName' started" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to start scheduled task: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Stops a scheduled task.

.DESCRIPTION
    Stops the specified running scheduled task.

.PARAMETER TaskName
    Name of the task to stop.

.EXAMPLE
    Stop-PSMJScheduledTask -TaskName "MyJiggler"
    Stops the MyJiggler scheduled task.
#>
function Stop-PSMJScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName
    )

    try {
        Stop-ScheduledTask -TaskName $TaskName
        Write-Host "Scheduled task '$TaskName' stopped" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to stop scheduled task: $($_.Exception.Message)"
    }
}

#endregion

#region Advanced Wake Prevention Functions

<#
.SYNOPSIS
    Prevents system idle using Windows SetThreadExecutionState API.

.DESCRIPTION
    Uses P/Invoke to call the SetThreadExecutionState Windows API to prevent the system from sleeping.

.PARAMETER Duration
    Duration in seconds to prevent idle. Default is 0 (continuous).

.EXAMPLE
    Prevent-SystemIdle -Duration 3600
    Prevents the system from going idle for 1 hour.
#>
function Prevent-SystemIdle {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$Duration = 0
    )

    # Define the P/Invoke signature for SetThreadExecutionState
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public static class DisplayState {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern uint SetThreadExecutionState(uint esFlags);

        public const uint ES_CONTINUOUS = 0x80000000;
        public const uint ES_SYSTEM_REQUIRED = 0x00000001;
        public const uint ES_DISPLAY_REQUIRED = 0x00000002;
        public const uint ES_AWAYMODE_REQUIRED = 0x00000040;
    }
"@

    # Prevent system sleep and display sleep
    [DisplayState]::SetThreadExecutionState(
        [DisplayState]::ES_CONTINUOUS -bor
        [DisplayState]::ES_SYSTEM_REQUIRED -bor
        [DisplayState]::ES_DISPLAY_REQUIRED) | Out-Null

    Write-Verbose "System idle prevention activated"

    if ($Duration -gt 0) {
        Start-Sleep -Seconds $Duration
        # Reset to normal state
        [DisplayState]::SetThreadExecutionState([DisplayState]::ES_CONTINUOUS) | Out-Null
        Write-Verbose "System idle prevention deactivated after $Duration seconds"
    }
}

<#
.SYNOPSIS
    Simulates keyboard input using hardware-level API.

.DESCRIPTION
    Uses SendInput Windows API to simulate hardware-level keyboard events.

.PARAMETER Key
    The key to simulate. Defaults to a non-disruptive key (F15).

.EXAMPLE
    Send-KeyboardInput
    Sends a function key press that's typically not mapped to any action.
#>
function Send-KeyboardInput {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Key = "{F15}"
    )

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait($Key)
    Write-Verbose "Sent keyboard input: $Key"
}

<#
.SYNOPSIS
    Simulates mouse input using hardware-level API.

.DESCRIPTION
    Uses SendInput Windows API to simulate hardware-level mouse events.

.PARAMETER XOffset
    Horizontal movement offset.

.PARAMETER YOffset
    Vertical movement offset.

.EXAMPLE
    Send-MouseInput -XOffset 5 -YOffset -5
    Simulates mouse movement using hardware-level API.
#>
function Send-MouseInput {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$XOffset = 0,

        [Parameter()]
        [int]$YOffset = 0
    )

    # Define the SendInput API
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public static class MouseSimulator {
        [StructLayout(LayoutKind.Sequential)]
        public struct MOUSEINPUT {
            public int dx;
            public int dy;
            public uint mouseData;
            public uint dwFlags;
            public uint time;
            public IntPtr dwExtraInfo;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct INPUT {
            public uint type;
            public MOUSEINPUT mi;
        }

        [DllImport("user32.dll", SetLastError = true)]
        public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

        public const int INPUT_MOUSE = 0;
        public const int MOUSEEVENTF_MOVE = 0x0001;
        public const int MOUSEEVENTF_ABSOLUTE = 0x8000;
    }
"@

    $mouseInputStructure = New-Object MouseSimulator+INPUT
    $mouseInputStructure.type = [MouseSimulator]::INPUT_MOUSE
    $mouseInputStructure.mi.dx = $XOffset
    $mouseInputStructure.mi.dy = $YOffset
    $mouseInputStructure.mi.dwFlags = [MouseSimulator]::MOUSEEVENTF_MOVE
    $mouseInputStructure.mi.time = 0
    $mouseInputStructure.mi.dwExtraInfo = [IntPtr]::Zero

    $inputArray = @($mouseInputStructure)
    $result = [MouseSimulator]::SendInput(1, $inputArray, [System.Runtime.InteropServices.Marshal]::SizeOf([type][MouseSimulator+INPUT]))

    if ($result -eq 0) {
        Write-Error "SendInput failed to send mouse event. Win32 error: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"
    }

    Write-Verbose "Sent hardware-level mouse movement: X=$XOffset, Y=$YOffset"
}

<#
.SYNOPSIS
    Keeps the system awake using multiple methods.

.DESCRIPTION
    Combines various techniques to prevent system sleep, including
    mouse movements, keyboard input, and Windows API calls.

.PARAMETER Methods
    Array of methods to use. Default includes all available methods.

.PARAMETER Interval
    Time in milliseconds between actions. Default is 30000 (30 seconds).

.PARAMETER Duration
    Duration in seconds to run. Default is 0 (indefinite).

.PARAMETER Incognito
When enabled, clears the console after starting to maintain privacy/discretion.

.EXAMPLE
    Start-KeepAwake -Interval 60000 -Duration 3600
    Keeps the system awake for 1 hour, performing actions every 60 seconds.
#>
<#
.SYNOPSIS
    Starts keep-awake functionality with multiple methods.

.DESCRIPTION
    Cross-platform wrapper that starts keep-awake functionality using various methods to prevent system idle.
    Automatically detects the operating system and dispatches to the appropriate platform-specific implementation.

    - Windows: Supports MouseSoftware, MouseHardware, Keyboard, SystemAPI methods
    - Linux: Supports MouseSoftware (via xdotool), SystemAPI (via systemd-inhibit)
    - macOS: Supports MouseSoftware (via cliclick), SystemAPI (via caffeinate)

.PARAMETER Methods
    Array of methods to use for keeping system awake.
    Valid values: 'MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI', 'All'
    Note: Not all methods are available on all platforms.

.PARAMETER Interval
    Time in milliseconds between keep-awake actions. Default is 30000ms (30 seconds).

.PARAMETER Duration
    Duration in seconds to run keep-awake. If not specified, runs indefinitely until stopped.

.PARAMETER Incognito
    When enabled, clears the console after starting to maintain privacy/discretion.

.EXAMPLE
    Start-KeepAwake -Methods 'All'
    Starts keep-awake with all available methods on the detected platform.

.EXAMPLE
    Start-KeepAwake -Methods 'SystemAPI' -Duration 3600
    Uses system API to prevent sleep for 1 hour.

.NOTES
    Requires PowerShell 7+ for Linux and macOS support.
    Windows PowerShell 5.1 is supported on Windows only.
    Available methods vary by platform.
#>
function Start-KeepAwake {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('MouseSoftware', 'MouseHardware', 'Keyboard', 'SystemAPI', 'All')]
        [string[]]$Methods = @('All'),

        [Parameter()]
        [int]$Interval = 30000,

        [Parameter()]
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
    )

    $platform = Get-OperatingSystemPlatform

    Write-Verbose "Starting keep-awake on platform: $platform with methods: $($Methods -join ', ')"

    switch ($platform) {
        'Windows' {
            Start-KeepAwake-Windows @PSBoundParameters
        }
        'Linux' {
            # Check for required tools
            if (-not (Test-PlatformCapability -Capability 'XDoTool') -and $Methods -contains 'MouseSoftware') {
                Write-Warning "Mouse methods require xdotool or ydotool on Linux."
            }
            if (-not (Test-PlatformCapability -Capability 'SystemdInhibit') -and $Methods -contains 'SystemAPI') {
                Write-Warning "SystemAPI method requires systemd-inhibit on Linux."
            }
            Start-KeepAwake-Linux @PSBoundParameters
        }
        'macOS' {
            # Check for required tools
            if (-not (Test-PlatformCapability -Capability 'CliClick') -and $Methods -contains 'MouseSoftware') {
                Write-Warning "Mouse methods require cliclick on macOS."
            }
            if (-not (Test-PlatformCapability -Capability 'Caffeinate')) {
                Write-Warning "SystemAPI method uses caffeinate (should be built-in on macOS)."
            }
            Start-KeepAwake-MacOS @PSBoundParameters
        }
        default {
            Write-Error "Unsupported platform: $platform"
        }
    }
}

#endregion

# Module cleanup when module is removed
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    if ($script:JigglingActive) {
        if ($script:JigglingJob) {
            # Add type checking to handle both real jobs and mock objects used in testing
            if ($script:JigglingJob -is [System.Management.Automation.Job]) {
                Stop-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
                Remove-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
            }
            else {
                Write-Verbose "Cleaning up non-Job object (likely a test mock)"
            }
            $script:JigglingJob = $null
        }
        $script:JigglingActive = $false
    }
}

# Export module members (this is also defined in the manifest for best practice)
Export-ModuleMember -Function @(
    # Core Functions
    'Start-PSMouseJiggler',
    'Stop-PSMouseJiggler',
    'Get-NewMousePosition',
    'Move-Mouse',
    'Start-MovementPattern',
    'Stop-MovementPattern',
    'Start-KeepAwake',

    # GUI/TUI Functions
    'Show-PSMouseJigglerGUI',
    'Show-PSMouseJigglerTUI',

    # Configuration Functions
    'Get-Configuration',
    'Save-Configuration',
    'Update-Configuration',
    'Reset-Configuration',
    'Get-RandomMovementPattern',

    # Scheduled Task Functions
    'Get-PSMJScheduledTasks',
    'New-PSMJScheduledTask',
    'Remove-PSMJScheduledTask',
    'Start-PSMJScheduledTask',
    'Stop-PSMJScheduledTask',

    # Keep-Awake Methods (Windows-specific)
    'Prevent-SystemIdle',
    'Send-KeyboardInput',
    'Send-MouseInput',

    # Platform Detection Helpers (v2.0.0)
    'Get-OperatingSystemPlatform',
    'Test-PlatformCapability',
    'Show-DependencyInstallInstructions'
)