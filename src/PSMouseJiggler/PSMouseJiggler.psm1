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
    $form.Size = New-Object System.Drawing.Size(400, 410) # Increased height for new controls
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

    # Advanced mode checkbox
    $advancedModeCheckbox = New-Object System.Windows.Forms.CheckBox
    $advancedModeCheckbox.Text = "Use Advanced Keep-Awake Methods"
    $advancedModeCheckbox.Location = New-Object System.Drawing.Point(20, 180)
    $advancedModeCheckbox.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($advancedModeCheckbox)

    # Method selection group
    $methodsGroupBox = New-Object System.Windows.Forms.GroupBox
    $methodsGroupBox.Text = "Keep-Awake Methods"
    $methodsGroupBox.Location = New-Object System.Drawing.Point(20, 210)
    $methodsGroupBox.Size = New-Object System.Drawing.Size(350, 100)
    $methodsGroupBox.Enabled = $false
    $form.Controls.Add($methodsGroupBox)

    # Method checkboxes
    $mouseSoftwareCheckbox = New-Object System.Windows.Forms.CheckBox
    $mouseSoftwareCheckbox.Text = "Software Mouse Movements"
    $mouseSoftwareCheckbox.Location = New-Object System.Drawing.Point(10, 20)
    $mouseSoftwareCheckbox.Size = New-Object System.Drawing.Size(200, 20)
    $mouseSoftwareCheckbox.Checked = $true
    $methodsGroupBox.Controls.Add($mouseSoftwareCheckbox)

    $mouseHardwareCheckbox = New-Object System.Windows.Forms.CheckBox
    $mouseHardwareCheckbox.Text = "Hardware Mouse Movements"
    $mouseHardwareCheckbox.Location = New-Object System.Drawing.Point(10, 45)
    $mouseHardwareCheckbox.Size = New-Object System.Drawing.Size(200, 20)
    $mouseHardwareCheckbox.Checked = $true
    $methodsGroupBox.Controls.Add($mouseHardwareCheckbox)

    $keyboardCheckbox = New-Object System.Windows.Forms.CheckBox
    $keyboardCheckbox.Text = "Keyboard Input"
    $keyboardCheckbox.Location = New-Object System.Drawing.Point(10, 70)
    $keyboardCheckbox.Size = New-Object System.Drawing.Size(120, 20)
    $keyboardCheckbox.Checked = $true
    $methodsGroupBox.Controls.Add($keyboardCheckbox)

    $systemApiCheckbox = New-Object System.Windows.Forms.CheckBox
    $systemApiCheckbox.Text = "System API"
    $systemApiCheckbox.Location = New-Object System.Drawing.Point(180, 70)
    $systemApiCheckbox.Size = New-Object System.Drawing.Size(120, 20)
    $systemApiCheckbox.Checked = $true
    $methodsGroupBox.Controls.Add($systemApiCheckbox)

    # Enable/disable method selection based on advanced mode
    $advancedModeCheckbox.Add_CheckedChanged({
            $methodsGroupBox.Enabled = $advancedModeCheckbox.Checked
        })

    # Start button
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Text = "Start Jiggling"
    $startButton.Location = New-Object System.Drawing.Point(50, 320)
    $startButton.Size = New-Object System.Drawing.Size(100, 30)
    $startButton.Add_Click({
            try {
                $interval = [int]$intervalTextBox.Text
                $duration = [int]$durationTextBox.Text

                if ($advancedModeCheckbox.Checked) {
                    $methods = @()
                    if ($mouseSoftwareCheckbox.Checked) { $methods += 'MouseSoftware' }
                    if ($mouseHardwareCheckbox.Checked) { $methods += 'MouseHardware' }
                    if ($keyboardCheckbox.Checked) { $methods += 'Keyboard' }
                    if ($systemApiCheckbox.Checked) { $methods += 'SystemAPI' }

                    if ($methods.Count -eq 0) {
                        [System.Windows.Forms.MessageBox]::Show("Please select at least one keep-awake method.", "Error", "OK", "Error")
                        return
                    }

                    Start-KeepAwake -Methods $methods -Interval $interval -Duration $duration
                    $statusLabel.Text = "Status: Running (Advanced Mode)"
                }
                else {
                    $pattern = $patternComboBox.SelectedItem.ToString()
                    Start-PSMouseJiggler -Interval $interval -MovementPattern $pattern -Duration $duration
                    $statusLabel.Text = "Status: Running ($pattern)"
                }

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
    $stopButton.Location = New-Object System.Drawing.Point(200, 320)
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
    $form.Add_Shown({ $form.Activate() })
    $form.Add_FormClosed({ $timer.Stop() })
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
function Move-Mouse {
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

.EXAMPLE
    Start-KeepAwake -Interval 60000 -Duration 3600
    Keeps the system awake for 1 hour, performing actions every 60 seconds.
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
        [int]$Duration = 0
    )

    if ($script:JigglingActive) {
        Write-Warning "PSMouseJiggler is already running. Use Stop-PSMouseJiggler to stop it first."
        return
    }

    Write-Host "Starting PSMouseJiggler KeepAwake with multiple methods, interval: $Interval ms" -ForegroundColor Green

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
    'Get-PSMJScheduledTasks',        # Updated name
    'New-PSMJScheduledTask',         # Updated name
    'Remove-PSMJScheduledTask',      # Updated name
    'Start-PSMJScheduledTask',       # Updated name
    'Stop-PSMJScheduledTask',        # Updated name
    # New functions
    'Prevent-SystemIdle',
    'Send-KeyboardInput',
    'Send-MouseInput',
    'Start-KeepAwake'
)