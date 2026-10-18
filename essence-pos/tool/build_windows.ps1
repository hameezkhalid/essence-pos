# Builds a portable Essence POS for Windows → build\essence-pos-windows.zip
# Unzip on any Windows 10/11 PC and run essence_pos.exe (no installer needed).
#
# Run from the essence-pos folder in PowerShell:
#   powershell -ExecutionPolicy Bypass -File tool\build_windows.ps1
#
# Needs (on the build PC only): Flutter, Git, and Visual Studio 2022 with
# "Desktop development with C++". Turn on Windows Developer Mode (Settings › System ›
# For developers) — Flutter needs it to build plugins.

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

flutter pub get
flutter build windows --release

$release = 'build\windows\x64\runner\Release'
if (-not (Test-Path "$release\essence_pos.exe")) { throw 'Build failed: essence_pos.exe not found' }

# Bundle the Visual C++ runtime so the app also runs on PCs that don't have it installed.
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vs = & $vswhere -latest -property installationPath
$crt = Get-ChildItem "$vs\VC\Redist\MSVC\*\x64\Microsoft.VC*.CRT" -Directory |
  Sort-Object FullName -Descending | Select-Object -First 1
if ($crt) {
  Copy-Item "$($crt.FullName)\*.dll" $release -Force
  Write-Host "Bundled VC++ runtime from $($crt.FullName)"
} else {
  Write-Warning 'VC++ runtime not found; target PCs may need the Microsoft Visual C++ Redistributable (x64).'
}

$zip = 'build\essence-pos-windows.zip'
Compress-Archive -Path "$release\*" -DestinationPath $zip -Force
Write-Host "`nDone: $zip"
Write-Host 'Copy it to the laptop, unzip, and run essence_pos.exe.'
