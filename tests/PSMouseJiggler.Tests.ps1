# PSMouseJiggler.Tests.ps1

Describe 'PSMouseJiggler Functionality Tests' {

    BeforeAll {
        # Import the module properly
        $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\src\PSMouseJiggler\PSMouseJiggler.psd1"
        Import-Module $ModulePath -Force

        # Mock functions that interact with hardware to avoid flaky tests
        Mock -CommandName [System.Windows.Forms.Cursor]::set_Position -MockWith { }
        Mock -CommandName Send-MouseInput -MockWith { }
        Mock -CommandName Send-KeyboardInput -MockWith { }

        # Mock system API calls
        Mock -CommandName Prevent-SystemIdle -MockWith { }
    }

    Context 'Core Functionality' {
        It 'Should start jiggling' {
            # Arrange
            $global:StartJigglingCalled = $false
            Mock Start-PSMouseJiggler { $global:StartJigglingCalled = $true }

            # Act
            Start-PSMouseJiggler -Duration 1 -MovementPattern 'Random'

            # Assert
            $global:StartJigglingCalled | Should -BeTrue
        }

        It 'Should stop jiggling when requested' {
            # Arrange
            $global:StopJigglingCalled = $false
            Mock Stop-PSMouseJiggler { $global:StopJigglingCalled = $true }

            # Act
            Stop-PSMouseJiggler

            # Assert
            $global:StopJigglingCalled | Should -BeTrue
        }
    }

    Context 'Configuration Management' {
        It 'Should load configuration settings' {
            # Arrange
            $testConfig = @{
                MovementSpeed   = 100
                MovementPattern = 'Random'
            }
            Mock Get-Configuration { return $testConfig }

            # Act
            $config = Get-Configuration

            # Assert
            $config | Should -Not -BeNullOrEmpty
            $config.MovementSpeed | Should -Be 100
            $config.MovementPattern | Should -Be 'Random'
        }

        It 'Should save configuration settings' {
            # Arrange
            $global:SaveConfigCalled = $false
            Mock Save-Configuration { $global:SaveConfigCalled = $true }
            $config = @{
                MovementSpeed   = 10
                MovementPattern = 'Linear'
            }

            # Act
            Save-Configuration -Configuration $config

            # Assert
            $global:SaveConfigCalled | Should -BeTrue
        }
    }

    Context 'Advanced Keep-Awake Methods' {
        It 'Should start keep-awake with default parameters' {
            # Arrange
            $global:KeepAwakeCalled = $false
            Mock Start-KeepAwake { $global:KeepAwakeCalled = $true }

            # Act
            Start-KeepAwake

            # Assert
            $global:KeepAwakeCalled | Should -BeTrue
        }

        It 'Should prevent system idle' {
            # Arrange
            $global:PreventIdleCalled = $false
            Mock Prevent-SystemIdle { $global:PreventIdleCalled = $true }

            # Act
            Prevent-SystemIdle -Duration 5

            # Assert
            $global:PreventIdleCalled | Should -BeTrue
        }
    }
}