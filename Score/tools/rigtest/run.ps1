# run.ps1 -- RSQ Score's scripted scenarios on the headless desktop engine (never ships; tools/qzd_hidden_run.ps1 does
# the run). Packs the probe, loads doom2 + RSQ_Score.pk3 (+ RSQ_SlowMo.pk3 with -SlowMo) + the probe on MAP01, lets the
# probe drive its cases by tic, then writes last_run.txt beside this script: every RSP line and every RS_Score line, in
# order, so each case's EXPECT sits right above the Score line that answers it. Exit code is the hidden run's.
#
#   powershell -File Score\tools\rigtest\run.ps1 [-SlowMo] [-Extra <pk3,pk3>]
param([switch] $SlowMo, [string] $Extra = '')
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repo = (Resolve-Path (Join-Path $here '..\..\..')).Path
$probe = Join-Path $here 'probe.pk3'
if (Test-Path $probe) { Remove-Item $probe }
# python's zipfile, not Compress-Archive (older versions write backslashes the engine cannot read)
$py = @"
import zipfile, os, sys
src, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk(src):
        for f in files:
            p = os.path.join(root, f)
            z.write(p, os.path.relpath(p, src).replace(os.sep, '/'))
"@
$tmp = Join-Path $env:TEMP 'rsp_pack.py'
Set-Content -Path $tmp -Value $py -Encoding ascii
python -I $tmp (Join-Path $here 'probe') $probe
$files = @((Join-Path $repo 'pk3\RSQ_Score.pk3'))
if ($SlowMo) { $files += (Join-Path $repo 'pk3\RSQ_SlowMo.pk3') }
if ($Extra) { $files += ($Extra -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
$files += $probe
$args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $repo 'tools\qzd_hidden_run.ps1'),
    '-Files', ($files -join ','), '-Map', 'MAP01', '-WaitTics', '700', '-TimeoutSec', '150', '-Tag', 'score_probe')
$out = & powershell @args 2>&1
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Output $_ }
$logLine = $out | Where-Object { "$_" -match '^log: ' } | Select-Object -Last 1
if ($logLine)
{
    $log = ("$logLine" -replace '^log: ', '').Trim()
    $lines = Get-Content -LiteralPath $log | Where-Object { $_ -match '^RSP |RS_Score|Script error|VM execution|Execution could not' }
    $report = Join-Path $here 'last_run.txt'
    Set-Content -Path $report -Value $lines -Encoding utf8
    Write-Output ("report: {0} ({1} lines)" -f $report, @($lines).Count)
}
exit $code
