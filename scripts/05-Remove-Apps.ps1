# =====================================================================
#  05-Remove-Apps.ps1  -  Episode 05
#  WHAT IT DOES: Removes the provisioned apps listed below from the
#     image, by exact package name, so new users don't get them.
#  THIS IS THE GENERIC BUILD. It KEEPS: Microsoft Store, Windows
#     Security, Xbox app + Game Pass (Microsoft.GamingApp), Game Bar
#     (XboxGamingOverlay), Camera, Paint, Notepad, Terminal, Photos,
#     Snipping Tool, Calculator.
#  MAKE IT YOURS: delete a line to keep that app, or add a name from
#     apps.csv (step 03) to remove it.
#  CHANGES ON YOUR PC: only the mounted image.
#  UNDO: any removed app can be installed later from Microsoft Store.
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

$remove = @(
  'Clipchamp.Clipchamp'
  'Microsoft.BingNews'
  'Microsoft.BingSearch'
  'Microsoft.BingWeather'
  'Microsoft.GetHelp'
  'Microsoft.MicrosoftOfficeHub'
  'Microsoft.MicrosoftSolitaireCollection'
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

Get-AppxProvisionedPackage -Path $Mount | ? DisplayName -in $remove | % {
  Write-Host "Removing $($_.DisplayName)" -ForegroundColor DarkYellow
  Remove-AppxProvisionedPackage -Path $Mount -PackageName $_.PackageName | Out-Null
}
"Apps left: " + (Get-AppxProvisionedPackage -Path $Mount).Count
