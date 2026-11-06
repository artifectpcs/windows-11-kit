# =====================================================================
#  02-Get-ISO-Export-Pro.ps1  -  Episode 02
#  BEFORE YOU RUN: download the Windows 11 x64 ISO yourself from
#                  https://www.microsoft.com/software-download/windows11
#                  This kit never contains or downloads Windows files.
#  WHAT IT DOES: Finds the newest ISO in your Downloads folder, shows its
#                SHA-256 hash so you can compare it with the value on
#                Microsoft's download page, copies its files into
#                C:\windowsbuild\iso, then exports ONLY the Windows 11
#                Pro edition into C:\windowsbuild\build\install.wim.
#  CHANGES ON YOUR PC: copies files into C:\windowsbuild. Your ISO in
#                      Downloads is never modified.
#  UNDO: delete the contents of C:\windowsbuild\iso and \build.
#  NOTE: Your license must match the edition you install (Pro).
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

$isoFile = (Get-ChildItem "$env:USERPROFILE\Downloads\*.iso" | Sort LastWriteTime -Descending | Select -First 1).FullName
if (-not $isoFile) { throw "No .iso found in Downloads. Download it from microsoft.com first." }
Write-Host "Using: $isoFile"
Write-Host "SHA256: $((Get-FileHash $isoFile -Algorithm SHA256).Hash)" -ForegroundColor Cyan
Write-Host "Compare that with the hash on Microsoft's download page before continuing." -ForegroundColor Cyan

$drive = (Mount-DiskImage -ImagePath $isoFile -PassThru | Get-Volume).DriveLetter
robocopy "${drive}:\" $Iso /E
attrib -r "$Iso\*" /S /D
Dismount-DiskImage -ImagePath $isoFile | Out-Null

$wim = "$Iso\sources\install.wim"
$pro = (Get-WindowsImage -ImagePath $wim | ? ImageName -eq 'Windows 11 Pro').ImageIndex
"Pro is index $pro"
dism /Export-Image /SourceImageFile:$wim /SourceIndex:$pro /DestinationImageFile:$Build\install.wim /Compress:max /CheckIntegrity
