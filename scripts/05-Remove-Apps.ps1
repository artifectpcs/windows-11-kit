# =====================================================================
#  05-Remove-Apps.ps1  -  Episode 05
#  WHAT IT DOES: Removes preinstalled apps from the image so new users
#     don't get them. You pick one of three levels:
#
#     1  MINIMAL      Ads, news and trial apps only. Everything else stays.
#     2  RECOMMENDED  The ARTifect generic build (default). Also removes
#                     OneDrive (via step 07), Teams, Outlook (new), To Do, Phone Link, Dev Home,
#                     Feedback Hub, Quick Assist, Widgets and similar.
#     3  AGGRESSIVE   Recommended, plus Copilot, Game Bar, Camera, Paint,
#                     Sticky Notes, Media Player and Movies & TV.
#
#  ALWAYS KEPT at every level: Microsoft Store, App Installer (winget),
#     Windows Security, Xbox app + Game Pass, Xbox sign-in, Notepad,
#     Terminal, Photos, Calculator, Snipping Tool, and the runtime
#     frameworks other apps depend on.
#
#  HOW TO USE: run it and pick 1, 2 or 3. It shows exactly what will be
#     removed and asks before changing anything. Or skip the menu:
#        .\05-Remove-Apps.ps1 -Level Recommended
#  MAKE IT YOURS: edit the lists below. Names must match apps.csv (Ep 03).
#  CHANGES ON YOUR PC: only the mounted image.
#  UNDO: any removed app can be installed later from Microsoft Store.
# =====================================================================
param([ValidateSet('Minimal','Recommended','Aggressive')][string]$Level)
. "$PSScriptRoot\00-Settings.ps1"

$Minimal = @(
  'Microsoft.BingNews'
  'Microsoft.BingWeather'
  'Microsoft.BingSearch'
  'Microsoft.MicrosoftSolitaireCollection'
  'Microsoft.MicrosoftOfficeHub'
  'Clipchamp.Clipchamp'
  'Microsoft.GetHelp'
)
$Recommended = $Minimal + @(
  'Microsoft.MicrosoftStickyNotes'
  'Microsoft.OutlookForWindows'
  'Microsoft.PowerAutomateDesktop'
  'Microsoft.Todos'
  'Microsoft.Windows.DevHome'
  'Microsoft.WindowsAlarms'
  'Microsoft.WindowsFeedbackHub'
  'Microsoft.WindowsSoundRecorder'
  'Microsoft.XboxSpeechToTextOverlay'
  'Microsoft.YourPhone'
  'MicrosoftCorporationII.QuickAssist'
  'MSTeams'
  'MicrosoftWindows.Client.WebExperience'
  'MicrosoftWindows.CrossDevice'
)
$Aggressive = $Recommended + @(
  'Microsoft.Copilot'
  'Microsoft.XboxGamingOverlay'
  'Microsoft.WindowsCamera'
  'Microsoft.Paint'
  'Microsoft.ZuneMusic'
  'Microsoft.ZuneVideo'
)
# Never removed, whatever the level (safety net if you edit the lists above)
$Protected = @(
  'Microsoft.WindowsStore','Microsoft.DesktopAppInstaller','Microsoft.SecHealthUI',
  'Microsoft.GamingApp','Microsoft.XboxIdentityProvider','Microsoft.WindowsNotepad',
  'Microsoft.WindowsTerminal','Microsoft.Windows.Photos','Microsoft.WindowsCalculator',
  'Microsoft.ScreenSketch','Microsoft.StorePurchaseApp'
)

if (-not $Level) {
  Write-Host ''
  Write-Host '  How much should we remove?' -ForegroundColor Cyan
  Write-Host '    1  Minimal      ads, news and trial apps only'
  Write-Host '    2  Recommended  + OneDrive, Teams, Outlook, To Do, Widgets  (default)'
  Write-Host '    3  Aggressive   also Copilot, Game Bar, Camera, Paint, media apps'
  $pick = Read-Host '  Type 1, 2 or 3 and press Enter'
  $Level = switch ($pick) { '1' {'Minimal'} '3' {'Aggressive'} default {'Recommended'} }
}
$remove = (Get-Variable $Level).Value | Where-Object { $_ -notin $Protected }

$installed = Get-AppxProvisionedPackage -Path $Mount
$hits = $installed | Where-Object DisplayName -in $remove
Write-Host "`n  Level: $Level  -  $($hits.Count) of $($installed.Count) apps will be removed:" -ForegroundColor Cyan
$hits | Sort DisplayName | ForEach-Object { Write-Host "    - $($_.DisplayName)" -ForegroundColor DarkYellow }
$ok = Read-Host "`n  Remove these? (Y/N)"
if ($ok -notmatch '^[Yy]') { Write-Host '  Nothing changed.'; return }

$hits | ForEach-Object {
  Write-Host "Removing $($_.DisplayName)" -ForegroundColor DarkYellow
  Remove-AppxProvisionedPackage -Path $Mount -PackageName $_.PackageName | Out-Null
}
$Level | Set-Content "$Build\removal-level.txt"   # 09 uses this to match the clean-up list
"Apps left: " + (Get-AppxProvisionedPackage -Path $Mount).Count
