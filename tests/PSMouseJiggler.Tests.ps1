Describe 'PSMouseJiggler Basic Functionality Tests' {
    BeforeAll {
        # Remove any existing instances of the module first
        Get-Module PSMouseJiggler | Remove-Module -Force -ErrorAction SilentlyContinue

        # Import the module
        $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\src\PSMouseJiggler\PSMouseJiggler.psd1"
        Import-Module $ModulePath -Force -DisableNameChecking
    }

    AfterAll {
        # Clean up - attempt to stop jiggling regardless of the variable state
        try {
            Stop-PSMouseJiggler -ErrorAction SilentlyContinue
        }
        catch {
            # Ignore errors
        }
        Remove-Module PSMouseJiggler -ErrorAction SilentlyContinue
    }

    Context 'Module Loading' {
        It 'Should load the module successfully' {
            $module = Get-Module PSMouseJiggler | Select-Object -First 1
            $module | Should -Not -BeNullOrEmpty
            $module.Name | Should -Be 'PSMouseJiggler'
        }

        It 'Should export the required functions' {
            $requiredFunctions = @(
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
                'Get-PSMJScheduledTasks',       # Updated name
                'Get-PSMJScheduledTaskStatus',
                'New-PSMJScheduledProfileTask',
                'New-PSMJScheduledTask',        # Updated name
                'Remove-PSMJScheduledTask',     # Updated name
                'Start-PSMJScheduledTask',      # Updated name
                'Stop-PSMJScheduledTask',       # Updated name
                'Prevent-SystemIdle',
                'Send-KeyboardInput',
                'Send-MouseInput',
                'Get-PSMJRecommendedMethods',
                'Start-PSMJProfile',
                'Get-PSMJDiagnostics'
            )

            foreach ($function in $requiredFunctions) {
                Get-Command -Name $function -Module PSMouseJiggler | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Core Functionality Sequence' {
        It 'Should execute the jiggling sequence without errors' {
            # Step 1: Start mouse jiggling with a short duration
            { Start-PSMouseJiggler -Duration 1 } | Should -Not -Throw
            Start-Sleep -Seconds 2

            # Step 2: Stop the jiggling
            { Stop-PSMouseJiggler } | Should -Not -Throw

            # Step 3: Start the keep-awake functionality with a short duration
            { Start-PSMouseJiggler -Methods @('SystemAPI', 'Keyboard') -Duration 1 } | Should -Not -Throw
            Start-Sleep -Seconds 2

            # Step 4: Stop the keep-awake functionality
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should clear the host without warning when an incognito start is already running' {
            InModuleScope PSMouseJiggler {
                Mock Clear-Host

                Start-PSMouseJiggler -Duration 10
                $warning = $null
                Start-PSMouseJiggler -Methods @('SystemAPI', 'Keyboard') -Incognito -WarningVariable warning

                $warning | Should -BeNullOrEmpty
                Should -Invoke Clear-Host -Exactly 1

                Stop-PSMouseJiggler
            }
        }

        It 'Should reject non-positive movement intervals' {
            { Start-PSMouseJiggler -Interval 0 } | Should -Throw
        }

        It 'Should reject negative durations' {
            { Start-PSMouseJiggler -Methods @('SystemAPI') -Duration -1 } | Should -Throw
        }

        It 'Should use defaults when a configuration contains invalid values' {
            $configPath = Join-Path $TestDrive 'invalid-config.json'
            '{"MovementPattern":"Unknown","JiggleInterval":0}' | Set-Content -Path $configPath

            $config = Get-Configuration -ConfigFilePath $configPath -WarningAction SilentlyContinue

            $config.MovementPattern | Should -Be 'Random'
            $config.JiggleInterval | Should -Be 1000
        }

        It 'Should save, retrieve, list, and remove a profile' {
            $configPath = Join-Path $TestDrive 'profiles.json'
            $profile = [PSCustomObject]@{
                Interval        = 1500
                Duration        = 60
                MovementPattern = 'Circular'
                Incognito       = $true
            }

            $saved = Save-PSMJProfile -Name 'Presentation' -Profile $profile -ConfigFilePath $configPath
            $saved.Name | Should -Be 'Presentation'
            $saved.MovementPattern | Should -Be 'Circular'

            $listed = @(Get-PSMJProfile -ConfigFilePath $configPath)
            $listed.Count | Should -Be 1
            $listed[0].Name | Should -Be 'Presentation'

            Remove-PSMJProfile -Name 'Presentation' -ConfigFilePath $configPath -Confirm:$false
            @(Get-PSMJProfile -ConfigFilePath $configPath).Count | Should -Be 0
        }

        It 'Should reject profiles with invalid method names' {
            $profile = [PSCustomObject]@{
                Methods  = @('Unsupported')
                Interval = 1000
                Duration = 0
            }

            { Save-PSMJProfile -Name 'Invalid' -Profile $profile -ConfigFilePath (Join-Path $TestDrive 'invalid-profile.json') } | Should -Throw
        }

        It 'Should execute a saved mouse jiggler profile' {
            $configPath = Join-Path $TestDrive 'mouse-profile.json'
            $profile = [PSCustomObject]@{
                Interval        = 1000
                Duration        = 1
                MovementPattern = 'Random'
            }

            Save-PSMJProfile -Name 'ShortMouse' -Profile $profile -ConfigFilePath $configPath | Out-Null
            { Start-PSMJProfile -Name 'ShortMouse' -ConfigFilePath $configPath } | Should -Not -Throw
            Start-Sleep -Seconds 2
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should execute a saved keep-awake profile' {
            $configPath = Join-Path $TestDrive 'keepawake-profile.json'
            $profile = [PSCustomObject]@{
                Methods  = @('SystemAPI')
                Interval = 1000
                Duration = 1
            }

            Save-PSMJProfile -Name 'ShortKeepAwake' -Profile $profile -ConfigFilePath $configPath | Out-Null
            { Start-PSMJProfile -Name 'ShortKeepAwake' -ConfigFilePath $configPath } | Should -Not -Throw
            Start-Sleep -Seconds 2
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should execute a saved AppKeepAlive profile' {
            $configPath = Join-Path $TestDrive 'appkeepalive-profile.json'
            $profile = [PSCustomObject]@{
                Strategy = 'AppKeepAlive'
                Interval = 1000
                Duration = 1
            }

            Save-PSMJProfile -Name 'ShortAppKeepAlive' -Profile $profile -ConfigFilePath $configPath | Out-Null
            { Start-PSMJProfile -Name 'ShortAppKeepAlive' -ConfigFilePath $configPath } | Should -Not -Throw
            Start-Sleep -Seconds 2
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should return diagnostics for the module and saved profiles' {
            $configPath = Join-Path $TestDrive 'diagnostics.json'
            $profile = [PSCustomObject]@{
                Methods  = @('SystemAPI')
                Interval = 30000
                Duration = 0
            }

            Save-PSMJProfile -Name 'DiagnosticsProfile' -Profile $profile -ConfigFilePath $configPath | Out-Null
            $diagnostics = Get-PSMJDiagnostics -ConfigFilePath $configPath

            $diagnostics.ModuleName | Should -Be 'PSMouseJiggler'
            $diagnostics.ConfigurationValid | Should -BeTrue
            $diagnostics.IsRunning | Should -BeFalse
            $diagnostics.JobState | Should -Be 'NotStarted'
            $diagnostics.ProfileCount | Should -Be 1
        }

        It 'Should report invalid configuration in diagnostics' {
            $configPath = Join-Path $TestDrive 'diagnostics-invalid.json'
            '{"MovementPattern":"Unknown"}' | Set-Content -Path $configPath

            $diagnostics = Get-PSMJDiagnostics -ConfigFilePath $configPath

            $diagnostics.ConfigurationValid | Should -BeFalse
            $diagnostics.ProfileCount | Should -Be 0
        }

        It 'Should normalize scheduled task status for UI consumers' {
            InModuleScope PSMouseJiggler {
                $task = [PSCustomObject]@{
                    TaskName = 'PSMouseJiggler-Work'
                    TaskPath = '\'
                    State    = 'Ready'
                    Settings = [PSCustomObject]@{ Enabled = $true }
                }
                $taskInfo = [PSCustomObject]@{
                    NextRunTime    = [datetime]'2026-08-21T09:00:00'
                    LastRunTime    = [datetime]'2026-08-20T17:00:00'
                    LastTaskResult = 0
                }

                Mock Get-ScheduledTask { $task }
                Mock Get-ScheduledTaskInfo { $taskInfo }

                $status = @(Get-PSMJScheduledTaskStatus -TaskName 'PSMouseJiggler-*')

                $status.Count | Should -Be 1
                $status[0].TaskName | Should -Be 'PSMouseJiggler-Work'
                $status[0].State | Should -Be 'Ready'
                $status[0].Enabled | Should -BeTrue
                $status[0].LastTaskResult | Should -Be 0
            }
        }

        It 'Should create a scheduled task action for a saved profile' {
            InModuleScope PSMouseJiggler {
                $configPath = Join-Path $TestDrive 'scheduled-profile.json'
                $profile = [PSCustomObject]@{
                    Methods  = @('SystemAPI')
                    Interval = 30000
                    Duration = 0
                }
                Save-PSMJProfile -Name "Work Profile" -Profile $profile -ConfigFilePath $configPath | Out-Null
                Mock New-PSMJScheduledTask

                New-PSMJScheduledProfileTask `
                    -TaskName 'PSMJ-Work' `
                    -ProfileName "Work Profile" `
                    -StartTime ([datetime]'2026-08-21T09:00:00') `
                    -RepeatIntervalMinutes 30 `
                    -ConfigFilePath $configPath

                Should -Invoke New-PSMJScheduledTask -Exactly 1 -ParameterFilter {
                    $TaskName -eq 'PSMJ-Work' -and
                    $Action -match "Start-PSMJProfile -Name 'Work Profile'" -and
                    $Action -match [regex]::Escape("-ConfigFilePath '$configPath'") -and
                    $RepeatIntervalMinutes -eq 30
                }
            }
        }

        It 'Should recommend methods for each keep-awake strategy' {
            @(Get-PSMJRecommendedMethods -Strategy LowImpact) | Should -Be @('SystemAPI')
            @(Get-PSMJRecommendedMethods -Strategy Compatibility) | Should -Be @('MouseSoftware')
            @(Get-PSMJRecommendedMethods -Strategy AppKeepAlive) | Should -Be @('SystemAPI', 'Keyboard')

            $adaptiveMethods = @(Get-PSMJRecommendedMethods -Strategy Adaptive)
            $adaptiveMethods.Count | Should -BeGreaterThan 0
            $adaptiveMethods | Should -Contain 'SystemAPI'
        }

        It 'Should execute an adaptive keep-awake session' {
            { Start-PSMouseJiggler -Strategy Adaptive -Duration 1 -Interval 1000 } | Should -Not -Throw
            Start-Sleep -Seconds 2
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should execute an AppKeepAlive session without moving the mouse' {
            { Start-PSMouseJiggler -Strategy AppKeepAlive -Duration 1 -Interval 1000 } | Should -Not -Throw
            Start-Sleep -Seconds 2
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should still support all movement patterns via the default Methods' {
            foreach ($pattern in @('Random', 'Horizontal', 'Vertical', 'Circular')) {
                { Start-PSMouseJiggler -MovementPattern $pattern -Duration 1 -Interval 1000 } | Should -Not -Throw
                Start-Sleep -Seconds 2
                { Stop-PSMouseJiggler } | Should -Not -Throw
            }
        }

        It 'Should reconcile completed jobs before reporting or starting again' {
            { Start-PSMouseJiggler -Duration 1 -Interval 1000 } | Should -Not -Throw

            $deadline = (Get-Date).AddSeconds(10)
            do {
                Start-Sleep -Milliseconds 250
                $diagnostics = Get-PSMJDiagnostics
            } while ($diagnostics.IsRunning -and (Get-Date) -lt $deadline)

            $diagnostics.IsRunning | Should -BeFalse
            $diagnostics.JobState | Should -Be 'NotStarted'

            { Start-PSMouseJiggler -Duration 1 -Interval 1000 } | Should -Not -Throw
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }
    }
}