function Start-PSMouseJiggler {
    param (
        [int]$Interval = 1000, # Time in milliseconds between movements
        [string]$MovementPattern = 'Random' # Default movement pattern
    )

    # Load movement patterns module
    Import-Module -Name .\modules\MovementPatterns.psm1

    # Start the jiggling process
    while ($true) {
        # Get the current mouse position
        $currentPosition = [System.Windows.Forms.Cursor]::Position

        # Determine the new position based on the selected movement pattern
        $newPosition = Get-NewMousePosition -CurrentPosition $currentPosition -Pattern $MovementPattern

        # Move the mouse to the new position
        [System.Windows.Forms.Cursor]::Position = $newPosition

        # Wait for the specified interval
        Start-Sleep -Milliseconds $Interval
    }
}

function Stop-PSMouseJiggler {
    # Logic to stop the mouse jiggling process
    Write-Host "Mouse jiggling stopped."
}

function Get-NewMousePosition {
    param (
        [System.Drawing.Point]$CurrentPosition,
        [string]$Pattern
    )

    # Logic to determine new mouse position based on the selected pattern
    switch ($Pattern) {
        'Random' {
            $xOffset = Get-Random -Minimum -10 -Maximum 10
            $yOffset = Get-Random -Minimum -10 -Maximum 10
            return [System.Drawing.Point]::new($CurrentPosition.X + $xOffset, $CurrentPosition.Y + $yOffset)
        }
        'Horizontal' {
            return [System.Drawing.Point]::new($CurrentPosition.X + 5, $CurrentPosition.Y)
        }
        'Vertical' {
            return [System.Drawing.Point]::new($CurrentPosition.X, $CurrentPosition.Y + 5)
        }
        default {
            return $CurrentPosition
        }
    }
}

# Entry point for the script
Start-PSMouseJiggler -Interval 1000 -MovementPattern 'Random'
