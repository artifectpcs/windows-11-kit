# =====================================================================
#  04-Add-Update.ps1  -  Episode 04
#  BEFORE YOU RUN: look up the latest cumulative update for YOUR Windows
#     release on "Windows release health", then download the x64 .msu
#     file(s) from the Microsoft Update Catalog (catalog.update.microsoft.com).
#     Some months need a checkpoint update too; download both into
#     Downloads. Do NOT reuse an old KB number: they change every month.
#  WHAT IT DOES: Moves the .msu files into build\updates and integrates
#     the cumulative update into the mounted image, then cleans up
#     superseded components. DISM finds the checkpoint file on its own.
#  CHANGES ON YOUR PC: only the mounted image in C:\windowsbuild.
#  CHECK: DISM prints "Image Version" at the top. It should go up.
#  USAGE: .\04-Add-Update.ps1 -KB 5127648      (use your month's KB)
# =====================================================================
param([Parameter(Mandatory)][string]$KB)
. "$PSScriptRoot\00-Settings.ps1"

Move-Item "$env:USERPROFILE\Downloads\windows11.0-kb*.msu" "$Build\updates\" -ErrorAction SilentlyContinue
$cu = (Get-ChildItem "$Build\updates\*kb$KB*.msu").FullName
if (-not $cu) { throw "No .msu matching kb$KB in $Build\updates" }
dism /Image:$Mount /Add-Package /PackagePath:$cu
dism /Image:$Mount /Cleanup-Image /StartComponentCleanup /ResetBase
