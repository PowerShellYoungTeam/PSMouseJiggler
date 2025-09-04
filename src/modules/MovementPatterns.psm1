# MovementPatterns.psm1

function Get-RandomMovementPattern {
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

function Move-Mouse {
    param (
        [int]$X,
        [int]$Y
    )
    $pos = [System.Windows.Forms.Cursor]::Position
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($pos.X + $X, $pos.Y + $Y)
}

function Start-MovementPattern {
    param (
        [int]$DurationInSeconds = 60
    )
    $endTime = (Get-Date).AddSeconds($DurationInSeconds)
    while ((Get-Date) -lt $endTime) {
        $movementPattern = Get-RandomMovementPattern
        & $movementPattern
    }
}

function Stop-MovementPattern {
    # Logic to stop the movement pattern can be implemented here
    Write-Host "Movement pattern stopped."
}