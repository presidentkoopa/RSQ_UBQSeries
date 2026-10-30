# Build RS_WeaponSelectionSystem.pk3
#
# Same approach as RS_VR_Unified's packer, for the same reasons:
#
#   ENTRY-BY-ENTRY .NET ZipArchive, not Compress-Archive and not
#   CreateFromDirectory. Both of those write BACKSLASHES in zip entry names on
#   Windows PowerShell. GZDoom tolerates that; SLADE does not, and a pk3 you
#   cannot open in SLADE is a pk3 you cannot debug.
#
#   ALLOWLIST, NOT DENYLIST. An exclusion list ships anything nobody thought to
#   exclude, and a lump name IGNORES ITS EXTENSION -- a stray MODELDEF.bak in a
#   pk3 root has silently shadowed the real MODELDEF before. Naming what goes IN
#   cannot fail that way.
#
#   VERIFY AFTER. Re-open the archive and check the entry count and that every
#   root lump is present, because a packer that does not check its own output is
#   how you ship an empty pk3 and find out in the headset.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = $PSScriptRoot
$out  = Join-Path $root 'RS_WeaponSelectionSystem.pk3'

# What ships. Anything not named here stays out.
# ANIMDEFS is NOT optional. It declares the WRFACE00..11 canvas textures the
# cards are painted on, and TexMan.GetCanvas() returns null for any name never
# declared -- so leaving it out gives you blank cards and NOTHING in the log.
$rootLumps = @('ANIMDEFS.txt', 'CVARINFO.txt', 'KEYCONF', 'MAPINFO.txt', 'MENUDEF.txt', 'SNDINFO.txt', 'zscript.txt')

$files = @()
foreach ($l in $rootLumps) {
    $p = Join-Path $root $l
    if (-not (Test-Path $p)) { throw "missing required lump: $l" }
    $files += Get-Item $p
}
$files += Get-ChildItem -Path (Join-Path $root 'zscript') -Recurse -File -Filter *.zs
$files += Get-ChildItem -Path (Join-Path $root 'sounds')  -Recurse -File -Filter *.ogg

if (Test-Path $out) { Remove-Item $out -Force }

$fs  = [System.IO.File]::Open($out, [System.IO.FileMode]::CreateNew)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
foreach ($f in $files) {
    $rel = ($f.FullName.Substring($root.Length + 1)) -replace '\\', '/'
    $e   = $zip.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
    $st  = $e.Open()
    $b   = [System.IO.File]::ReadAllBytes($f.FullName)
    $st.Write($b, 0, $b.Length)
    $st.Dispose()
}
$zip.Dispose()
$fs.Dispose()

# Verify.
$check = [System.IO.Compression.ZipFile]::OpenRead($out)
$names = $check.Entries | ForEach-Object { $_.FullName }
$count = $names.Count
$bad   = $names | Where-Object { $_ -match '\\' }
$check.Dispose()

if ($count -ne $files.Count) { throw "packed $count entries, expected $($files.Count)" }
if ($bad)                    { throw "backslash in entry name: $($bad -join ', ')" }
foreach ($l in $rootLumps) {
    if ($names -notcontains $l) { throw "verification failed: $l missing from the archive" }
}

Write-Output "RS_WeaponSelectionSystem.pk3  --  $count entries, verified"
Write-Output ("  size: {0:N0} bytes" -f (Get-Item $out).Length)
