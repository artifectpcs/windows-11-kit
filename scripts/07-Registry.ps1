# =====================================================================
#  07-Registry.ps1  -  Episodes 07, 08 and 09
#  WHAT IT DOES: Writes settings into the image's registry so they're in
#     place before anyone signs in:
#       - Privacy (Ep 07): telemetry policy 0, advertising ID off,
#         activity history off, News and Interests off, P2P update
#         sharing off, tailored experiences off, suggestions off.
#       - Services (Ep 08): disables DiagTrack, dmwappushservice,
#         MapsBroker, PeerDistSvc, SessionEnv. Windows Update, Defender,
#         BITS and networking are NOT touched.
#       - Start menu (Ep 09): no placeholder pins, no Recommended section.
#       - Edge: no sidebar, shopping pop-ups, Rewards or MSN feed.
#  NOT CHANGED: Virtualization-based security / memory integrity stay ON.
#  EDITION NOTE: on Windows 11 Pro, Microsoft treats AllowTelemetry=0 as
#     the "Required" diagnostic level; the fully-off level exists only on
#     Enterprise/Education. Verify in Settings > Privacy after install.
#  CHANGES ON YOUR PC: only the mounted image. Close Registry Editor first.
#  UNDO (after install): delete the policy values, or set a service's
#     Start value back (2 = Automatic, 3 = Manual).
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

reg load HKLM\OFFSW   "$Mount\Windows\System32\config\SOFTWARE"
reg load HKLM\OFFSYS  "$Mount\Windows\System32\config\SYSTEM"
reg load HKLM\OFFUSER "$Mount\Users\Default\NTUSER.DAT"
function Set-Reg($key, $name, $value) {
  reg add $key /v $name /t REG_DWORD /d $value /f | Out-Null
  Write-Host "  $name = $value" -ForegroundColor DarkYellow
}

# --- Privacy (machine-wide) ---
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\DataCollection' AllowTelemetry 0
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\AdvertisingInfo' DisabledByGroupPolicy 1
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\System' PublishUserActivities 0
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\System' UploadUserActivities 0
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Dsh' AllowNewsAndInterests 0
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\DeliveryOptimization' DODownloadMode 0

# --- Start menu: no placeholder apps, no Recommended section ---
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\CloudContent' DisableCloudOptimizedContent 1
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\CloudContent' DisableWindowsConsumerFeatures 1
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\CloudContent' DisableSoftLanding 1
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\Explorer' HideRecommendedSection 1
Set-Reg 'HKLM\OFFSW\Policies\Microsoft\Windows\Explorer' HideRecommendedPersonalizedSites 1

# --- Every new user ---
$cdm = 'HKLM\OFFUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
'SilentInstalledAppsEnabled','ContentDeliveryAllowed','PreInstalledAppsEnabled','OemPreInstalledAppsEnabled',
'SystemPaneSuggestionsEnabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled',
'SubscribedContent-353694Enabled' | % { Set-Reg $cdm $_ 0 }
Set-Reg 'HKLM\OFFUSER\Software\Policies\Microsoft\Windows\Explorer' DisableSearchBoxSuggestions 1
Set-Reg 'HKLM\OFFUSER\Software\Policies\Microsoft\Windows\CloudContent' DisableTailoredExperiencesWithDiagnosticData 1
$adv = 'HKLM\OFFUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-Reg $adv Start_Layout 1; Set-Reg $adv Start_TrackProgs 0; Set-Reg $adv Start_TrackDocs 0; Set-Reg $adv Start_IrisRecommendations 0

# --- Services (Start = 4 means Disabled; offline images use ControlSet001) ---
'DiagTrack','dmwappushservice','MapsBroker','PeerDistSvc','SessionEnv' | % {
  reg add "HKLM\OFFSYS\ControlSet001\Services\$_" /v Start /t REG_DWORD /d 4 /f | Out-Null
  Write-Host "  $_ : Start = 4 (Disabled)" -ForegroundColor DarkYellow
}

# --- Edge extras off ---
$edge = 'HKLM\OFFSW\Policies\Microsoft\Edge'
Set-Reg $edge HideFirstRunExperience 1; Set-Reg $edge HubsSidebarEnabled 0; Set-Reg $edge EdgeShoppingAssistantEnabled 0
Set-Reg $edge ShowMicrosoftRewards 0; Set-Reg $edge NewTabPageContentEnabled 0; Set-Reg $edge PersonalizationReportingEnabled 0

[gc]::Collect(); Start-Sleep 2
reg unload HKLM\OFFUSER; reg unload HKLM\OFFSYS; reg unload HKLM\OFFSW
