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
                'Show-PSMouseJigglerGUI',
                'Start-KeepAwake'
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
            { Start-KeepAwake -Duration 1 } | Should -Not -Throw
            Start-Sleep -Seconds 2

            # Step 4: Stop the keep-awake functionality
            { Stop-PSMouseJiggler } | Should -Not -Throw
        }
    }
}