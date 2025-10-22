# Validation Script for PSMouseJiggler
# This script validates that all components work correctly with the new structure

Write-Host "PSMouseJiggler Validation Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

$errors = @()
$successes = @()

# Test 1: Module Manifest Validation
Write-Host "1. Testing module manifest..." -ForegroundColor Yellow
try {
    $manifest = Test-ModuleManifest -Path "src\PSMouseJiggler\PSMouseJiggler.psd1" -ErrorAction Stop
    $successes += "✓ Module manifest is valid (Version: $($manifest.Version))"
}
catch {
    $errors += "✗ Module manifest validation failed: $($_.Exception.Message)"
}

# Test 2: Module Import
Write-Host "2. Testing module import..." -ForegroundColor Yellow
try {
    Remove-Module PSMouseJiggler -ErrorAction SilentlyContinue
    $fullPath = Join-Path $PSScriptRoot "src\PSMouseJiggler\PSMouseJiggler.psd1"
    Import-Module $fullPath -Force -ErrorAction Stop
    $successes += "✓ Module imported successfully"
}
catch {
    $errors += "✗ Module import failed: $($_.Exception.Message)"
}

# Test 3: Function Availability
Write-Host "3. Testing function availability..." -ForegroundColor Yellow
$expectedFunctions = @(
    'Start-PSMouseJiggler',
    'Stop-PSMouseJiggler',
    'Show-PSMouseJigglerGUI',
    'Get-Configuration'
)

foreach ($func in $expectedFunctions) {
    try {
        Get-Command $func -ErrorAction Stop | Out-Null
        $successes += "✓ Function '$func' is available"
    }
    catch {
        $errors += "✗ Function '$func' not found"
    }
}

# Test 4: Configuration System
Write-Host "4. Testing configuration system..." -ForegroundColor Yellow
try {
    $config = Get-Configuration -ErrorAction Stop
    if ($config) {
        $successes += "✓ Configuration system works"
    }
    else {
        $errors += "✗ Configuration system returned null"
    }
}
catch {
    $errors += "✗ Configuration system failed: $($_.Exception.Message)"
}

# Test 5: Pester Tests
Write-Host "5. Running Pester tests..." -ForegroundColor Yellow
try {
    $testResult = Invoke-Pester -Path "tests\PSMouseJiggler.Module.Tests.ps1" -PassThru -ErrorAction Stop
    if ($testResult.FailedCount -eq 0) {
        $successes += "✓ All $($testResult.PassedCount) Pester tests passed"
    }
    else {
        $errors += "✗ $($testResult.FailedCount) Pester tests failed"
    }
}
catch {
    $errors += "✗ Pester tests failed to run: $($_.Exception.Message)"
}

# Test 6: CI/CD Paths
Write-Host "6. Validating CI/CD workflow paths..." -ForegroundColor Yellow
$ciContent = Get-Content ".github\workflows\ci.yml" -Raw
$releaseContent = Get-Content ".github\workflows\release.yml" -Raw

if ($ciContent -match "src/PSMouseJiggler/PSMouseJiggler\.psd1") {
    $successes += "✓ CI workflow uses correct path"
}
else {
    $errors += "✗ CI workflow path is incorrect"
}

if ($releaseContent -match "src\\PSMouseJiggler\\") {
    $successes += "✓ Release workflow uses correct path"
}
else {
    $errors += "✗ Release workflow path is incorrect"
}

# Results Summary
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "VALIDATION RESULTS" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan

Write-Host "`nSuccesses ($($successes.Count)):" -ForegroundColor Green
$successes | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }

if ($errors.Count -gt 0) {
    Write-Host "`nErrors ($($errors.Count)):" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host "`nValidation FAILED" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "`nValidation PASSED - All components working correctly!" -ForegroundColor Green
    Write-Host "The PSMouseJiggler module is ready for use and deployment." -ForegroundColor Green
}

# Cleanup
Remove-Module PSMouseJiggler -ErrorAction SilentlyContinue
