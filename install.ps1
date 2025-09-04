# This script installs the PSMouseJiggler application, sets up necessary dependencies, and configures the environment.

# Check for PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PowerShell version 5.0 or higher is required." -ForegroundColor Red
    exit 1
}

# Define installation directory
$installDir = "$PSScriptRoot\src"

# Create installation directory if it doesn't exist
if (-Not (Test-Path -Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir
}

# Copy source files to installation directory
# Copy source files to installation directory
Copy-Item -Path "$PSScriptRoot\src\*" -Destination $installDir -Recurse -Force

# Install required modules if not already installed
$requiredModules = @('Pester')

foreach ($module in $requiredModules) {
    if (-Not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -Scope CurrentUser
    }
}

# Display installation success message
Write-Host "PSMouseJiggler has been installed successfully." -ForegroundColor Green
Write-Host "You can start using it by running 'src\PSMouseJiggler.ps1'." -ForegroundColor Yellow