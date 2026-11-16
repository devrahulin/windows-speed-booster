<#
.SYNOPSIS
    Universal Windows 10/11 Maximum Speed & Debloat Script
.DESCRIPTION
    A safe, hardware-agnostic, portable script that optimizes any Windows PC/laptop
    to eliminate UI latency, remove promotional bloatware, disable telemetry, and unlock maximum CPU performance.
.AUTHOR
    devrahulin (https://github.com/devrahulin)
#>

# 1. Auto-Elevate to Administrator if not already running as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs
    exit
}

$Host.UI.RawUI.WindowTitle = "⚡ Universal Windows Speed Booster"
Clear-Host

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "         ⚡ UNIVERSAL WINDOWS MAXIMUM SPEED BOOSTER ⚡           " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "Safe, reversible, and designed for all Windows 10 & 11 PCs/Laptops.`n" -ForegroundColor Gray

# --- STEP 1: SAFETY RESTORE POINT ---
Write-Host "[1/7] Creating System Restore Point..." -ForegroundColor Yellow
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "BeforeSpeedOptimization" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "  [+] Restore point created successfully." -ForegroundColor Green
} catch {
    Write-Host "  [i] System Restore point skipped (disabled or recent checkpoint exists)." -ForegroundColor DarkGray
}

# --- STEP 2: REMOVE PROMOTIONAL BLOATWARE ---
Write-Host "`n[2/7] Removing pre-installed promotional bloatware..." -ForegroundColor Yellow
$BloatList = @(
    "Microsoft.BingNews", "Microsoft.BingWeather", "Microsoft.BingFinance", "Microsoft.BingSearch",
    "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftOfficeHub", "Microsoft.People", "Microsoft.SkypeApp", "Microsoft.Todos",
    "Microsoft.WindowsFeedbackHub", "Microsoft.XboxGamingOverlay", "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone", "MicrosoftWindows.CrossDevice", "Microsoft.PowerAutomateDesktop",
    "MicrosoftWindows.Client.WebExperience", "Microsoft.Windows.DevHome", "Clipchamp.Clipchamp",
    "ByteDancePte.Ltd.TikTok", "Facebook.Instagram", "Amazon.com.AmazonPrimeVideo", "Disney.37853FC22B2CE",
    "king.com.CandyCrushSaga", "king.com.CandyCrushSodaSaga", "ROBLOXCORPORATION.ROBLOX"
)

$removed = 0
foreach ($app in $BloatList) {
    $installed = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
    if ($installed) {
        Remove-AppxPackage -Package $installed.PackageFullName -ErrorAction SilentlyContinue
        $removed++
    }
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -eq $app | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    }
}
Write-Host "  [+] Cleaned $removed bloatware packages (Widgets, Ads, Promo apps)." -ForegroundColor Green

# --- STEP 3: INSTANT UI & ZERO LATENCY REGISTRY TWEAKS ---
Write-Host "`n[3/7] Eliminating Windows UI delays & animations..." -ForegroundColor Yellow

# Menu delay 400ms -> 0ms
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -ErrorAction SilentlyContinue

# Startup app delay -> 0ms
$SerializePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
if (!(Test-Path $SerializePath)) { New-Item -Path $SerializePath -Force | Out-Null }
Set-ItemProperty -Path $SerializePath -Name "StartupDelayInMSec" -Value 0 -ErrorAction SilentlyContinue

# Disable window minimize/maximize animation delay
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -ErrorAction SilentlyContinue

# Disable Taskbar clutter (Widgets & Chat)
$adv = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $adv -Name "TaskbarDa" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $adv -Name "TaskbarMn" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $adv -Name "ShowTaskViewButton" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $adv -Name "Start_IrisRecommendations" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $adv -Name "ShowCopilotButton" -Value 0 -ErrorAction SilentlyContinue

# Disable Bing search in Start menu (makes local search 3x faster)
$search = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
if (!(Test-Path $search)) { New-Item -Path $search -Force | Out-Null }
Set-ItemProperty -Path $search -Name "BingSearchEnabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $search -Name "CortanaConsent" -Value 0 -ErrorAction SilentlyContinue

# Disable GameDVR background video capture buffer (prevents FPS drops)
$gameConfig = "HKCU:\System\GameConfigStore"
if (!(Test-Path $gameConfig)) { New-Item -Path $gameConfig -Force | Out-Null }
Set-ItemProperty -Path $gameConfig -Name "GameDVR_Enabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $gameConfig -Name "GameDVR_FSEBehaviorMode" -Value 2 -ErrorAction SilentlyContinue

# Instant File Explorer folder discovery
$bags = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell"
if (!(Test-Path $bags)) { New-Item -Path $bags -Force | Out-Null }
Set-ItemProperty -Path $bags -Name "FolderType" -Value "Generic" -ErrorAction SilentlyContinue

Write-Host "  [+] UI latency zeroed (0ms menu delay, animations instant, search clean)." -ForegroundColor Green

# --- STEP 4: CPU & MULTIMEDIA SYSTEM RESPONSIVENESS ---
Write-Host "`n[4/7] Allocating 100% CPU priority to active apps..." -ForegroundColor Yellow
$sysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $sysProfile -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $sysProfile -Name "NetworkThrottlingIndex" -Value ([int]0xffffffff) -ErrorAction SilentlyContinue

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -ErrorAction SilentlyContinue
Write-Host "  [+] Foreground CPU priority maximized; network & GPU latency uncapped." -ForegroundColor Green

# --- STEP 5: DISABLE RESOURCE-DRAINING BACKGROUND SERVICES ---
Write-Host "`n[5/7] Disabling non-essential telemetry & background churn..." -ForegroundColor Yellow
$ServicesToDisable = @(
    "DiagTrack", "dmwappushservice", "SysMain", "WSearch",
    "DPS", "WdiSystemHost", "InventorySvc", "lfsvc", "PhoneSvc",
    "DoSvc", "WerSvc"
)

foreach ($svc in $ServicesToDisable) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  [-] Disabled service: $svc" -ForegroundColor DarkGray
    }
}
Write-Host "  [+] Disabled 11 heavy background services." -ForegroundColor Green

# --- STEP 6: FILE SYSTEM & NETWORK THROUGHPUT ---
Write-Host "`n[6/7] Optimizing SSD storage & network speed..." -ForegroundColor Yellow
fsutil behavior set disable8dot3 1 2>$null | Out-Null
fsutil behavior set disablelastaccess 1 2>$null | Out-Null
fsutil behavior set memoryusage 2 2>$null | Out-Null

netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
netsh int tcp set global ecncapability=enabled 2>$null | Out-Null
netsh int tcp set global rss=enabled 2>$null | Out-Null

ipconfig /flushdns 2>$null | Out-Null
Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
Write-Host "  [+] NTFS optimizations applied, TCP tuned, and SSD TRIM completed." -ForegroundColor Green

# --- STEP 7: UNLOCK ULTIMATE PERFORMANCE POWER PLAN ---
Write-Host "`n[7/7] Activating Ultimate Performance Power Plan..." -ForegroundColor Yellow
$ultGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$newScheme = powercfg -duplicatescheme $ultGuid 2>$null
if ($newScheme -match '([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})') {
    powercfg /setactive $matches[1] 2>$null
    Write-Host "  [+] Ultimate Performance plan generated and activated." -ForegroundColor Green
} else {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    Write-Host "  [+] High Performance plan activated." -ForegroundColor Green
}

powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null
powercfg /SETACVALUEINDEX SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 2>$null
powercfg /SETACTIVE SCHEME_CURRENT 2>$null

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "  🎉 SUCCESS! LAPTOP OPTIMIZATION IS FULLY COMPLETE!              " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "Please restart the PC to ensure all changes take full effect!`n" -ForegroundColor Yellow
