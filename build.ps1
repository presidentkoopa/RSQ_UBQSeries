# Build RSQ_DistanceGrab.pk3.
#
# EXPLICIT INCLUDE LIST, not an exclusion list. An exclusion list can only
# exclude what somebody thought of, and a lump name IGNORES ITS EXTENSION -- so
# anything stray in the tree can shadow a real lump. A MODELDEF.bak in a pk3
# root has silently replaced a real MODELDEF before.
#
# String .Replace() and not the -replace operator: -replace takes a REGEX and a
# lone backslash is not a valid one.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = $PSScriptRoot
$out  = Join-Path $root 'RSQ_DistanceGrab.pk3'

# docs/ and models/ stay out for now: docs is prose, and the FBX is a 24 MB
# SOURCE asset that the engine cannot read and must never be packed.
# tools/ stays out too: gen_sounds.py WRITES sounds/, it is not a lump.
$required = @('zscript.txt', 'MAPINFO.txt', 'CVARINFO.txt')
$optional = @('TRNSLATE.txt', 'KEYCONF.txt', 'MENUDEF.txt', 'MODELDEF.txt', 'SNDINFO.txt', 'MASSDEF.txt')
$dirs     = @('zscript', 'graphics', 'sprites', 'sounds')

$files = @()
foreach ($f in $required) {
    $p = Join-Path $root $f
    if (-not (Test-Path $p)) { throw "REQUIRED lump missing: $f" }
    $files += Get-Item $p
}
foreach ($f in $optional) {
    $p = Join-Path $root $f
    if (Test-Path $p) { $files += Get-Item $p }
}
foreach ($d in $dirs) {
    $p = Join-Path $root $d
    if (Test-Path $p) { $files += Get-ChildItem $p -Recurse -File }
}

if (Test-Path $out) { Remove-Item $out -Force }

$fs  = [System.IO.File]::Open($out, 'Create')
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
foreach ($f in $files) {
    $rel = $f.FullName.Substring($root.Length + 1).Replace([char]92, [char]47)
    $e   = $zip.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
    $st  = $e.Open()
    $b   = [System.IO.File]::ReadAllBytes($f.FullName)
    $st.Write($b, 0, $b.Length)
    $st.Close()
}
$zip.Dispose(); $fs.Close()

# ---------------------------------------------------------------- verify
$z = [System.IO.Compression.ZipFile]::OpenRead($out)
$names = @{}
$z.Entries | ForEach-Object { $names[$_.FullName.ToLower()] = $true }
$fail = 0

$bad = @($z.Entries | Where-Object { $_.FullName.Contains([char]92) }).Count
if ($bad -gt 0) { Write-Warning "$bad entries contain backslashes"; $fail++ }

# A packed .fbx would be 24 MB of source asset the engine cannot read.
$stray = @($z.Entries | Where-Object { $_.FullName -match '(?i)(\.md$|\.ps1$|\.py$|\.json$|\.bak$|\.fbx$|^\.claude/|^docs/|^models/hands/)' })
foreach ($s in $stray) { Write-Warning "stray non-lump packed: $($s.FullName)"; $fail++ }

# Every #include must resolve. An unresolved one is a fatal load error.
$e  = $z.Entries | Where-Object { $_.FullName -eq 'zscript.txt' }
$sr = New-Object System.IO.StreamReader($e.Open()); $t = $sr.ReadToEnd(); $sr.Close()
$inc = 0; $miss = 0
foreach ($line in ($t -split "`n")) {
    if ($line -match '^\s*#include\s+"([^"]+)"') {
        $inc++
        if (-not $names.ContainsKey($matches[1].ToLower())) { Write-Warning "unresolved #include: $($matches[1])"; $miss++; $fail++ }
    }
}

# Every handler MAPINFO registers must exist, and every handler that exists
# should be registered. A registered-but-absent class is a fatal load error; a
# defined-but-unregistered one is SILENCE, which reads in a headset as the
# feature simply not existing.
$allZs = ''
foreach ($en in ($z.Entries | Where-Object { $_.FullName -match '(?i)\.zs$' })) {
    $r = New-Object System.IO.StreamReader($en.Open()); $allZs += $r.ReadToEnd(); $r.Close()
}
$declared = @([regex]::Matches($allZs, '(?im)^\s*class\s+([A-Za-z0-9_]+)') | ForEach-Object { $_.Groups[1].Value.ToLower() })
$mi = $z.Entries | Where-Object { $_.FullName -eq 'MAPINFO.txt' }
$sr2 = New-Object System.IO.StreamReader($mi.Open()); $mt = $sr2.ReadToEnd(); $sr2.Close()
$handlers = @()
foreach ($m in [regex]::Matches($mt, '(?i)AddEventHandlers\s*=\s*([^\r\n}]+)')) {
    $handlers += ([regex]::Matches($m.Groups[1].Value, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value })
}
$hMiss = 0
foreach ($h in $handlers) { if ($declared -notcontains $h.ToLower()) { Write-Warning "MAPINFO registers undefined handler: $h"; $hMiss++; $fail++ } }

$dupes = $declared | Group-Object | Where-Object { $_.Count -gt 1 }
foreach ($d in $dupes) { Write-Warning "duplicate class declaration: $($d.Name)"; $fail++ }

# EVERY CVAR THE CODE NAMES MUST BE DECLARED. An undeclared cvar is not an
# error in ZScript, it is a zero -- so a typo'd reach silently switches the
# cone off and nothing says so.
$ci = $z.Entries | Where-Object { $_.FullName -eq 'CVARINFO.txt' }
$sr3 = New-Object System.IO.StreamReader($ci.Open()); $ct = $sr3.ReadToEnd(); $sr3.Close()
$declaredCvars = @([regex]::Matches($ct, '(?im)^\s*(?:user|server)\s+\w+\s+([A-Za-z0-9_]+)') | ForEach-Object { $_.Groups[1].Value.ToLower() })
# Matched at the CALL SITE, not as any rsqdg_* string literal. The loose form
# flagged the netevent names `rsqdg_press` and `rsqdg_release` as undeclared
# cvars, which they are not -- and a check that cries wolf gets switched off.
$usedCvars = @([regex]::Matches($allZs, '(?:Num|Flag|Opt|GetCVar)\s*\(\s*"([A-Za-z0-9_]+)"') | ForEach-Object { $_.Groups[1].Value.ToLower() }) | Sort-Object -Unique
$cMiss = 0
foreach ($c in $usedCvars) { if ($declaredCvars -notcontains $c) { Write-Warning "cvar read but not declared: $c"; $cMiss++; $fail++ } }

# Every translation the code asks for by name must exist, for the same reason.
$trNames = @()
if ($names.ContainsKey('trnslate.txt')) {
    $tr = $z.Entries | Where-Object { $_.FullName -eq 'TRNSLATE.txt' }
    $sr4 = New-Object System.IO.StreamReader($tr.Open()); $tt = $sr4.ReadToEnd(); $sr4.Close()
    $trNames = @([regex]::Matches($tt, '(?im)^\s*([A-Za-z0-9_]+)\s*=') | ForEach-Object { $_.Groups[1].Value.ToLower() })
}
$usedTr = @([regex]::Matches($allZs, 'Translation\.GetID\("([^"]+)"\)') | ForEach-Object { $_.Groups[1].Value.ToLower() }) | Sort-Object -Unique
$tMiss = 0
foreach ($tn in $usedTr) { if ($trNames -notcontains $tn) { Write-Warning "translation used but not defined: $tn"; $tMiss++; $fail++ } }

# ZSCRIPT IS CASE-INSENSITIVE, so a field and a method whose names differ only
# in case are a REDEFINITION, not two things. `private bool poseGood;` beside
# `bool PoseGood()` is a hard compile error, and it is invisible when reading
# either line on its own. Both of this package's first two compile failures were
# exactly this.
#
# Checked per FILE rather than per class, which is sound here because this
# package is one class per file; a file with two classes would need the real
# thing.
$collide = 0
foreach ($en in ($z.Entries | Where-Object { $_.FullName -match '(?i)\.zs$' })) {
    $r = New-Object System.IO.StreamReader($en.Open()); $src = $r.ReadToEnd(); $r.Close()
    # Strip line comments so commented-out code cannot raise a false alarm.
    $clean = [regex]::Replace($src, '//[^\r\n]*', '')
    $fields  = @([regex]::Matches($clean, '(?im)^\s*(?:private\s+|protected\s+|meta\s+|transient\s+)*(?:bool|int|uint|double|float|String|Name|Actor|Vector2|Vector3|TextureID|TranslationID|Color|Sector|Service|PlayerInfo|PlayerPawn|Inventory|Class<[^>]+>)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:\[[^\]]*\])?\s*(?:,|;)') | ForEach-Object { $_.Groups[1].Value })
    $methods = @([regex]::Matches($clean, '(?im)^\s*(?:private\s+|protected\s+|static\s+|virtual\s+|override\s+|clearscope\s+|play\s+|ui\s+|native\s+)*(?:void|bool|int|uint|double|float|String|Name|Actor|Vector2|Vector3|TextureID|TranslationID|Color)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(') | ForEach-Object { $_.Groups[1].Value })
    $fl = @($fields  | ForEach-Object { $_.ToLower() })
    foreach ($m in $methods) {
        if ($fl -contains $m.ToLower()) {
            Write-Warning "CASE COLLISION in $($en.FullName): field and method both named '$m' -- ZScript will reject this"
            $collide++; $fail++
        }
    }
}

# AN UNSCOPED CLASS CANNOT CALL A PLAY FUNCTION.
#
# A class declared bare -- `class RSQDG_Cone` with no base and no qualifier --
# is DATA scope, and calling a play function from it fails with "Can't call play
# function X from data context". A class that inherits from Thinker or
# EventHandler is play already and needs nothing.
#
# This bit exactly once, on a class whose REMA original carries the qualifier
# (`class RS_Cone play`) and lost it in the port. The list below is only the
# play-only natives this package actually reaches for; it is meant to catch a
# dropped qualifier, not to be a complete scope checker.
$playOnly = @('CheckSight','LineTrace','LineAttack','AimLineAttack','TryMove',
              'SetOrigin','A_SetSize','CallTryPickup','A_ChangeModel',
              'UpdateSector','SetAnimation','A_QuakeEx','Thrust','DamageMobj')
$scopeBad = 0
foreach ($en in ($z.Entries | Where-Object { $_.FullName -match '(?i)\.zs$' })) {
    $r = New-Object System.IO.StreamReader($en.Open()); $src = $r.ReadToEnd(); $r.Close()
    $clean = [regex]::Replace($src, '//[^\r\n]*', '')
    # Bare class: no ':' base and no play/ui/clearscope qualifier on the line.
    foreach ($m in [regex]::Matches($clean, '(?im)^\s*class\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:\r?\n|\{)')) {
        $cname = $m.Groups[1].Value
        foreach ($fn in $playOnly) {
            if ($clean -match "(?<![A-Za-z0-9_])$fn\s*\(") {
                Write-Warning "SCOPE: class '$cname' in $($en.FullName) is data scope but the file calls $fn() -- it needs 'play'"
                $scopeBad++; $fail++
                break
            }
        }
    }
}

# EVERY SOUND THE CODE NAMES MUST BE DEFINED, AND EVERY DEFINITION MUST HAVE
# ITS FILE. An undefined logical sound is not an error at load or at play: it is
# silence, and a feedback layer that has gone silent reads as "the sound was
# turned down", not as a bug.
$sMiss = 0
$usedSnd = @([regex]::Matches($allZs, '"(rsqdg/[A-Za-z0-9_]+)"') | ForEach-Object { $_.Groups[1].Value.ToLower() }) | Sort-Object -Unique
$sndDefs = @{}
if ($names.ContainsKey('sndinfo.txt')) {
    $si = $z.Entries | Where-Object { $_.FullName -eq 'SNDINFO.txt' }
    $sr7 = New-Object System.IO.StreamReader($si.Open()); $st = $sr7.ReadToEnd(); $sr7.Close()
    foreach ($m in [regex]::Matches($st, '(?im)^\s*(rsqdg/[A-Za-z0-9_]+)\s+([A-Za-z0-9_]+)')) {
        $sndDefs[$m.Groups[1].Value.ToLower()] = $m.Groups[2].Value.ToLower()
    }
}
foreach ($u in $usedSnd) { if (-not $sndDefs.ContainsKey($u)) { Write-Warning "sound used but not in SNDINFO: $u"; $sMiss++; $fail++ } }
foreach ($k in $sndDefs.Keys) {
    $lump = $sndDefs[$k]
    $hit = @($names.Keys | Where-Object { $_ -match "^sounds/$lump\.(wav|ogg|flac)$" }).Count
    if ($hit -eq 0) { Write-Warning "SNDINFO $k -> $lump but no sounds/$lump.* is packed"; $sMiss++; $fail++ }
}

# A TRNSLATE ENTRY NEEDS ITS SOURCE RANGE. `Name = "%[a]:[b]"` is rejected with
# "Expected integer constant but got '%'"; it has to be `"0:255=%[a]:[b]"`. The
# lump parses at load, so this is a startup failure rather than a silent one --
# but it is still cheaper to catch here.
$trBad = 0
if ($names.ContainsKey('trnslate.txt')) {
    $tr2 = $z.Entries | Where-Object { $_.FullName -eq 'TRNSLATE.txt' }
    $sr6 = New-Object System.IO.StreamReader($tr2.Open()); $tt2 = $sr6.ReadToEnd(); $sr6.Close()
    foreach ($m in [regex]::Matches($tt2, '(?im)^\s*([A-Za-z0-9_]+)\s*=\s*"([^"]*)"')) {
        if ($m.Groups[2].Value -notmatch '^\s*\d+\s*:\s*\d+\s*=') {
            Write-Warning "TRNSLATE '$($m.Groups[1].Value)' has no source range -- needs a leading '0:255='"
            $trBad++; $fail++
        }
    }
}

# EVERY OptionMenu MUST BE REACHABLE. An orphaned page compiles clean, loads
# clean and says nothing -- in a headset it reads as the feature having been
# removed, which is exactly what happened to ten pages of the desktop package
# when it was split out of its parent.
$mMiss = 0; $menus = @(); $linked = @()
if ($names.ContainsKey('menudef.txt')) {
    $mn = $z.Entries | Where-Object { $_.FullName -eq 'MENUDEF.txt' }
    $sr5 = New-Object System.IO.StreamReader($mn.Open()); $mdt = $sr5.ReadToEnd(); $sr5.Close()
    $menus  = @([regex]::Matches($mdt, '(?im)^\s*OptionMenu\s+"([^"]+)"') | ForEach-Object { $_.Groups[1].Value })
    $linked = @([regex]::Matches($mdt, '(?im)^\s*Submenu\s+"[^"]*"\s*,\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value })
    # The root is reached by AddOptionMenu rather than by a Submenu line.
    $roots  = @([regex]::Matches($mdt, '(?is)AddOptionMenu\s+"[^"]*"\s*\{(.*?)\}') | ForEach-Object {
                 [regex]::Matches($_.Groups[1].Value, 'Submenu\s+"[^"]*"\s*,\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value } })
    $reachable = @($linked + $roots)
    foreach ($m in $menus) {
        if ($reachable -notcontains $m) { Write-Warning "ORPHANED OptionMenu (unreachable): $m"; $mMiss++; $fail++ }
    }
    foreach ($l in ($reachable | Sort-Object -Unique)) {
        if ($menus -notcontains $l) { Write-Warning "Submenu points at a page that does not exist: $l"; $mMiss++; $fail++ }
    }
    # Every cvar a menu row drives must be declared too, for the same reason.
    $menuCvars = @([regex]::Matches($mdt, '(?im)^\s*(?:Slider|Option)\s+"[^"]*"\s*,\s*"([A-Za-z0-9_]+)"') | ForEach-Object { $_.Groups[1].Value.ToLower() }) | Sort-Object -Unique
    foreach ($c in $menuCvars) {
        if ($c -like 'rsqdg_*' -and $declaredCvars -notcontains $c) { Write-Warning "menu row drives an undeclared cvar: $c"; $mMiss++; $fail++ }
    }
}

$n = $z.Entries.Count; $kb = [math]::Round((Get-Item $out).Length / 1KB, 1)
$z.Dispose()
Write-Host "RSQ_DistanceGrab.pk3  --  $n entries, $kb KB"
Write-Host "  backslash entries : $bad"
Write-Host "  stray files       : $($stray.Count)"
Write-Host "  #includes         : $inc checked, $miss unresolved"
Write-Host "  event handlers    : $($handlers.Count) registered, $hMiss undefined"
Write-Host "  classes           : $($declared.Count) declared, $($dupes.Count) duplicated"
Write-Host "  cvars             : $($usedCvars.Count) read, $cMiss undeclared"
Write-Host "  translations      : $($usedTr.Count) used, $tMiss undefined"
Write-Host "  option menus      : $($menus.Count) defined, $mMiss unreachable or broken"
Write-Host "  case collisions   : $collide"
Write-Host "  scope qualifiers  : $scopeBad missing"
Write-Host "  translation syntax: $trBad bad"
Write-Host "  sounds            : $($usedSnd.Count) used, $sMiss undefined or missing"
if ($fail -gt 0) { throw "package verification failed ($fail problems)" }
Write-Host "  VERIFIED OK"
