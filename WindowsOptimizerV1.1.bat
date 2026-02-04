@echo off
color 0B
setlocal enabledelayedexpansion
title Windows Optimizer 1.1
set "t_d=0"
set "b_d=0"
set "p_d=0"

:check_permissions
fltmc >nul 2>&1  
if %errorlevel% equ 0 (
    goto :menu 
) else (
    echo [ERROR] Please right-click and "Run as Administrator".
    pause
    goto :eof
)

:menu
cls
echo =========================================
echo         WINDOWS OPTIMIZER v1.1
echo =========================================
if %t_d%==1 (echo [1] Remove Telemetry [DONE]) else (echo [1] Remove Telemetry)
if %b_d%==1 (echo [2] Remove Bloatware Apps [DONE]) else (echo [2] Remove Bloatware Apps)
if %p_d%==1 (echo [3] Main Performance Tweaks [DONE]) else (echo [3] Main Performance Tweaks)
echo [4] Exit
echo =========================================
if %t_d%==1 if %b_d%==1 if %p_d%==1 goto :phase2
choice /c 1234 /n /m "Select an option: "
if errorlevel 4 exit
if errorlevel 3 goto :performance
if errorlevel 2 goto :bloatware
if errorlevel 1 goto :telemetry

:telemetry
echo Processing Telemetry...
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
set "t_d=1"
echo [OK] Telemetry Disabled.
timeout /t 2 >nul
goto :menu

:bloatware
echo Removing Bloatware...
powershell -Command "& {Get-AppxPackage *3dbuilder* | Remove-AppxPackage}" >nul 2>&1
powershell -Command "& {Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage}" >nul 2>&1
powershell -Command "& {Get-AppxPackage *skypeapp* | Remove-AppxPackage}" >nul 2>&1
powershell -Command "& {Get-AppxPackage *zunemusic* | Remove-AppxPackage}" >nul 2>&1
powershell -Command "& {Get-AppxPackage *bingweather* | Remove-AppxPackage}" >nul 2>&1
powershell -Command "& {Get-AppxPackage *feedbackhub* | Remove-AppxPackage}" >nul 2>&1
set "b_d=1"
echo [OK] Bloatware Removed.
timeout /t 2 >nul
goto :menu

:performance
echo Applying Tweaks...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul 2>&1
powercfg -h off >nul 2>&1
sc stop WSearch >nul 2>&1
sc config WSearch start= disabled >nul 2>&1
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
sc stop TrkWks >nul 2>&1
sc config TrkWks start= disabled >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1
set "p_d=1"
echo [OK] Performance Tweaks Applied.
timeout /t 2 >nul
goto :menu

:phase2
echo.
echo All basic optimizations complete.
echo Launching Phase 2: Gaming optimizations...
timeout /t 3
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex (irm 'https://raw.githubusercontent.com/RealSteel99-codes/Windows-Optimizer/main/WindowsOptimizerPhase2.ps1')"
echo.
echo Phase 2 Execution Finished.
echo It is recommended to restart your PC now.
pause
exit


