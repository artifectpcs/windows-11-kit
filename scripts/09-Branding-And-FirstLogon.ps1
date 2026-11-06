# =====================================================================
#  09-Branding-And-FirstLogon.ps1  -  Episodes 09 and 11
#  WHAT IT DOES: Copies five small, readable files into the image:
#     - your wallpaper
#     - files\FirstLogon.ps1           sets the wallpaper, shows file
#                                      extensions, opens Explorer to This PC
#     - files\Remove-ReturningApps.ps1 OPTIONAL clean-up that runs for
#                                      14 days, logs everything, then
#                                      deletes its own scheduled task
#     - files\Sweep-List.txt           which apps that clean-up watches for
#     - files\LayoutModification.xml   taskbar pins: File Explorer + Edge
#   It also writes your name/model/support link into Settings > About.
#  DON'T WANT THE CLEAN-UP? Delete its line from the answer file
#     template, or empty Sweep-List.txt.
#  CHANGES ON YOUR PC: only the mounted image.
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

$scripts = "$Mount\Windows\Setup\Scripts"
$shell   = "$Mount\Users\Default\AppData\Local\Microsoft\Windows\Shell"
mkdir $scripts, "$Mount\Windows\Web\Wallpaper\Custom", $shell -Force | Out-Null
if (Test-Path $Wall) { Copy-Item $Wall "$Mount\Windows\Web\Wallpaper\Custom\wallpaper.jpg" }
else { Write-Host "No wallpaper at $Wall, skipping." -ForegroundColor Yellow }

Copy-Item "$Kit\files\FirstLogon.ps1", "$Kit\files\Remove-ReturningApps.ps1", "$Kit\files\Sweep-List.txt" $scripts
Copy-Item "$Kit\files\LayoutModification.xml" $shell

reg load HKLM\OFFSW "$Mount\Windows\System32\config\SOFTWARE"
$oem = 'HKLM\OFFSW\Microsoft\Windows\CurrentVersion\OEMInformation'
reg add $oem /v Manufacturer /t REG_SZ /d $Me /f
reg add $oem /v Model        /t REG_SZ /d $Model /f
reg add $oem /v SupportURL   /t REG_SZ /d $Url /f
[gc]::Collect(); Start-Sleep 2
reg unload HKLM\OFFSW

Get-ChildItem $scripts, "$Mount\Windows\Web\Wallpaper\Custom", $shell | Select Name
