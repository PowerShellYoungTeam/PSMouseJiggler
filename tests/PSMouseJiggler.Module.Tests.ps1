# PSMouseJiggler.Tests.ps1
# Pester tests for the PSMouseJiggler module

BeforeAll {
    # Import the module from the module directory
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\src\PSMouseJiggler\PSMouseJiggler.psd1"
    Import-Module $ModulePath -Force
}

Describe 'PSMouseJiggler Module Tests' {

    Context 'Module Loading' {
        It 'Should load the module successfully' {
            $module = Get-Module PSMouseJiggler | Select-Object -First 1
            $module | Should -Not -BeNullOrEmpty
            $module.Name | Should -Be 'PSMouseJiggler'
        }

        It 'Should export the expected functions' {
            $module = Get-Module PSMouseJiggler
            $expectedFunctions = @(
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

            foreach ($function in $expectedFunctions) {
                $module.ExportedFunctions.Keys | Should -Contain $function
            }
        }
    }

    Context 'Core Functions' {
        It 'Should have Start-PSMouseJiggler function available' {
            { Get-Command Start-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should have Stop-PSMouseJiggler function available' {
            { Get-Command Stop-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should calculate new mouse position correctly' {
            $currentPos = [System.Drawing.Point]::new(100, 100)
            $newPos = Get-NewMousePosition -CurrentPosition $currentPos -Pattern 'Horizontal'
            $newPos | Should -Not -BeNullOrEmpty
            $newPos.GetType().Name | Should -Be 'Point'
        }
    }

    Context 'Configuration Functions' {
        It 'Should get default configuration when no config file exists' {
            $config = Get-Configuration -ConfigFilePath "NonExistentFile.json"
            $config | Should -Not -BeNullOrEmpty
            $config.MovementSpeed | Should -Be 1000
            $config.MovementPattern | Should -Be 'Random'
        }

        It 'Should save and load configuration correctly' {
            $tempConfigPath = Join-Path $env:TEMP "test-config.json"

            # Create test configuration
            $testConfig = [PSCustomObject]@{
                MovementSpeed   = 1500
                MovementPattern = 'Circular'
                TestProperty    = 'TestValue'
            }

            # Save configuration
            Save-Configuration -Configuration $testConfig -ConfigFilePath $tempConfigPath

            # Verify file was created
            Test-Path $tempConfigPath | Should -Be $true

            # Load and verify configuration
            $loadedConfig = Get-Configuration -ConfigFilePath $tempConfigPath
            $loadedConfig.MovementSpeed | Should -Be 1500
            $loadedConfig.MovementPattern | Should -Be 'Circular'
            $loadedConfig.TestProperty | Should -Be 'TestValue'

            # Cleanup
            Remove-Item $tempConfigPath -ErrorAction SilentlyContinue
        }

        It 'Should update configuration correctly' {
            $tempConfigPath = Join-Path $env:TEMP "test-config-update.json"

            # Create initial configuration
            $initialConfig = [PSCustomObject]@{
                MovementSpeed   = 1000
                MovementPattern = 'Random'
            }
            Save-Configuration -Configuration $initialConfig -ConfigFilePath $tempConfigPath

            # Update configuration
            Update-Configuration -Key 'MovementSpeed' -Value 2000 -ConfigFilePath $tempConfigPath

            # Verify update
            $updatedConfig = Get-Configuration -ConfigFilePath $tempConfigPath
            $updatedConfig.MovementSpeed | Should -Be 2000

            # Cleanup
            Remove-Item $tempConfigPath -ErrorAction SilentlyContinue
        }
    }

    Context 'Movement Functions' {
        It 'Should get random movement pattern' {
            $pattern = Get-RandomMovementPattern
            $pattern | Should -Not -BeNullOrEmpty
            $pattern.GetType().Name | Should -Be 'ScriptBlock'
        }

        It 'Should move mouse by relative coordinates' {
            # Get initial position
            $initialPos = [System.Windows.Forms.Cursor]::Position

            # Move mouse
            Move-Mouse -X 5 -Y 0

            # Verify position changed
            $newPos = [System.Windows.Forms.Cursor]::Position
            $newPos.X | Should -Be ($initialPos.X + 5)
            $newPos.Y | Should -Be $initialPos.Y

            # Move back to original position
            Move-Mouse -X -5 -Y 0
        }
    }

    Context 'Scheduled Task Functions' {
        It 'Should get scheduled tasks without error' {
            { Get-ScheduledTasks -TaskName "PSMouseJiggler" } | Should -Not -Throw
        }

        # Note: We skip actual scheduled task creation/deletion tests to avoid
        # requiring administrator privileges and affecting the system
    }

    Context 'Parameter Validation' {
        It 'Should validate movement pattern parameter' {
            { Start-PSMouseJiggler -MovementPattern 'InvalidPattern' } | Should -Throw
        }

        It 'Should accept valid movement patterns' {
            $validPatterns = @('Random', 'Horizontal', 'Vertical', 'Circular')
            foreach ($pattern in $validPatterns) {
                { Get-NewMousePosition -CurrentPosition ([System.Drawing.Point]::new(0, 0)) -Pattern $pattern } | Should -Not -Throw
            }
        }
    }
}

AfterAll {
    # Clean up - remove the module
    Remove-Module PSMouseJiggler -ErrorAction SilentlyContinue
}
