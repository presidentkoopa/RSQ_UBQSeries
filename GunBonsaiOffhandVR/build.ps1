# Build the Gun Bonsai VR / Offhand patch pk3.
#
# A pk3 is just a zip. Everything in this directory except the build script,
# the git metadata and the notes goes in at the same relative path Gun Bonsai
# uses, so GZDoom's later-lump-wins rule substitutes our copies for the stock
# ones. That is the whole mechanism -- there is no patching step.
#
# Load order matters and is not negotiable: this must come AFTER GunBonsai.

$ErrorActionPreference = 'Stop'

$src = $PSScriptRoot
$name = 'RSQ_GunBonsaiVR.pk3'
$rotation = 'D:\SteamLibrary\steamapps\Common\DooM VR\__CurrentRotationDONOTDELETE'

$staging = Join-Path $env:TEMP 'gbvr_stage'
if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Force $staging | Out-Null

# $name must be excluded, or each build zips the previous build into itself:
# the 86 KB release carried a stale 42 KB copy of an older build of this mod,
# and grew every time. .gitignore has no business in a release either.
$exclude = @('.git', '.gitignore', 'build.ps1', 'NOTES.md', 'tools', $name)
Get-ChildItem -Path $src -Force | Where-Object { $exclude -notcontains $_.Name } | ForEach-Object {
  Copy-Item -Recurse -Force $_.FullName -Destination $staging
}

# Compress-Archive refuses any extension but .zip, so build then rename.
$zip = Join-Path $env:TEMP 'gbvr_build.zip'
if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zip -CompressionLevel Optimal

$out = Join-Path $src $name
if (Test-Path $out) { Remove-Item -Force $out }
Move-Item $zip $out

Write-Host "Built $out"

if (Test-Path $rotation) {
  Copy-Item -Force $out (Join-Path $rotation $name)
  Write-Host "Deployed to $rotation"
} else {
  Write-Host "Rotation folder not found; skipped deploy."
}
