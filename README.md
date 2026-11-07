# Windows 11: The ARTifect Way

**Build your own clean, fully updatable Windows 11 Pro installer from Microsoft's official ISO.**

This is the companion kit for the ARTifect PCs video series ([@artifectpcs](https://www.tiktok.com/@artifectpcs)). Every step in the videos is a script here that you can read before you run.

### Why you can trust this kit

- **No Windows files here.** You download Windows yourself from microsoft.com. This repo only holds plain-text PowerShell scripts and XML.
- **Nothing compiled or hidden.** No `.exe`, no `.zip`, no installers. Every file opens in your browser right here on GitHub.
- **Every script explains itself.** The top of each file says what it does, what it changes and how to undo it.
- **Check your copy.** `SHA256SUMS.txt` lists a hash for every file (see [Verify your download](#verify-your-download)).
- **Your Windows stays normal.** It stays genuine, activatable and updatable, with Windows Update, Defender, Microsoft Store, Xbox/Game Pass and memory integrity (VBS) all left working.

---

## What you need

| | |
|---|---|
| A Windows 10/11 PC to build on | Run everything in **Terminal (Admin)** |
| ~30 GB free disk space | |
| A **16 GB or larger** USB drive | |
| A spare PC or virtual machine to test the install | Never test on your daily driver |
| A Windows 11 **Pro** license | The installer doesn't activate Windows; your license does |

## Get the kit

**Option A, copy and paste:** open each script below on GitHub, click the copy button, and paste it into Terminal (Admin).

**Option B, download:** click **Code → Download ZIP**, then unzip to `C:\windowsbuild-kit`. Windows marks downloaded scripts as "from the internet". After you've read them, unblock them once:

```powershell
Get-ChildItem C:\windowsbuild-kit -Recurse | Unblock-File
Set-ExecutionPolicy -Scope Process Bypass   # this window only; resets when you close it
cd C:\windowsbuild-kit\scripts
```

No need to lower your system-wide security settings.

---

## The steps (one per episode)

First, edit **`scripts/00-Settings.ps1`** with your name, model, support link, wallpaper path and a temporary setup-account name. Every other script reads it.

| Ep | Run | What happens |
|---|---|---|
| 01 | `.\01-Setup-Workspace.ps1` | Makes `C:\windowsbuild\{iso,build,mount,build\updates}`, installs ADK Deployment Tools |
| 02 | `.\02-Get-ISO-Export-Pro.ps1` | Download the ISO from [microsoft.com](https://www.microsoft.com/software-download/windows11) first. Shows the SHA-256 to compare, copies the files, exports **only Windows 11 Pro** |
| 03 | `.\03-Mount-And-Inventory.ps1` | Mounts the image and saves `apps.csv`, `features.csv`, `capabilities.csv` (your "before" picture) |
| 04 | `.\04-Add-Update.ps1 -KB <number>` | Integrates this month's cumulative update. Look up the KB on Windows release health and download the `.msu` from the Microsoft Update Catalog. **The KB changes every month.** |
| 05 | `.\05-Remove-Apps.ps1` | Pick **Minimal**, **Recommended** (default) or **Aggressive**. It lists exactly what will go and asks first. Store, Security, Xbox/Game Pass and winget are always kept. |
| 06 | `.\06-Features.ps1` | .NET 3.5 on, Work Folders and legacy Media Player off. Dev/AI PCs: uncomment Hyper-V/WSL lines. |
| 07–09 | `.\07-Registry.ps1` | Privacy, targeted services, Start menu clean-up, Edge extras. VBS stays on. |
| 10 | `.\08-Answer-File.ps1` | Writes `autounattend.xml` to your installer (see [The setup account](#the-setup-account)) |
| 09, 11 | `.\09-Branding-And-FirstLogon.ps1` | Wallpaper, About-page info, taskbar pins, optional 14-day app clean-up |
| 12 | `.\10-Build-ISO.ps1` | Saves, compresses, builds `C:\windowsbuild\My-Windows11.iso` |
| 12 | `.\12-Check-It-Worked.ps1` | Run **on the new install**: read-only health report |

**Before step 10:** close any File Explorer window inside `C:\windowsbuild\mount`. An open window there is the most common reason the save fails with "files in use".

### Make the USB and install

1. Open [Rufus](https://rufus.ie), pick your USB drive and `My-Windows11.iso`, **GPT** / **UEFI**, Start.
2. If Rufus offers its own "customize Windows" options, **untick them all**. The answer file already handles setup.
3. Boot the **test** PC from the USB and install.

## The setup account

The answer file creates a temporary local admin account with no password, so setup can finish on its own and run the first-logon scripts. It signs in automatically **once**, then automatic sign-in turns itself off.

**That account is for setup, not for daily use. After install:**

1. **Settings → Accounts → Other users → Add account.** Create your own account (local or Microsoft) and make it an Administrator.
2. Set a strong password or a Windows Hello PIN.
3. Sign out, sign in as **you**, then **remove the temporary setup account**.
4. Activate Windows with your Pro license: **Settings → System → Activation**.

## After install: validate

Install on test hardware first, then confirm:

- [ ] Drivers installed (Device Manager has no warnings)
- [ ] Windows activated
- [ ] Windows Update runs and completes
- [ ] Windows Security / Defender on
- [ ] Your games or work apps launch
- [ ] Stable under load, temps normal

Run `12-Check-It-Worked.ps1` for a quick report. If you claim a performance gain, compare against stock Windows **on identical hardware**.

## Good to know

- **Telemetry on Pro:** `AllowTelemetry = 0` is set, but on Windows 11 Pro Microsoft treats it as the "Required" diagnostic level. The fully-off level exists only on Enterprise and Education.
- **Values change monthly:** KB numbers, build numbers and image sizes depend on the month you build. Recheck them each time.
- **Undo anything:** each script's header says how. Removed apps can be reinstalled from Microsoft Store.

## Verify your download

Compare your files with `SHA256SUMS.txt`:

```powershell
Get-ChildItem C:\windowsbuild-kit -Recurse -File | ? Name -ne 'SHA256SUMS.txt' | Get-FileHash -Algorithm SHA256 | ft Hash, Path
```

## Repo layout

```
scripts/   numbered steps (00-12), run in order
files/     what gets copied INTO your image: answer-file template, first-logon
           script, optional clean-up + its list, taskbar layout
docs/      the full written walkthrough (PDF and Word), with screenshots
```

Prefer reading to watching? The **[full walkthrough PDF](docs/Build-Your-Own-Windows-11-The-ARTifect-Walkthrough.pdf)** explains every step in detail, with screenshots and a troubleshooting FAQ.

---

Released under the [MIT License](LICENSE).

*Not affiliated with or endorsed by Microsoft. Windows is a trademark of Microsoft Corporation. You use these scripts at your own risk. Read them first, and test on spare hardware.*
