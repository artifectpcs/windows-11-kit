# =====================================================================
#  08-Answer-File.ps1  -  Episode 10
#  WHAT IT DOES: Copies files\autounattend-template.xml to the root of
#     your installer as autounattend.xml, filling in your $Account name
#     from 00-Settings.ps1. Setup reads it automatically from the USB.
#  WHAT THE ANSWER FILE DOES: accepts the license, uses Microsoft's
#     public generic Pro install key (it does NOT activate Windows),
#     skips the Microsoft-account screens, creates a temporary local
#     admin account, signs in to it ONCE (LogonCount 1) to run the
#     first-logon scripts, then auto sign-in turns itself off.
#  AFTER INSTALL (important): create your own account with a strong
#     password or PIN, sign in to it, then delete the temporary setup
#     account (Settings > Accounts > Other users). See the README.
#  CHANGES ON YOUR PC: writes C:\windowsbuild\iso\autounattend.xml.
# =====================================================================
. "$PSScriptRoot\00-Settings.ps1"

(Get-Content "$Kit\files\autounattend-template.xml" -Raw).Replace('__ACCOUNT__', $Account) |
  Set-Content "$Iso\autounattend.xml" -Encoding UTF8
# Proof it's valid XML: should list windowsPE, specialize, oobeSystem
([xml](Get-Content "$Iso\autounattend.xml")).unattend.settings.pass
