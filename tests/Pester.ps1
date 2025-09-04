# Describe the Pester testing framework and set it up for the PSMouseJiggler project. This file will include the necessary imports and configurations to run the tests defined in PSMouseJiggler.Tests.ps1.

# Pester.ps1

# Import the Pester module
Import-Module Pester

# Define the path to the tests
# Point tests to the PSMouseJiggler test file
$testPath = Join-Path -Path $PSScriptRoot -ChildPath 'PSMouseJiggler.Tests.ps1'

# Run the tests
Invoke-Pester -Script $testPath -OutputFormat NUnitXml -OutputFile "$PSScriptRoot\TestResults.xml" -PassThru | Out-Null

# Optionally, you can add additional configurations or test settings here.