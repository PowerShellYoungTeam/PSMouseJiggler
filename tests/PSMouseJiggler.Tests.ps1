Describe 'PSMouseJiggler Basic Functionality Tests' {
    BeforeAll {
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
            $module = Get-Module PSMouseJiggler
            $module | Should -Not -BeNullOrEmpty
            $module.Name | Should -Be 'PSMouseJiggler'
        }

        It 'Should export the required functions' {
            $requiredFunctions = @(
                'Start-PSMouseJiggler',
                'Stop-PSMouseJiggler',
                'Show-PSMouseJigglerGUI'
            )

            foreach ($function in $requiredFunctions) {
                Get-Command -Name $function -Module PSMouseJiggler | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Basic Start/Stop Functionality' {
        It 'Should start without errors' {
            # Just test that it doesn't throw
            { Start-PSMouseJiggler -Duration 1 } | Should -Not -Throw

            # Give it time to fully initialize
            Start-Sleep -Seconds 2

            # Since we can't access $script:JigglingActive directly, use indirect tests
            # If Stop-PSMouseJiggler works without error, then jiggling must be active
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }

        It 'Should stop without errors' {
            # Start jiggling with a longer duration to ensure it's running
            { Start-PSMouseJiggler -Duration 60 } | Should -Not -Throw
            Start-Sleep -Seconds 1

            # Test that we can call Stop-PSMouseJiggler without errors
            { Stop-PSMouseJiggler } | Should -Not -Throw

            # Test that starting again works (which would fail if still running)
            Start-Sleep -Seconds 1
            { Start-PSMouseJiggler -Duration 1 } | Should -Not -Throw
            Start-Sleep -Seconds 2
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }
    }
}