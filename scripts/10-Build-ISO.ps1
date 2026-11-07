# =====================================================================
#  10-Build-ISO.ps1  -  Episode 12
#  BEFORE YOU RUN: close every File Explorer window inside the mount
#     folder (the #1 cause of "files in use").
#  WHAT IT DOES: Saves your changes and unmounts the image, compresses it
#     with Microsoft's recovery compression (Setup reads it natively),
#     and builds a bootable ISO: C:\windowsbuild\My-Windows11.iso
#  NEXT: write the ISO to a 16 GB+ USB drive with Rufus (GPT, UEFI) and
#     install on TEST hardware first. See the README.
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

Push-Location $Root
dism /Unmount-Image /MountDir:$Mount /Commit

Remove-Item "$Iso\sources\install.wim" -ErrorAction SilentlyContinue
dism /Export-Image /SourceImageFile:$Build\install.wim /SourceIndex:1 /DestinationImageFile:$Iso\sources\install.esd /Compress:recovery

$adk = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg"
& "$adk\oscdimg.exe" -m -o -u2 -udfver102 "-bootdata:2#p0,e,b$adk\etfsboot.com#pEF,e,b$adk\efisys.bin" $Iso "$Root\My-Windows11.iso"
Pop-Location
