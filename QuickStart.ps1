# PSMouseJiggler Quick Start Demo
# This script demonstrates basic usage of the PSMouseJiggler module

Write-Host "PSMouseJiggler Quick Start Demo" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# Import the module
Write-Host "1. Importing PSMouseJiggler module..." -ForegroundColor Yellow
Import-Module .\PSMouseJiggler\PSMouseJiggler.psd1 -Force

# Show available commands
Write-Host "`n2. Available commands:" -ForegroundColor Yellow
Get-Command -Module PSMouseJiggler | Format-Table Name, CommandType -AutoSize

# Show current configuration
Write-Host "`n3. Current configuration:" -ForegroundColor Yellow
$config = Get-Configuration
$config | Format-List

# Demonstrate help system
Write-Host "`n4. Getting help for main functions:" -ForegroundColor Yellow
Write-Host "   - Start-PSMouseJiggler: " -NoNewline
Get-Help Start-PSMouseJiggler
Write-Host "   - Stop-PSMouseJiggler: " -NoNewline
Get-Help Stop-PSMouseJiggle
Write-Host "   - Show-PSMouseJigglerGUI: " -NoNewline
Get-Help Show-PSMouseJigglerGUI

Write-Host "`n5. Usage examples:" -ForegroundColor Yellow
Write-Host "   # Start with default settings:"
Write-Host "   Start-PSMouseJiggler" -ForegroundColor Cyan
Write-Host ""
Write-Host "   # Start with custom settings:"
Write-Host "   Start-PSMouseJiggler -Interval 5000 -MovementPattern 'Figure8' -Duration 600" -ForegroundColor Cyan
Write-Host ""
Write-Host "   # Show GUI interface:"
Write-Host "   Show-PSMouseJigglerGUI" -ForegroundColor Cyan
Write-Host ""
Write-Host "   # Stop jiggling:"
Write-Host "   Stop-PSMouseJiggler" -ForegroundColor Cyan

Write-Host "`nQuick Start Demo completed!" -ForegroundColor Green
Write-Host "The PSMouseJiggler module is ready to use." -ForegroundColor Green
