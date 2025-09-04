# ScheduledTasks.psm1

function Get-ScheduledTasks {
    [CmdletBinding()]
    param (
        [string]$TaskName
    )
    
    # Retrieve scheduled tasks related to PSMouseJiggler
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*$TaskName*" }
    return $tasks
}

function New-ScheduledTask {
    [CmdletBinding()]
    param (
        [string]$TaskName,
        [string]$Action,
        [datetime]$StartTime,
        [int]$RepeatIntervalMinutes = 60
    )
    
    # Create a new scheduled task for PSMouseJiggler
    $action = New-ScheduledTaskAction -Execute $Action
    $trigger = New-ScheduledTaskTrigger -At $StartTime -Daily
    $trigger.RepeatInterval = (New-TimeSpan -Minutes $RepeatIntervalMinutes)
    
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $TaskName -Description "PSMouseJiggler Task"
}

function Remove-ScheduledTask {
    [CmdletBinding()]
    param (
        [string]$TaskName
    )
    
    # Remove a scheduled task related to PSMouseJiggler
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

function Start-ScheduledTask {
    [CmdletBinding()]
    param (
        [string]$TaskName
    )
    
    # Start a scheduled task for PSMouseJiggler
    Start-ScheduledTask -TaskName $TaskName
}

function Stop-ScheduledTask {
    [CmdletBinding()]
    param (
        [string]$TaskName
    )
    
    # Stop a scheduled task for PSMouseJiggler
    Stop-ScheduledTask -TaskName $TaskName
}