# FirstLogon.ps1 - runs once, at the first sign-in after Setup.
# Sets the custom wallpaper, shows file extensions, and opens File Explorer to "This PC".
# Changes only the signed-in user's settings. Undo any of it in Settings.
Add-Type @"
using System.Runtime.InteropServices;
public class Wp { [DllImport("user32.dll")] public static extern int SystemParametersInfo(int a, int b, string c, int d); }
"@
$wp = Get-ChildItem "C:\Windows\Web\Wallpaper\Custom\wallpaper.*" -ErrorAction SilentlyContinue | Select -First 1
if ($wp) { [Wp]::SystemParametersInfo(20, 0, $wp.FullName, 3) }
$adv = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty $adv -Name HideFileExt -Value 0
Set-ItemProperty $adv -Name LaunchTo -Value 1
