# Configuration.psm1

function Get-Configuration {
    param (
        [string]$ConfigFilePath = "$PSScriptRoot\..\config\default.json"
    )

    if (Test-Path $ConfigFilePath) {
        $jsonContent = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
        return $jsonContent
    } else {
        Write-Error "Configuration file not found at path: $ConfigFilePath"
        return $null
    }
}

function Save-Configuration {
    param (
        [string]$ConfigFilePath = "$PSScriptRoot\..\config\default.json",
        [PSCustomObject]$Configuration
    )

    $jsonContent = $Configuration | ConvertTo-Json -Depth 10
    Set-Content -Path $ConfigFilePath -Value $jsonContent -Force
}

function Update-Configuration {
    param (
        [string]$Key,
        [string]$Value,
        [string]$ConfigFilePath = "$PSScriptRoot\..\config\default.json"
    )

    $config = Get-Configuration -ConfigFilePath $ConfigFilePath
    if ($config -ne $null) {
        $config | Add-Member -MemberType NoteProperty -Name $Key -Value $Value -Force
        Save-Configuration -ConfigFilePath $ConfigFilePath -Configuration $config
    }
}

function Reset-Configuration {
    param (
        [string]$ConfigFilePath = "$PSScriptRoot\..\config\default.json"
    )

    $defaultConfig = @{
        MovementSpeed = 100
        MovementPattern = "Default"
        AutoJiggle = $false
    }

    Save-Configuration -ConfigFilePath $ConfigFilePath -Configuration $defaultConfig
}