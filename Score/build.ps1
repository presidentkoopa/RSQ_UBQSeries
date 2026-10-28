# Build RS_Score.pk3
#
# Entry-by-entry ZipArchive with FORWARD SLASHES and an ALLOWLIST, the same pattern
# as RS_Ballistics and RS_SlowMo use, and for the same two reasons:
#   - Compress-Archive writes backslash separators, which SLADE will not open.
#   - A lump name ignores its extension, so a stray .bak in the root can silently
#     shadow the real lump. Only named files and named trees go in.
#
# -OutFile packs somewhere other than the installed RS_Score.pk3, so a scratch pack
# can be compile-checked BEFORE it replaces the one the owner loads.
# -NoCompileCheck skips the last step.
param([switch]$NoCompileCheck, [string]$OutFile = '')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = $PSScriptRoot
$out  = if ($OutFile) { $OutFile } else { Join-Path $root 'RS_Score.pk3' }

# ---- the allowlist ---------------------------------------------------------
$rootLumps = @(
    'zscript.txt',
    'MAPINFO.txt',
    'CVARINFO.txt',
    'SNDINFO.txt',
    'TEXTCOLO.txt',
    'RSSCFON.fon2',
    'RSSCFN2.fon2'
)

$files = @()
foreach ($l in $rootLumps) {
    $p = Join-Path $root $l
    if (-not (Test-Path $p)) { throw "missing required lump: $l" }
    $files += Get-Item $p
}

$files += Get-ChildItem -Path (Join-Path $root 'zscript')  -Recurse -File -Filter *.zs
$files += Get-ChildItem -Path (Join-Path $root 'graphics') -Recurse -File -Filter *.png
$files += Get-ChildItem -Path (Join-Path $root 'sounds')   -Recurse -File -Filter *.ogg

# ---- pack ------------------------------------------------------------------
if (Test-Path $out) { Remove-Item $out -Force }
$fs  = [System.IO.File]::Open($out, [System.IO.FileMode]::CreateNew)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
foreach ($f in $files) {
    $rel = ($f.FullName.Substring($root.Length + 1)) -replace ([regex]::Escape([char]92)), '/'
    $e = $zip.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
    $st = $e.Open(); $b = [System.IO.File]::ReadAllBytes($f.FullName)
    $st.Write($b, 0, $b.Length); $st.Dispose()
}
$zip.Dispose(); $fs.Dispose()

# ---- verify rather than trust: a lump that fails to pack is SILENT ---------
$check = [System.IO.Compression.ZipFile]::OpenRead($out)
$names = $check.Entries | ForEach-Object { $_.FullName }
$check.Dispose()

$must = @(
    'zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt', 'SNDINFO.txt', 'TEXTCOLO.txt',
    'RSSCFON.fon2', 'RSSCFN2.fon2',
    'zscript/rsscore/tracker.zs',
    'zscript/rsscore/event.zs',
    'zscript/rsscore/bonus.zs',
    'zscript/rsscore/bonuses.zs',
    'zscript/rsscore/handler.zs',
    'zscript/rsscore/hud.zs',
    'graphics/SCOREBG1.png',
    'graphics/SCOREBR1.png',
    'graphics/SCOREBKT.png',
    'graphics/HUD_LIF1.png',
    'sounds/score/points_reward.ogg',
    'sounds/score/points_fullheal.ogg'
)
foreach ($m in $must) {
    if ($names -notcontains $m) { throw "verification failed: $m missing" }
}
Write-Output "RS_Score.pk3  --  $($names.Count) entries, verified"

if ($NoCompileCheck) { Write-Output "compile check SKIPPED (-NoCompileCheck) -- NOT proven to compile"; return }

& 'E:\DOOMWork\tools\compile_check.ps1' -Files @($out)
if ($LASTEXITCODE -ne 0) { throw "compile check FAILED -- see above" }
