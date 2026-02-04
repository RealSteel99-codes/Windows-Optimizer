function Optimize-GPU {
    Write-Host "Detecting Graphics Hardware..." -ForegroundColor Cyan
    $GpuInfo = Get-CimInstance Win32_VideoController
    $GpuName = $GpuInfo.Name
    Write-Host "Found: $GpuName" -ForegroundColor Yellow

    
    $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (-not (Test-Path $gpuPath)) { New-Item -Path $gpuPath -Force | Out-Null }
    Set-ItemProperty -Path $gpuPath -Name "HwSchMode" -Value 2 -Force

    # --- NVIDIA SPECIFIC TWEAKS ---
    if ($GpuName -like "*NVIDIA*") {
        Write-Host "Applying NVIDIA Latency Tweaks..." -ForegroundColor Green
        # Disables NVIDIA Telemetry Container services
        Get-Service -Name "NvTelemetryContainer" -ErrorAction SilentlyContinue | Stop-Service -PassThru | Set-Service -StartupType Disabled
        
        # Power Management: Prefer Maximum Performance 
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableRID73779 /t REG_DWORD /d 1 /f
    } 
    
    # --- AMD SPECIFIC TWEAKS ---
    elseif ($GpuName -like "*AMD*" -or $GpuName -like "*Radeon*") {
        Write-Host "Applying AMD Radeon Tweaks..." -ForegroundColor Green
        # Disable AMD Crash Defender and External Events (known for stuttering)
        Get-Service -Name "AMDRadeonSoftware" -ErrorAction SilentlyContinue | Set-Service -StartupType Manual
        Get-Service -Name "AMD External Events Utility" -ErrorAction SilentlyContinue | Stop-Service | Set-Service -StartupType Disabled
        
        # Disable ULPS (Ultra Low Power State)
        $ulps = Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Control\Video -Recurse | Where-Object { $_.Name -like "*0000" }
        foreach ($key in $ulps) {
            if (Get-ItemProperty -Path $key.PSPath -Name "EnableUlps" -ErrorAction SilentlyContinue) {
                Set-ItemProperty -Path $key.PSPath -Name "EnableUlps" -Value 0
            }
        }
    }
}

#Set Ultimate power plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
$ultimatePlan = powercfg -list | Select-String "Ultimate Performance"
if ($ultimatePlan) {
    $guid = $ultimatePlan.ToString().Split()[3]
    powercfg -setactive $guid
}
# Disable Game DVR
$registryPaths = @(
    "HKCU:\System\GameConfigStore",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
)

Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Value 0
# Disables GameBar Presence Writer (part of the FSE lag issue)
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartPanel" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d 0 /f
Optimize-GPU
Write-Host "All optimizations applied! Please reboot." -ForegroundColor Green
