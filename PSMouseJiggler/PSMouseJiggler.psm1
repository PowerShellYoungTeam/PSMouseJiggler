#
# PSMouseJiggler Module
# A PowerShell module to simulate mouse movements and prevent system idle
#

# Check for required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global variable to track jiggling state
$script:JigglingJob = $null
$script:JigglingActive = $false

#region Core Mouse Jiggling Functions

<#
.SYNOPSIS
    Starts the PSMouseJiggler to simulate mouse movements.

.DESCRIPTION
    Starts mouse jiggling with specified interval and movement pattern to prevent the system from going idle.

.PARAMETER Interval
    Time in milliseconds between mouse movements. Default is 1000ms.

.PARAMETER MovementPattern
    The pattern for mouse movement. Valid values: 'Random', 'Horizontal', 'Vertical', 'Circular'. Default is 'Random'.

.PARAMETER Duration
    Duration in seconds to run the jiggler. If not specified, runs indefinitely until stopped.

.EXAMPLE
    Start-PSMouseJiggler
    Starts mouse jiggling with default settings.

.EXAMPLE
    Start-PSMouseJiggler -Interval 2000 -MovementPattern 'Circular' -Duration 300
    Starts mouse jiggling every 2 seconds using circular pattern for 5 minutes.
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
        [int]$Duration = 0
    )

    if ($script:JigglingActive) {
        Write-Warning "PSMouseJiggler is already running. Use Stop-PSMouseJiggler to stop it first."
        return
    }

    Write-Host "Starting PSMouseJiggler with $MovementPattern pattern, interval: $Interval ms" -ForegroundColor Green

    $script:JigglingActive = $true
    $startTime = Get-Date

    $script:JigglingJob = Start-Job -ScriptBlock {
        param($Interval, $MovementPattern, $Duration, $StartTime)

        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $endTime = if ($Duration -gt 0) { $StartTime.AddSeconds($Duration) } else { [DateTime]::MaxValue }

        while ((Get-Date) -lt $endTime) {
            # Get current mouse position
            $currentPos = [System.Windows.Forms.Cursor]::Position

            # Calculate new position based on pattern
            switch ($MovementPattern) {
                'Random' {
                    $xOffset = Get-Random -Minimum -10 -Maximum 11
                    $yOffset = Get-Random -Minimum -10 -Maximum 11
                    $newPos = [System.Drawing.Point]::new($currentPos.X + $xOffset, $currentPos.Y + $yOffset)
                }
                'Horizontal' {
                    $xOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
                    $newPos = [System.Drawing.Point]::new($currentPos.X + $xOffset, $currentPos.Y)
                }
                'Vertical' {
                    $yOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
                    $newPos = [System.Drawing.Point]::new($currentPos.X, $currentPos.Y + $yOffset)
                }
                'Circular' {
                    $angle = (Get-Date).Millisecond / 1000.0 * 2 * [Math]::PI
                    $radius = 10
                    $xOffset = [Math]::Cos($angle) * $radius
                    $yOffset = [Math]::Sin($angle) * $radius
                    $newPos = [System.Drawing.Point]::new($currentPos.X + $xOffset, $currentPos.Y + $yOffset)
                }
                default {
                    $newPos = $currentPos
                }
            }

            # Move mouse to new position
            [System.Windows.Forms.Cursor]::Position = $newPos

            # Wait for specified interval
            Start-Sleep -Milliseconds $Interval
        }
    } -ArgumentList $Interval, $MovementPattern, $Duration, $startTime

    if ($Duration -gt 0) {
        Write-Host "PSMouseJiggler will run for $Duration seconds" -ForegroundColor Yellow
    } else {
        Write-Host "PSMouseJiggler is running indefinitely. Use Stop-PSMouseJiggler to stop." -ForegroundColor Yellow
    }
}

<#
.SYNOPSIS
    Stops the PSMouseJiggler.

.DESCRIPTION
    Stops any running mouse jiggling job.

.EXAMPLE
    Stop-PSMouseJiggler
    Stops the currently running mouse jiggler.
#>
function Stop-PSMouseJiggler {
    [CmdletBinding()]
    param()

    if (-not $script:JigglingActive) {
        Write-Warning "PSMouseJiggler is not currently running."
        return
    }

    if ($script:JigglingJob) {
        Stop-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
        Remove-Job -Job $script:JigglingJob -ErrorAction SilentlyContinue
        $script:JigglingJob = $null
    }

    $script:JigglingActive = $false
    Write-Host "PSMouseJiggler stopped." -ForegroundColor Green
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
            return [System.Drawing.Point]::new($CurrentPosition.X + $xOffset, $CurrentPosition.Y + $yOffset)
        }
        'Horizontal' {
            $xOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
            return [System.Drawing.Point]::new($CurrentPosition.X + $xOffset, $CurrentPosition.Y)
        }
        'Vertical' {
            $yOffset = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -5 } else { 5 }
            return [System.Drawing.Point]::new($CurrentPosition.X, $CurrentPosition.Y + $yOffset)
        }
        'Circular' {
            $angle = (Get-Date).Millisecond / 1000.0 * 2 * [Math]::PI
            $radius = 10
            $xOffset = [Math]::Cos($angle) * $radius
            $yOffset = [Math]::Sin($angle) * $radius
            return [System.Drawing.Point]::new($CurrentPosition.X + $xOffset, $CurrentPosition.Y + $yOffset)
        }
        default {
            return $CurrentPosition
        }
    }
}

#endregion

#region GUI Functions

<#
.SYNOPSIS
    Shows the PSMouseJiggler GUI interface.

.DESCRIPTION
    Displays a graphical user interface for controlling the mouse jiggler.

.EXAMPLE
    Show-PSMouseJigglerGUI
    Opens the GUI interface.
#>
function Show-PSMouseJigglerGUI {
    [CmdletBinding()]
    param()

    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "PSMouseJiggler"
    $form.Size = New-Object System.Drawing.Size(400, 300)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    # Status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Status: Stopped"
    $statusLabel.Location = New-Object System.Drawing.Point(20, 20)
    $statusLabel.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($statusLabel)

    # Interval input
    $intervalLabel = New-Object System.Windows.Forms.Label
    $intervalLabel.Text = "Interval (ms):"
    $intervalLabel.Location = New-Object System.Drawing.Point(20, 60)
    $intervalLabel.Size = New-Object System.Drawing.Size(80, 20)
    $form.Controls.Add($intervalLabel)

    $intervalTextBox = New-Object System.Windows.Forms.TextBox
    $intervalTextBox.Text = "1000"
    $intervalTextBox.Location = New-Object System.Drawing.Point(110, 60)
    $intervalTextBox.Size = New-Object System.Drawing.Size(100, 20)
    $form.Controls.Add($intervalTextBox)

    # Pattern selection
    $patternLabel = New-Object System.Windows.Forms.Label
    $patternLabel.Text = "Movement Pattern:"
    $patternLabel.Location = New-Object System.Drawing.Point(20, 100)
    $patternLabel.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($patternLabel)

    $patternComboBox = New-Object System.Windows.Forms.ComboBox
    $patternComboBox.Location = New-Object System.Drawing.Point(150, 100)
    $patternComboBox.Size = New-Object System.Drawing.Size(120, 20)
    $patternComboBox.DropDownStyle = "DropDownList"
    $patternComboBox.Items.AddRange(@("Random", "Horizontal", "Vertical", "Circular"))
    $patternComboBox.SelectedIndex = 0
    $form.Controls.Add($patternComboBox)

    # Duration input
    $durationLabel = New-Object System.Windows.Forms.Label
    $durationLabel.Text = "Duration (sec, 0=infinite):"
    $durationLabel.Location = New-Object System.Drawing.Point(20, 140)
    $durationLabel.Size = New-Object System.Drawing.Size(140, 20)
    $form.Controls.Add($durationLabel)

    $durationTextBox = New-Object System.Windows.Forms.TextBox
    $durationTextBox.Text = "0"
    $durationTextBox.Location = New-Object System.Drawing.Point(170, 140)
    $durationTextBox.Size = New-Object System.Drawing.Size(100, 20)
    $form.Controls.Add($durationTextBox)

    # Start button
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Text = "Start Jiggling"
    $startButton.Location = New-Object System.Drawing.Point(50, 190)
    $startButton.Size = New-Object System.Drawing.Size(100, 30)
    $startButton.Add_Click({
        try {
            $interval = [int]$intervalTextBox.Text
            $pattern = $patternComboBox.SelectedItem.ToString()
            $duration = [int]$durationTextBox.Text

            Start-PSMouseJiggler -Interval $interval -MovementPattern $pattern -Duration $duration
            $statusLabel.Text = "Status: Running ($pattern)"
            $startButton.Enabled = $false
            $stopButton.Enabled = $true
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
        }
    })
    $form.Controls.Add($startButton)

    # Stop button
    $stopButton = New-Object System.Windows.Forms.Button
    $stopButton.Text = "Stop Jiggling"
    $stopButton.Location = New-Object System.Drawing.Point(200, 190)
    $stopButton.Size = New-Object System.Drawing.Size(100, 30)
    $stopButton.Enabled = $false
    $stopButton.Add_Click({
        Stop-PSMouseJiggler
        $statusLabel.Text = "Status: Stopped"
        $startButton.Enabled = $true
        $stopButton.Enabled = $false
    })
    $form.Controls.Add($stopButton)

    # Timer to update status
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.Add_Tick({
        if (-not $script:JigglingActive -and $stopButton.Enabled) {
            $statusLabel.Text = "Status: Stopped"
            $startButton.Enabled = $true
            $stopButton.Enabled = $false
        }
    })
    $timer.Start()

    # Show the form
    $form.Add_Shown({$form.Activate()})
    $form.Add_FormClosed({$timer.Stop()})
    [void]$form.ShowDialog()
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
            $jsonContent = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
            return $jsonContent
        }
        catch {
            Write-Warning "Error reading configuration file: $($_.Exception.Message)"
            return Get-DefaultConfiguration
        }
    } else {
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

        $jsonContent = $Configuration | ConvertTo-Json -Depth 10
        Set-Content -Path $ConfigFilePath -Value $jsonContent -Force
        Write-Verbose "Configuration saved to $ConfigFilePath"
    }
    catch {
        Write-Error "Error saving configuration: $($_.Exception.Message)"
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
        MovementSpeed = 1000
        MovementPattern = "Random"
        AutoJiggle = $false
        Duration = 0
        GUISettings = @{
            WindowPosition = @{ X = 0; Y = 0 }
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
        { Move-Mouse -X 10 -Y 0; Start-Sleep -Milliseconds 100 },
        { Move-Mouse -X -10 -Y 0; Start-Sleep -Milliseconds 100 },
        { Move-Mouse -X 0 -Y 10; Start-Sleep -Milliseconds 100 },
        { Move-Mouse -X 0 -Y -10; Start-Sleep -Milliseconds 100 },
        { Move-Mouse -X 5 -Y 5; Start-Sleep -Milliseconds 100 },
        { Move-Mouse -X -5 -Y -5; Start-Sleep -Milliseconds 100 }
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
function Move-Mouse {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$X = 0,

        [Parameter()]
        [int]$Y = 0
    )

    $currentPos = [System.Windows.Forms.Cursor]::Position
    $newPos = [System.Drawing.Point]::new($currentPos.X + $X, $currentPos.Y + $Y)
    [System.Windows.Forms.Cursor]::Position = $newPos
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
        [Parameter()]
        [int]$DurationInSeconds = 60
    )

    $endTime = (Get-Date).AddSeconds($DurationInSeconds)
    Write-Host "Starting movement pattern for $DurationInSeconds seconds" -ForegroundColor Green

    while ((Get-Date) -lt $endTime) {
        $movementPattern = Get-RandomMovementPattern
        & $movementPattern
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
    Get-ScheduledTasks -TaskName "PSMouseJiggler"
    Gets all tasks with "PSMouseJiggler" in the name.
#>
function Get-ScheduledTasks {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$TaskName = "PSMouseJiggler"
    )

    try {
        $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*$TaskName*" }
        return $tasks
    }
    catch {
        Write-Error "Error retrieving scheduled tasks: $($_.Exception.Message)"
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
    New-ScheduledTask -TaskName "MyJiggler" -Action "powershell.exe -Command 'Start-PSMouseJiggler'" -StartTime (Get-Date).AddMinutes(5)
    Creates a task to start jiggling in 5 minutes.
#>
function New-ScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName,

        [Parameter(Mandatory)]
        [string]$Action,

        [Parameter(Mandatory)]
        [datetime]$StartTime,

        [Parameter()]
        [int]$RepeatIntervalMinutes = 60
    )

    try {
        $action = New-ScheduledTaskAction -Execute $Action
        $trigger = New-ScheduledTaskTrigger -At $StartTime -Daily
        $trigger.RepeatInterval = (New-TimeSpan -Minutes $RepeatIntervalMinutes)

        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $TaskName -Description "PSMouseJiggler Task"
        Write-Host "Scheduled task '$TaskName' created successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Error creating scheduled task: $($_.Exception.Message)"
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
    Remove-ScheduledTask -TaskName "MyJiggler"
    Removes the MyJiggler scheduled task.
#>
function Remove-ScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName
    )

    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Scheduled task '$TaskName' removed successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Error removing scheduled task: $($_.Exception.Message)"
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
    Start-ScheduledTask -TaskName "MyJiggler"
    Starts the MyJiggler scheduled task.
#>
function Start-ScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName
    )

    try {
        Start-ScheduledTask -TaskName $TaskName
        Write-Host "Scheduled task '$TaskName' started successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Error starting scheduled task: $($_.Exception.Message)"
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
    Stop-ScheduledTask -TaskName "MyJiggler"
    Stops the MyJiggler scheduled task.
#>
function Stop-ScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName
    )

    try {
        Stop-ScheduledTask -TaskName $TaskName
        Write-Host "Scheduled task '$TaskName' stopped successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Error stopping scheduled task: $($_.Exception.Message)"
    }
}

#endregion

# Module cleanup when module is removed
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    if ($script:JigglingActive) {
        Stop-PSMouseJiggler
    }
}

# Export module members (this is also defined in the manifest for best practice)
Export-ModuleMember -Function @(
    'Start-PSMouseJiggler',
    'Stop-PSMouseJiggler',
    'Get-NewMousePosition',
    'Show-PSMouseJigglerGUI',
    'Get-Configuration',
    'Save-Configuration',
    'Update-Configuration',
    'Reset-Configuration',
    'Get-RandomMovementPattern',
    'Move-Mouse',
    'Start-MovementPattern',
    'Stop-MovementPattern',
    'Get-ScheduledTasks',
    'New-ScheduledTask',
    'Remove-ScheduledTask',
    'Start-ScheduledTask',
    'Stop-ScheduledTask'
)
