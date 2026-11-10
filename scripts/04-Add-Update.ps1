# =====================================================================
#  04-Add-Update.ps1  -  Episode 04
#  WHAT IT DOES:
#    1. Reads the mounted image and tells you its Windows version/build.
#    2. Looks for x64 update files (.msu) in Downloads and build\updates.
#       None yet? It opens the Microsoft Update Catalog in your browser,
#       already searched for this month's update for your version.
#       Download the newest "Cumulative Update for Windows 11" (x64, NOT
#       "Preview") into Downloads, then run this script again.
#    3. Adds the update to the image (DISM finds any checkpoint update
#       in the same folder on its own), cleans up replaced components,
#       and shows the build number before -> after so you know it worked.
#  CHANGES ON YOUR PC: only the mounted image in C:\windowsbuild.
#  USAGE:  .\04-Add-Update.ps1               (finds the update itself)
#          .\04-Add-Update.ps1 -KB 5132061   (or name it yourself)
# =====================================================================
param([string]$KB)
. "$PSScriptRoot\00-Settings.ps1"

function Get-ImageBuild {
  reg load HKLM\OFFQ "$Mount\Windows\System32\config\SOFTWARE" | Out-Null
  $v = Get-ItemProperty 'HKLM:\OFFQ\Microsoft\Windows NT\CurrentVersion'
  $r = [pscustomobject]@{ Release = $v.DisplayVersion; Build = "$($v.CurrentBuild).$($v.UBR)" }
  Remove-Variable v; [gc]::Collect(); Start-Sleep 1
  reg unload HKLM\OFFQ | Out-Null
  $r
}

if (-not (Test-Path "$Mount\Windows")) { throw "No image mounted at $Mount. Run 03-Mount-And-Inventory.ps1 first." }
$before = Get-ImageBuild
Write-Host "Image: Windows 11 $($before.Release), build $($before.Build)" -ForegroundColor Cyan

# Gather update files (Downloads -> build\updates)
Move-Item "$env:USERPROFILE\Downloads\windows11.0-kb*-x64*.msu" "$Build\updates\" -ErrorAction SilentlyContinue
$msu = Get-ChildItem "$Build\updates\*.msu" -ErrorAction SilentlyContinue | Where-Object Name -match '-x64'
if ($KB) { $msu = $msu | Where-Object Name -match "kb$KB" }

if (-not $msu) {
  $q = "Cumulative Update Windows 11 $($before.Release)"
  Write-Host "No x64 update file found yet. Opening the Update Catalog..." -ForegroundColor Yellow
  Write-Host "Download the newest 'Cumulative Update for Windows 11' for x64 (skip Preview, Dynamic, Safe OS, .NET)," -ForegroundColor Yellow
  Write-Host "save it to Downloads, then run this script again." -ForegroundColor Yellow
  Start-Process ("https://www.catalog.update.microsoft.com/Search.aspx?q=" + [uri]::EscapeDataString($q))
  return
}

# Cumulative updates are large; small files are dynamic/setup updates
$big = @($msu | Where-Object Length -gt 1GB | Sort-Object LastWriteTime -Descending)
if ($big.Count -eq 0) { throw "Only small .msu files found. Those aren't the cumulative update; download the multi-GB one." }
if ($big.Count -eq 1) { $cu = $big[0] }
else {
  Write-Host "More than one large update found:" -ForegroundColor Yellow
  for ($i = 0; $i -lt $big.Count; $i++) { Write-Host ("  {0}  {1}  ({2:N1} GB)" -f ($i+1), $big[$i].Name, ($big[$i].Length/1GB)) }
  Write-Host "Pick the NEWEST cumulative update. A checkpoint update in the same folder is applied automatically." -ForegroundColor Yellow
  $cu = $big[[int](Read-Host "Number") - 1]
}
Write-Host "Applying $($cu.Name)" -ForegroundColor Cyan

dism /Image:$Mount /Add-Package /PackagePath:$($cu.FullName)
dism /Image:$Mount /Cleanup-Image /StartComponentCleanup /ResetBase

$after = Get-ImageBuild
if ($after.Build -ne $before.Build) {
  Write-Host "Build $($before.Build) -> $($after.Build)  Update applied." -ForegroundColor Green
} else {
  Write-Host "Build is still $($after.Build). The update did not apply. Check the DISM messages above." -ForegroundColor Red
}
