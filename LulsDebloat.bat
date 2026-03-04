@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Luls Debloater - Windows 10/11 (Safe v1)

:: ===========================
::  Luls Debloater - Safe v1
::  Windows 10/11
::  Author: Luls.lol
:: ===========================

:: ----- Setup log folder -----
set "LOGDIR=C:\LulsDebloater"
set "LOGFILE=%LOGDIR%\debloat.log"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1

call :log "==============================================="
call :log "Luls Debloater started: %DATE% %TIME%"
call :log "Running as: %USERNAME% on %COMPUTERNAME%"
call :log "==============================================="

:: ----- Require admin -----
net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo.
  echo [!] Admin rights required. Right-click this .bat and "Run as administrator".
  call :log "ERROR: Not running as admin. Exiting."
  pause
  exit /b 1
)

:: ----- Detect Windows version -----
for /f "tokens=2 delims==" %%a in ('wmic os get Caption /value ^| find "="') do set "OSCAP=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get Version /value ^| find "="') do set "OSVER=%%a"
call :log "OS: %OSCAP% (Version: %OSVER%)"

echo.
echo ==============================================
echo            Luls Debloater (Safe v1)
echo            Windows 10/11
echo ==============================================
echo This script removes common bloat apps and disables ad/suggestion features.
echo It does NOT touch Windows Update, Defender, or core system components.
echo Log: %LOGFILE%
echo.

:: ----- Restore point (best effort) -----
echo Creating restore point (best effort)...
call :log "Attempting restore point..."
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'Luls Debloater (Safe v1)' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue; 'OK' } catch { 'FAIL' }" ^
  >> "%LOGFILE%" 2>&1

:: ----- Confirm -----
choice /C YN /M "Continue with safe debloat actions?"
if errorlevel 2 (
  call :log "User chose NO. Exiting."
  echo Cancelled.
  pause
  exit /b 0
)

:: ===========================
:: Menu-like prompts
:: ===========================

echo.
choice /C YN /M "Remove common preinstalled Store apps (Candy Crush, etc)?"
set "DO_APPX=%errorlevel%"
:: errorlevel 1 = Y, 2 = N

echo.
choice /C YN /M "Disable Windows ads/suggestions/tips (recommended)?"
set "DO_ADS=%errorlevel%"

echo.
choice /C YN /M "Disable Xbox Game Bar / DVR features (recommended for non-gamers)?"
set "DO_XBOX=%errorlevel%"

echo.
choice /C YN /M "Windows 11 only: Disable Widgets/Chat integrations?"
set "DO_WIN11_UI=%errorlevel%"

echo.
choice /C YN /M "Apply extra telemetry reductions (safe, non-breaking)?"
set "DO_TELE=%errorlevel%"

echo.
echo ==============================================
echo Running tasks...
echo ==============================================

:: ===========================
:: Disable ads/suggestions/tips
:: ===========================
if "%DO_ADS%"=="1" (
  call :log "Applying: Disable ads/suggestions/tips"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryAllowed" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "OemPreInstalledAppsEnabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEnabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEverEnabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353694Enabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353696Enabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" "ScoobeSystemSettingEnabled" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "REG_DWORD" "0"
)

:: ===========================
:: Xbox / GameDVR off
:: ===========================
if "%DO_XBOX%"=="1" (
  call :log "Applying: Disable Xbox Game Bar / GameDVR"
  call :regset "HKCU\System\GameConfigStore" "GameDVR_Enabled" "REG_DWORD" "0"
  call :regset "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" "REG_DWORD" "0"
  call :regset "HKCU\SOFTWARE\Microsoft\GameBar" "AllowAutoGameMode" "REG_DWORD" "0"
  call :regset "HKCU\SOFTWARE\Microsoft\GameBar" "ShowStartupPanel" "REG_DWORD" "0"
  call :regset "HKCU\SOFTWARE\Microsoft\GameBar" "GamePanelStartupTipIndex" "REG_DWORD" "3"
)

:: ===========================
:: Telemetry reductions (safe)
:: ===========================
if "%DO_TELE%"=="1" (
  call :log "Applying: Telemetry reductions (safe)"
  call :regset "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "REG_DWORD" "0"
  call :regset "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "REG_DWORD" "0"
  call :regset "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "REG_DWORD" "1"
)

:: ===========================
:: Win11 UI: Widgets + Chat off
:: ===========================
if "%DO_WIN11_UI%"=="1" (
  call :log "Applying: Win11 Widgets/Chat disable (best effort)"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" "REG_DWORD" "0"
  call :regset "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" "REG_DWORD" "0"
)

:: ===========================
:: Remove common Appx bloat
:: ===========================
if "%DO_APPX%"=="1" (
  call :log "Applying: Remove common Appx bloat packages"
  call :removeapp "Microsoft.3DBuilder"
  call :removeapp "Microsoft.Microsoft3DViewer"
  call :removeapp "Microsoft.BingNews"
  call :removeapp "Microsoft.BingWeather"
  call :removeapp "Microsoft.GetHelp"
  call :removeapp "Microsoft.Getstarted"
  call :removeapp "Microsoft.Messaging"
  call :removeapp "Microsoft.MicrosoftOfficeHub"
  call :removeapp "Microsoft.MicrosoftSolitaireCollection"
  call :removeapp "Microsoft.MixedReality.Portal"
  call :removeapp "Microsoft.Office.OneNote"
  call :removeapp "Microsoft.OneConnect"
  call :removeapp "Microsoft.People"
  call :removeapp "Microsoft.SkypeApp"
  call :removeapp "Microsoft.Todos"
  call :removeapp "Microsoft.XboxApp"
  call :removeapp "Microsoft.XboxGamingOverlay"
  call :removeapp "Microsoft.XboxGameOverlay"
  call :removeapp "Microsoft.XboxIdentityProvider"
  call :removeapp "Microsoft.XboxSpeechToTextOverlay"
  call :removeapp "Microsoft.ZuneMusic"
  call :removeapp "Microsoft.ZuneVideo"
  call :removeapp "MicrosoftTeams"
  call :removeapp "SpotifyAB.SpotifyMusic"
  call :removeapp "Disney.37853FC22B2CE"
  call :removeapp "king.com.CandyCrushSaga"
  call :removeapp "king.com.CandyCrushSodaSaga"
  call :removeapp "king.com.BubbleWitch3Saga"
)

:: ===========================
:: Final polish: restart Explorer
:: ===========================
call :log "Restarting Explorer to apply UI changes"
taskkill /f /im explorer.exe >> "%LOGFILE%" 2>&1
start explorer.exe

echo.
echo ==============================================
echo Done.
echo ==============================================
echo Some changes may require a restart to fully apply.
echo Log saved to: %LOGFILE%
call :log "Completed successfully."
echo.
choice /C YN /M "Restart your PC now?"
if errorlevel 2 goto :end
shutdown /r /t 5
goto :end

:: ===========================
:: Functions
:: ===========================
:log
echo [%DATE% %TIME%] %*>> "%LOGFILE%"
exit /b 0

:regset
:: %1 key, %2 name, %3 type, %4 value
reg add "%~1" /v "%~2" /t "%~3" /d "%~4" /f >> "%LOGFILE%" 2>&1
exit /b 0

:removeapp
:: %1 package name (partial)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p='%~1';" ^
  "Get-AppxPackage -AllUsers | Where-Object { $_.Name -like '*'+$p+'*' } | ForEach-Object { try { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue } catch {} };" ^
  "Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like '*'+$p+'*' } | ForEach-Object { try { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue } catch {} }" ^
  >> "%LOGFILE%" 2>&1
exit /b 0

:end
echo.
pause
exit /b 0
