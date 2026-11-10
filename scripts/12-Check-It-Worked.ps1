# =====================================================================
#  12-Check-It-Worked.ps1  -  Episode 12 (run on the NEW install)
#  WHAT IT DOES: Read-only report. Prints the Windows build, how many
#     apps are provisioned, any removed apps that came back, the state
#     of the five disabled services, the optional clean-up task, its
#     log, and whether memory integrity (VBS) is on.
#  CHANGES ON YOUR PC: none.
# =====================================================================
"Build: " + (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % { "$($_.DisplayVersion) $($_.CurrentBuild).$($_.UBR)" })
"Activation: " + ((Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND Name LIKE 'Windows%'").LicenseStatus -eq 1)
"Apps provisioned: " + (Get-AppxProvisionedPackage -Online).Count
Get-AppxPackage -AllUsers | ? Name -match 'DevHome|CrossDevice|Clipchamp|Solitaire|OutlookForWindows' | Select Name
"OneDrive installed: " + ([bool](Get-Process OneDrive -EA 0) -or (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"))
Get-Service DiagTrack,dmwappushservice,MapsBroker,PeerDistSvc,SessionEnv -EA 0 | ft Name,StartType -Auto
Get-ScheduledTask 'Remove Returning Apps' -EA 0 | ft TaskName,State -Auto
Get-Content C:\ProgramData\CustomWindows\app-sweep.log -EA 0
"VBS running: " + ((Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard).VirtualizationBasedSecurityStatus -eq 2)
