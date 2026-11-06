# =====================================================================
#  06-Features.ps1  -  Episode 06
#  WHAT IT DOES: Turns on .NET 3.5 (older games and launchers need it),
#     turns off Work Folders and legacy Windows Media Player, and
#     removes four unused capabilities.
#  LEFT ALONE ON PURPOSE: DirectX.Configuration.Database (games),
#     all Wifi.Client / Ethernet.Client drivers (network), Hello.Face,
#     Language packs, VBSCRIPT, PowerShell ISE.
#  WORKLOAD OPTION: building a developer or local-AI PC? Uncomment the
#     Hyper-V / WSL / Sandbox lines at the bottom.
#  CHANGES ON YOUR PC: only the mounted image.
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

dism /Image:$Mount /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:$Iso\sources\sxs
dism /Image:$Mount /Disable-Feature /FeatureName:WorkFolders-Client
dism /Image:$Mount /Disable-Feature /FeatureName:WindowsMediaPlayer

'App.StepsRecorder~~~~0.0.1.0','Browser.InternetExplorer~~~~0.0.11.0','MathRecognizer~~~~0.0.1.0','Media.WindowsMediaPlayer~~~~0.0.12.0' | % {
  Write-Host "Removing $_" -ForegroundColor DarkYellow
  Remove-WindowsCapability -Path $Mount -Name $_ | Out-Null
}

# --- Developer / local-AI PCs only: remove the # to enable ---
# dism /Image:$Mount /Enable-Feature /FeatureName:Microsoft-Hyper-V-All /All
# dism /Image:$Mount /Enable-Feature /FeatureName:Microsoft-Windows-Subsystem-Linux /All
# dism /Image:$Mount /Enable-Feature /FeatureName:VirtualMachinePlatform /All
# dism /Image:$Mount /Enable-Feature /FeatureName:Containers-DisposableClientVM /All
