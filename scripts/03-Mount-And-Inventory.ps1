# =====================================================================
#  03-Mount-And-Inventory.ps1  -  Episode 03
#  WHAT IT DOES: Mounts your working Pro image into C:\windowsbuild\mount
#                and saves three lists of what's inside (your "before"
#                picture): apps.csv, features.csv, capabilities.csv.
#  CHANGES ON YOUR PC: none outside C:\windowsbuild. Nothing in the
#                      image is changed by this step.
#  UNDO: dism /Unmount-Image /MountDir:C:\windowsbuild\mount /Discard
#  TIP: Close File Explorer windows inside the mount folder when you're
#       done looking. An open window is the #1 cause of "files in use"
#       when you save in step 10.
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

dism /Mount-Image /ImageFile:$Build\install.wim /Index:1 /MountDir:$Mount

Set-Location $Build
Get-AppxProvisionedPackage -Path $Mount | Select DisplayName, PackageName | Export-Csv apps.csv -NoTypeInformation
Get-WindowsOptionalFeature -Path $Mount | Select FeatureName, State | Export-Csv features.csv -NoTypeInformation
Get-WindowsCapability -Path $Mount | ? State -eq Installed | Select Name | Export-Csv capabilities.csv -NoTypeInformation
"Apps provisioned: " + (Import-Csv apps.csv).Count
