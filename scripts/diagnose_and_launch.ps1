# Ma'a yegue - Diagnostic & Launch Script
# Run this to diagnose and fix common issues before launching the app

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Ma'a yegue - Diagnostic Script" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter installation
Write-Host "1. Checking Flutter installation..." -ForegroundColor Yellow
flutter --version
Write-Host ""

# Check connected devices
Write-Host "2. Checking connected devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# Check for Android device specifically
Write-Host "3. Checking ADB devices..." -ForegroundColor Yellow
adb devices
Write-Host ""

# Clean and rebuild
Write-Host "4. Cleaning build artifacts..." -ForegroundColor Yellow
flutter clean
Write-Host ""

Write-Host "5. Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Run doctor
Write-Host "6. Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor -v
Write-Host ""

# Analyze code
Write-Host "7. Analyzing code for errors..." -ForegroundColor Yellow
flutter analyze
Write-Host ""

Write-Host "===================================" -ForegroundColor Green
Write-Host "Diagnostic Complete!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

# Prompt for launch
$launch = Read-Host "Do you want to launch the app now? (y/n)"
if ($launch -eq "y" -or $launch -eq "Y") {
    Write-Host ""
    Write-Host "Launching Ma'a yegue..." -ForegroundColor Cyan
    Write-Host ""
    
    $device = Read-Host "Enter device ID (or press Enter for default)"
    if ($device) {
        flutter run -d $device
    } else {
        flutter run
    }
} else {
    Write-Host ""
    Write-Host "To launch manually, run:" -ForegroundColor Yellow
    Write-Host "  flutter run" -ForegroundColor White
    Write-Host "Or for specific device:" -ForegroundColor Yellow
    Write-Host "  flutter run -d <device-id>" -ForegroundColor White
    Write-Host ""
}
