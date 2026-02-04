@echo off
color 0B
setlocal enabledelayedexpansion
title Windows Optimizer 1.0
goto :check_permissions

:check_permissions
echo Checking for permissions...
fltmc >nul 2>&1  
if %errorlevel% equ 0 (
    echo [SUCCESS] CMD is running with elevated privileges.
    goto :menu 
) else (
    echo [ERROR] CMD is NOT running as Administrator.
    echo Please right-click and "Run as Administrator".
    pause
    goto :eof
)

:menu
color 0B
cls
echo =========================================
echo       WINDOWS OPTIMIZER v1.0
echo =========================================
echo [1] Remove Telemetry 
echo [2] Remove Bloatware Apps
echo [3] Main Performance Tweaks
echo [4] Exit
echo =========================================
choice /c 1234 /n /m "Select an option: "

if errorlevel 4 exit
if errorlevel 3 goto :performance
if errorlevel 2 goto :bloatware
if errorlevel 1 goto :telemetry

:telemetry
echo Disabling Telemetry...
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f
reg query "HKCU\Software\Microsoft\IdentityCRL\UserExtendedProperties" >nul 2>&1
if %errorlevel% equ 0 (
    echo [Notice] You are signed into a Microsoft account. it is HIGHLY reccomended you switch to a lcoal account, as an online account adds significant bloat and extra tracking.
    timeout 2
    goto :menu
) else (
    echo Done!
    timeout 2
    goto :menu
)

:bloatware
echo Removing bloatware apps...
rem This removes common bloatware
powershell -Command "& {Get-AppxPackage *3dbuilder* | Remove-AppxPackage}"
powershell -Command "& {Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage}"
powershell -Command "& {Get-AppxPackage *skypeapp* | Remove-AppxPackage}"
powershell -Command "& {Get-AppxPackage *zunemusic* | Remove-AppxPackage}"
powershell -Command "& {Get-AppxPackage *bingweather* | Remove-AppxPackage}"
powershell -Command "& {Get-AppxPackage *feedbackhub* | Remove-AppxPackage}"
echo Bloatware removal complete!
timeout 2
goto :menu

:performance
echo Applying Performance Tweaks...
rem 1. Disable Transparency effects (Visual)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
rem 2. Prioritize Programs over Background Services
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul 2>&1
rem 3. Disable Hibernation to save disk space and reduce writes
powercfg -h off >nul 2>&1
rem 4. Disable Search Indexing Service (Heavy Disk Usage)
sc stop WSearch >nul 2>&1
sc config WSearch start= disabled >nul 2>&1
rem 5. Disable SysMain (formerly Superfetch)
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
rem 6. Disable Distributed Link Tracking Client
sc stop TrkWks >nul 2>&1
sc config TrkWks start= disabled >nul 2>&1
rem Clean network cache
ipconfig /flushdns >nul 2>&1
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1
echo Performance Tweaks Applied!
timeout 2
goto :menu

