# Remove-ReturningApps.ps1 - OPTIONAL, transparent, time-limited clean-up (Episode 11)
# Windows updates can re-add some apps. For 14 days after install this checks every
# 6 hours (and at startup/sign-in) for apps matching Sweep-List.txt, removes them,
# and writes every action to C:\ProgramData\CustomWindows\app-sweep.log.
# After 14 days the scheduled task expires and deletes itself.
# Don't want it? Empty Sweep-List.txt, or run:  Unregister-ScheduledTask 'Remove Returning Apps'
# Removed something you wanted? Install it again from Microsoft Store.
param([switch]$Register)
$ErrorActionPreference = 'SilentlyContinue'
$Task = 'Remove Returning Apps'
$Dir  = "$env:ProgramData\CustomWindows"
$Log  = "$Dir\app-sweep.log"
$List = "$PSScriptRoot\Sweep-List.txt"
New-Item -ItemType Directory $Dir -Force | Out-Null
function Log($msg) { "$(Get-Date -Format s)  $msg" | Add-Content $Log }

if ($Register) {
  $end  = (Get-Date).AddDays(14).ToString('s')
  $act  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
  $boot = New-ScheduledTaskTrigger -AtStartup; $boot.Delay = 'PT2M'; $boot.EndBoundary = $end
  $logn = New-ScheduledTaskTrigger -AtLogOn;   $logn.EndBoundary = $end
  $tick = New-ScheduledTaskTrigger -Once -At (Get-Date).AddHours(6) -RepetitionInterval (New-TimeSpan -Hours 6) -RepetitionDuration (New-TimeSpan -Days 14)
  $tick.EndBoundary = $end
  $set  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DeleteExpiredTaskAfter (New-TimeSpan -Days 1)
  $who  = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
  Register-ScheduledTask -TaskName $Task -Action $act -Trigger $boot, $logn, $tick -Settings $set -Principal $who -Force | Out-Null
  Log "registered '$Task' for 14 days"
  Start-ScheduledTask -TaskName $Task
  exit
}

$patterns = Get-Content $List | Where-Object { $_ -and $_ -notmatch '^\s*#' }
Log 'sweep start'
$gone = @()
foreach ($p in Get-AppxProvisionedPackage -Online) {
  if ($patterns | Where-Object { $p.DisplayName -like $_ }) {
    Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName | Out-Null
    Log "  deprovisioned $($p.DisplayName)"; $gone += $p.DisplayName
  }
}
foreach ($a in Get-AppxPackage -AllUsers | Where-Object { $_.Name -in $gone -and -not $_.NonRemovable }) {
  Remove-AppxPackage -Package $a.PackageFullName -AllUsers
  Log "  removed $($a.Name)"
}
Log "sweep done ($($gone.Count) found)"
