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

.PARAMETER Incognito
When enabled, clears the console after starting to maintain privacy/discretion.

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
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
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

    # Clear console if incognito mode is enabled
    if ($Incognito) {
        Clear-Host
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
    $form.Text = "PSMouseJiggler v1.0.4"
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

.PARAMETER Incognito
When enabled, clears the console after starting to maintain privacy/discretion.

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
        [int]$Duration = 0,

        [Parameter()]
        [switch]$Incognito
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

    # Clear console if incognito mode is enabled
    if ($Incognito) {
        Clear-Host
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