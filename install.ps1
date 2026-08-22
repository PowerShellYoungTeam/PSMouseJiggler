# This script installs the PSMouseJiggler PowerShell module

# Check for PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PowerShell version 5.0 or higher is required." -ForegroundColor Red
    exit 1
}

# Define installation directories
$documentsPath = [Environment]::GetFolderPath("MyDocuments")
$moduleBasePath = Join-Path $documentsPath "WindowsPowerShell\Modules"
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $moduleBasePath = Join-Path $documentsPath "PowerShell\Modules"
}

$sourceManifestPath = Join-Path $PSScriptRoot "src\PSMouseJiggler\PSMouseJiggler.psd1"
$moduleVersion = (Test-ModuleManifest -Path $sourceManifestPath).Version
$moduleRootPath = Join-Path $moduleBasePath "PSMouseJiggler"
$moduleInstallPath = Join-Path $moduleRootPath $moduleVersion

Write-Host "Installing PSMouseJiggler module to: $moduleInstallPath" -ForegroundColor Yellow

# Remove a legacy flat (unversioned) copy left by older versions of this script.
# A flat manifest sitting next to versioned subfolders makes Import-Module ignore it and load a stale version instead.
$legacyManifestPath = Join-Path $moduleRootPath "PSMouseJiggler.psd1"
if (Test-Path -Path $legacyManifestPath) {
    Write-Host "Removing legacy unversioned install at: $moduleRootPath" -ForegroundColor Yellow
    Get-ChildItem -Path $moduleRootPath -File | Remove-Item -Force
    Get-ChildItem -Path $moduleRootPath -Directory -Exclude $moduleVersion.ToString() -ErrorAction SilentlyContinue |
    Where-Object { -not (Test-Path (Join-Path $_.FullName "PSMouseJiggler.psd1")) } |
    Remove-Item -Recurse -Force
}

# Create module directory if it doesn't exist
if (-Not (Test-Path -Path $moduleInstallPath)) {
    New-Item -ItemType Directory -Path $moduleInstallPath -Force
}

# Copy module files to installation directory
Copy-Item -Path "$PSScriptRoot\src\PSMouseJiggler\*" -Destination $moduleInstallPath -Recurse -Force

# Install required modules if not already installed
$requiredModules = @('Pester')

foreach ($module in $requiredModules) {
    if (-Not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing required module: $module" -ForegroundColor Yellow
        Install-Module -Name $module -Force -Scope CurrentUser
    }
}

# Import the module to verify installation
try {
    Import-Module PSMouseJiggler -Force
    Write-Host "PSMouseJiggler module has been installed and imported successfully!" -ForegroundColor Green
    Write-Host "Available commands:" -ForegroundColor Cyan
    Get-Command -Module PSMouseJiggler | Format-Table Name, CommandType -AutoSize
    Write-Host "`nTo get started, run: Start-PSMouseJiggler" -ForegroundColor Yellow
    Write-Host "For GUI interface, run: Show-PSMouseJigglerGUI" -ForegroundColor Yellow
}
catch {
    Write-Host "Installation completed but there was an issue importing the module: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You may need to restart PowerShell or run 'Import-Module PSMouseJiggler' manually." -ForegroundColor Yellow
}