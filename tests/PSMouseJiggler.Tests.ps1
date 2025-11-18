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

Describe 'PSMouseJiggler Module Loading' -Tag 'Unit', 'Windows', 'Linux', 'MacOS' {
    Context 'Module Import' {
        It 'Should load the module successfully' {
            $module = Get-Module PSMouseJiggler | Select-Object -First 1
            $module | Should -Not -BeNullOrEmpty
            $module.Name | Should -Be 'PSMouseJiggler'
        }

        It 'Should have correct module version' {
            $module = Get-Module PSMouseJiggler | Select-Object -First 1
            $module.Version | Should -Be '2.0.0'
        }

        It 'Should export all required functions' {
            $requiredFunctions = @(
                'Start-PSMouseJiggler',
                'Stop-PSMouseJiggler',
                'Get-NewMousePosition',
                'Move-Mouse',
                'Start-MovementPattern',
                'Stop-MovementPattern',
                'Start-KeepAwake',
                'Show-PSMouseJigglerGUI',
                'Show-PSMouseJigglerTUI',
                'Get-Configuration',
                'Save-Configuration',
                'Update-Configuration',
                'Reset-Configuration',
                'Get-RandomMovementPattern',
                'Get-PSMJScheduledTasks',
                'New-PSMJScheduledTask',
                'Remove-PSMJScheduledTask',
                'Start-PSMJScheduledTask',
                'Stop-PSMJScheduledTask',
                'Prevent-SystemIdle',
                'Send-KeyboardInput',
                'Send-MouseInput',
                'Get-OperatingSystemPlatform',
                'Test-PlatformCapability',
                'Show-DependencyInstallInstructions'
            )

            foreach ($function in $requiredFunctions) {
                Get-Command -Name $function -Module PSMouseJiggler -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "Function $function should be exported"
            }
        }
    }
}

Describe 'Platform Detection' -Tag 'Unit', 'Windows', 'Linux', 'MacOS' {
    Context 'Get-OperatingSystemPlatform' {
        It 'Should return a valid platform name' {
            $platform = Get-OperatingSystemPlatform
            $platform | Should -BeIn @('Windows', 'Linux', 'macOS')
        }

        It 'Should return consistent results' {
            $platform1 = Get-OperatingSystemPlatform
            $platform2 = Get-OperatingSystemPlatform
            $platform1 | Should -Be $platform2
        }
    }

    Context 'Test-PlatformCapability' {
        It 'Should accept valid capability names' {
            $validCapabilities = @('GUI', 'WindowsAPI', 'XDoTool', 'YDoTool', 'CliClick', 'SystemdInhibit', 'Caffeinate', 'ScheduledTasks', 'LaunchD', 'SystemdTimers')

            foreach ($capability in $validCapabilities) {
                { Test-PlatformCapability -Capability $capability } | Should -Not -Throw
            }
        }

        It 'Should return boolean values' {
            $result = Test-PlatformCapability -Capability 'GUI'
            $result | Should -BeOfType [bool]
        }
    }
}

Describe 'Platform-Specific Capabilities' {
    Context 'Windows-Specific Features' -Tag 'Windows' {
        It 'Should have GUI capability on Windows' {
            $result = Test-PlatformCapability -Capability 'GUI'
            $result | Should -Be $true
        }

        It 'Should have WindowsAPI capability on Windows' {
            $result = Test-PlatformCapability -Capability 'WindowsAPI'
            $result | Should -Be $true
        }

        It 'Should have ScheduledTasks capability on Windows' {
            $result = Test-PlatformCapability -Capability 'ScheduledTasks'
            $result | Should -Be $true
        }

        It 'Should not have Linux-specific capabilities on Windows' {
            Test-PlatformCapability -Capability 'XDoTool' | Should -Be $false
            Test-PlatformCapability -Capability 'SystemdInhibit' | Should -Be $false
        }

        It 'Should not have macOS-specific capabilities on Windows' {
            Test-PlatformCapability -Capability 'CliClick' | Should -Be $false
            Test-PlatformCapability -Capability 'Caffeinate' | Should -Be $false
        }
    }

    Context 'Linux-Specific Features' -Tag 'Linux' {
        It 'Should not have GUI capability on Linux' {
            $result = Test-PlatformCapability -Capability 'GUI'
            $result | Should -Be $false
        }

        It 'Should detect XDoTool or YDoTool if installed' {
            $hasXDoTool = Test-PlatformCapability -Capability 'XDoTool'
            $hasYDoTool = Test-PlatformCapability -Capability 'YDoTool'
            ($hasXDoTool -or $hasYDoTool) | Should -Be $true -Because 'At least one mouse tool should be available for testing'
        }

        It 'Should have SystemdTimers capability if systemctl is available' {
            $result = Test-PlatformCapability -Capability 'SystemdTimers'
            $result | Should -BeOfType [bool]
        }
    }

    Context 'macOS-Specific Features' -Tag 'MacOS' {
        It 'Should not have GUI capability on macOS' {
            $result = Test-PlatformCapability -Capability 'GUI'
            $result | Should -Be $false
        }

        It 'Should have Caffeinate capability on macOS' {
            $result = Test-PlatformCapability -Capability 'Caffeinate'
            $result | Should -Be $true -Because 'caffeinate is built-in on macOS'
        }

        It 'Should have LaunchD capability on macOS' {
            $result = Test-PlatformCapability -Capability 'LaunchD'
            $result | Should -Be $true
        }

        It 'Should detect CliClick if installed' -Skip:(-not (Get-Command cliclick -ErrorAction SilentlyContinue)) {
            $result = Test-PlatformCapability -Capability 'CliClick'
            $result | Should -Be $true
        }
    }
}

Describe 'Core Functionality' -Tag 'Integration', 'Windows', 'Linux', 'MacOS' {
    AfterEach {
        # Stop any running jobs after each test
        Stop-PSMouseJiggler -ErrorAction SilentlyContinue
    }

    Context 'Start and Stop Operations' {
        It 'Should start mouse jiggler with default parameters' {
            { Start-PSMouseJiggler -Duration 1 } | Should -Not -Throw
            Start-Sleep -Milliseconds 500
            Stop-PSMouseJiggler
        }

        It 'Should start mouse jiggler with custom interval' {
            { Start-PSMouseJiggler -Interval 500 -Duration 1 } | Should -Not -Throw
            Start-Sleep -Milliseconds 500
            Stop-PSMouseJiggler
        }

        It 'Should support all movement patterns' {
            $patterns = @('Random', 'Horizontal', 'Vertical', 'Circular')

            foreach ($pattern in $patterns) {
                { Start-PSMouseJiggler -MovementPattern $pattern -Duration 1 } | Should -Not -Throw
                Start-Sleep -Milliseconds 500
                Stop-PSMouseJiggler
            }
        }

        It 'Should stop mouse jiggler without errors' {
            Start-PSMouseJiggler -Duration 1
            Start-Sleep -Milliseconds 500
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }
    }

    Context 'Keep-Awake Functionality' {
        It 'Should start keep-awake with platform-appropriate methods' {
            $platform = Get-OperatingSystemPlatform

            # Use methods appropriate for the platform
            if ($platform -eq 'Windows') {
                { Start-KeepAwake -Methods @('SystemAPI') -Duration 1 } | Should -Not -Throw
            }
            elseif ($platform -eq 'Linux') {
                { Start-KeepAwake -Methods @('SystemAPI') -Duration 1 } | Should -Not -Throw
            }
            elseif ($platform -eq 'macOS') {
                { Start-KeepAwake -Methods @('SystemAPI') -Duration 1 } | Should -Not -Throw
            }

            Start-Sleep -Milliseconds 500
            Stop-PSMouseJiggler
        }
    }

    Context 'Incognito Mode' {
        It 'Should accept Incognito parameter for Start-PSMouseJiggler' {
            { Start-PSMouseJiggler -Incognito -Duration 1 } | Should -Not -Throw
            Start-Sleep -Milliseconds 500
            Stop-PSMouseJiggler
        }

        It 'Should accept Incognito parameter for Start-KeepAwake' {
            { Start-KeepAwake -Methods @('SystemAPI') -Incognito -Duration 1 } | Should -Not -Throw
            Start-Sleep -Milliseconds 500
            Stop-PSMouseJiggler
        }
    }
}

Describe 'Configuration Management' -Tag 'Unit', 'Windows', 'Linux', 'MacOS' {
    Context 'Configuration Operations' {
        It 'Should get default configuration' {
            $config = Get-Configuration
            $config | Should -Not -BeNullOrEmpty
            $config.Interval | Should -Be 1000
        }

        It 'Should update configuration' {
            { Update-Configuration -Interval 2000 } | Should -Not -Throw
            $config = Get-Configuration
            $config.Interval | Should -Be 2000
        }

        It 'Should reset configuration to defaults' {
            Update-Configuration -Interval 2000
            { Reset-Configuration } | Should -Not -Throw
            $config = Get-Configuration
            $config.Interval | Should -Be 1000
        }
    }
}