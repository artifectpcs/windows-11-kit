# =====================================================================
#  01-Setup-Workspace.ps1  -  Episode 01
#  WHAT IT DOES: Creates the four working folders and installs the
#                Windows ADK with ONLY the Deployment Tools feature
#                (that's where oscdimg.exe, the ISO builder, lives).
#  CHANGES ON YOUR PC: new folders under C:\windowsbuild; installs the
#                Microsoft ADK Deployment Tools from winget.
#  UNDO: delete C:\windowsbuild; uninstall "Windows Assessment and
#        Deployment Kit" from Settings > Apps.
#  RUN AS: PowerShell / Terminal (Admin)
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

mkdir $Iso, $Build, $Mount, "$Build\updates" -Force | Out-Null
Write-Host "Folders ready under $Root" -ForegroundColor Green

winget install --id Microsoft.WindowsADK -e --source winget --accept-source-agreements --accept-package-agreements --override "/quiet /norestart /features OptionId.DeploymentTools"

$oscdimg = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
if (Test-Path $oscdimg) { Write-Host "oscdimg found: ready for step 10" -ForegroundColor Green }
else { Write-Host "oscdimg not found yet. Re-run after the ADK install finishes." -ForegroundColor Yellow }
