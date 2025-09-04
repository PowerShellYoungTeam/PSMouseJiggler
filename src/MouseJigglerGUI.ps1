# PSMouseJigglerGUI.ps1

# This script provides a graphical user interface for the Mouse Jiggler application.

# Load necessary modules
Import-Module -Name "$PSScriptRoot\modules\Configuration.psm1"
Import-Module -Name "$PSScriptRoot\modules\MovementPatterns.psm1"
Import-Module -Name "$PSScriptRoot\modules\ScheduledTasks.psm1"

# Function to create the GUI
function Create-PSMouseJigglerGUI {
    # Create a new form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "PSMouseJiggler"
    $form.Size = New-Object System.Drawing.Size(300, 200)
    $form.StartPosition = "CenterScreen"

    # Start button
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Text = "Start Jiggling"
    $startButton.Location = New-Object System.Drawing.Point(50, 50)
    $startButton.Add_Click({
        Start-Jiggling
    })
    $form.Controls.Add($startButton)

    # Stop button
    $stopButton = New-Object System.Windows.Forms.Button
    $stopButton.Text = "Stop Jiggling"
    $stopButton.Location = New-Object System.Drawing.Point(150, 50)
    $stopButton.Add_Click({
        Stop-Jiggling
    })
    $form.Controls.Add($stopButton)

    # Movement pattern selection
    $patternLabel = New-Object System.Windows.Forms.Label
    $patternLabel.Text = "Select Movement Pattern:"
    $patternLabel.Location = New-Object System.Drawing.Point(50, 100)
    $form.Controls.Add($patternLabel)

    $patternComboBox = New-Object System.Windows.Forms.ComboBox
    $patternComboBox.Location = New-Object System.Drawing.Point(50, 120)
    $patternComboBox.Items.AddRange(@("Random", "Linear", "Circular"))
    $patternComboBox.SelectedIndex = 0
    $form.Controls.Add($patternComboBox)

    # Show the form
    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}

# Function to start jiggling
function Start-Jiggling {
    # Logic to start mouse jiggling
    $selectedPattern = $patternComboBox.SelectedItem
    # Call the appropriate movement pattern function based on selection
    Start-MouseMovement -Pattern $selectedPattern
}

# Function to stop jiggling
function Stop-Jiggling {
    # Logic to stop mouse jiggling
    Stop-MouseMovement
}

# Entry point
Create-PSMouseJigglerGUI