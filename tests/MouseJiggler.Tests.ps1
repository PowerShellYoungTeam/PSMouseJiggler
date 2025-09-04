# PSMouseJiggler.Tests.ps1

Describe 'PSMouseJiggler Functionality Tests' {

    BeforeAll {
        # Load the main PSMouseJiggler script
        . "$PSScriptRoot/../src/PSMouseJiggler.ps1"
    }

    It 'Should simulate mouse movement' {
        # Arrange
        $initialPosition = [System.Windows.Forms.Cursor]::Position

        # Act
        Start-PSMouseJiggler -Duration 1 -MovementPattern 'Random'

        # Wait for a short duration to allow movement
        Start-Sleep -Seconds 1

        # Assert
        $newPosition = [System.Windows.Forms.Cursor]::Position
        $newPosition | Should -Not -BeExactly $initialPosition
    }

    It 'Should stop jiggling when requested' {
        # Arrange
        Start-PSMouseJiggler -Duration 5 -MovementPattern 'Random'
        Start-Sleep -Seconds 2

        # Act
        Stop-PSMouseJiggler

        # Wait for a short duration to ensure jiggling has stopped
        Start-Sleep -Seconds 1

        # Assert
        $finalPosition = [System.Windows.Forms.Cursor]::Position
        $finalPosition | Should -BeExactly $newPosition
    }

    It 'Should load configuration settings' {
        # Act
        $config = Load-Configuration

        # Assert
        $config | Should -Not -BeNullOrEmpty
        $config.MovementSpeed | Should -BeGreaterThan 0
    }

    It 'Should save configuration settings' {
        # Arrange
        $config = @{
            MovementSpeed = 10
            MovementPattern = 'Linear'
        }

        # Act
        Save-Configuration -Config $config

        # Assert
        $loadedConfig = Load-Configuration
        $loadedConfig.MovementSpeed | Should -Be 10
        $loadedConfig.MovementPattern | Should -Be 'Linear'
    }
}