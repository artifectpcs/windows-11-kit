# =====================================================================
#  00-Settings.ps1  -  Make it yours
#  WHAT IT DOES: Holds the few values the other scripts use. Nothing
#                runs here; it only sets variables.
#  HOW TO USE:   Edit the values below, save, and you're done. Every
#                other script loads this file automatically.
#  CHANGES ON YOUR PC: none.
# =====================================================================

$Me      = 'Your Name'                       # shows as Manufacturer in Settings > System > About
$Model   = 'Custom PC'                       # shows as Model
$Url     = 'https://example.com'             # the "Online support" link in About
$Account = 'Setup'                           # temporary local account Setup creates (you'll make your own after install)
$Wall    = 'C:\windowsbuild\build\wallpaper.jpg'   # your wallpaper (a 4K .jpg looks sharp everywhere)

# Working folders (no spaces: DISM and oscdimg are picky about paths)
$Root  = 'C:\windowsbuild'
$Iso   = "$Root\iso"
$Build = "$Root\build"
$Mount = "$Root\mount"
$Kit   = Split-Path $PSScriptRoot -Parent     # this repo's folder
