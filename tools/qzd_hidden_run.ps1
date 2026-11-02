# ============================================================================
# QUESTZDOOM 17.3 HIDDEN RUN for the RSQ series -- the desktop engine loads a set of pk3s, runs a
# map for a while, quits; nobody sees a window; the log is read afterwards.
#
# This is the owner's SuperPunchOut/tools/qzd_hidden_run.ps1 (2026-11-01) with its SuperPunchOut-only
# companion pack (tools/desktest, which names SPO_Director by literal) left out, so it can gate any
# RSQ pk3 set. The engine is started on its own Win32 desktop (CreateDesktop), as that script and
# UZDXREMA's main_boottest.ps1 do, so no window ever appears where the owner is working; it is killed
# on a fatal line, a Fatal Error dialog, or the timeout. Owner's rule for check runs: windowed,
# hidden, once per finished block ("you check it headless", 2026-11-02).
#
# WHAT IT PROVES AND WHAT IT CANNOT. +vr_mode 0, no hands: the packs parse on 17.3's compiler, the
# handlers run, console commands in -Commands run in the level. Nothing about a headset, hands, or
# how anything looks. Say so when reporting.
#
#   powershell -File tools\qzd_hidden_run.ps1 -Files A.pk3,B.pk3 -Map MAP01 -WaitTics 350 `
#       -Commands 'summon Zombieman','wait 35','kill monsters' -Tag gbovr_l1
#
# -Files     load order, parents first (absolute paths). Each must exist.
# -Map       the map to enter.
# -WaitTics  tics the level runs before the commands (35 = 1 s).
# -Commands  console commands run in the level after the wait, in order, then `wait 70; quit`.
#            The list may arrive flattened as one comma-joined string (native-exe argument passing);
#            it is split on commas and semicolons here, so keep a `;` out of a single command.
# -Engine    folder with qzdoom.exe and doom2.wad (the owner's 17.3-m build).
# -Tag       names the log: %TEMP%\qzd_hidden_run\run_<tag>_<stamp>.log. The path is printed.
# Exit 0 = loaded and ran (script parsing took, no error line); 1 = error lines; 2 = no log / no parse line.
# ============================================================================
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string[]] $Files,
    [string] $Engine = 'E:\DOOMWork\QZD17-engine\build\Release',
    [string] $Map = 'MAP01',
    [int]    $WaitTics = 140,
    [int]    $TimeoutSec = 180,
    [string[]] $Commands = @(),
    [string[]] $ExtraArgs = @(),
    [int] $Skill = 0,
    [string] $Tag = 'run'
)
$ErrorActionPreference = 'Stop'

$Files = @($Files | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$Commands = @($Commands | ForEach-Object { $_ -split '[,;]' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })

$exe  = Join-Path $Engine 'qzdoom.exe'
$iwad = Join-Path $Engine 'doom2.wad'
foreach ($p in @($exe, $iwad)) { if (-not (Test-Path -LiteralPath $p)) { throw "missing: $p" } }
$abs = @()
foreach ($f in $Files) {
    if (-not (Test-Path -LiteralPath $f)) { throw "missing file: $f" }
    $abs += (Resolve-Path -LiteralPath $f).Path
}
$Files = $abs

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$scratch = Join-Path $env:TEMP 'qzd_hidden_run'
New-Item -ItemType Directory -Force $scratch | Out-Null
# The config is the engine's own, kept between runs (a hand-written ini crashed 17.3-m). +vr_mode 0 on the
# command line is the VR guard either way.
$cfg = Join-Path $scratch 'qzd_hidden_rsq.ini'
$log = Join-Path $scratch ("run_{0}_{1}.log" -f $Tag, $stamp)
$con = Join-Path $scratch ("run_{0}_{1}.stdout.txt" -f $Tag, $stamp)

# What must not change: the build folder's own config and logs.
$guard = @(Get-ChildItem -LiteralPath $Engine -File | Where-Object { $_.Extension -in '.ini', '.log', '.txt' })
$before = @{}; foreach ($g in $guard) { $before[$g.FullName] = $g.LastWriteTimeUtc }

if (-not ([System.Management.Automation.PSTypeName]'HiddenDesk').Type) {
Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices; using System.Text;
public static class HiddenDesk {
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  struct STARTUPINFO { public int cb; public string lpReserved; public string lpDesktop; public string lpTitle; public int dwX, dwY, dwXSize, dwYSize, dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags; public short wShowWindow, cbReserved2; public IntPtr lpReserved2, hStdInput, hStdOutput, hStdError; }
  [StructLayout(LayoutKind.Sequential)] struct PROCESS_INFORMATION { public IntPtr hProcess, hThread; public int dwProcessId, dwThreadId; }
  [StructLayout(LayoutKind.Sequential)] struct SECURITY_ATTRIBUTES { public int nLength; public IntPtr lpSecurityDescriptor; public bool bInheritHandle; }
  [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr CreateDesktop(string name, IntPtr dev, IntPtr mode, int flags, uint access, IntPtr sa);
  [DllImport("user32.dll", SetLastError=true)] static extern bool CloseDesktop(IntPtr h);
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern bool CreateProcess(string app, StringBuilder cmd, IntPtr pa, IntPtr ta, bool inherit, uint flags, IntPtr env, string cwd, ref STARTUPINFO si, out PROCESS_INFORMATION pi);
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr CreateFile(string name, uint access, uint share, ref SECURITY_ATTRIBUTES sa, uint disp, uint flags, IntPtr tmpl);
  [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
  delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumDesktopWindows(IntPtr desk, EnumProc cb, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  public static IntPtr Desktop = IntPtr.Zero;
  public static bool HasFatalWindow() {
    if (Desktop == IntPtr.Zero) return false;
    bool found = false;
    EnumDesktopWindows(Desktop, (h, l) => { var sb = new StringBuilder(512); GetWindowText(h, sb, 512); if (sb.ToString().StartsWith("Fatal Error")) found = true; return !found; }, IntPtr.Zero);
    return found;
  }
  public static string WindowTitles() {
    if (Desktop == IntPtr.Zero) return "";
    var all = new StringBuilder();
    EnumDesktopWindows(Desktop, (h, l) => { var sb = new StringBuilder(512); GetWindowText(h, sb, 512); string t = sb.ToString().Trim(); if (t.Length > 0) { if (all.Length > 0) all.Append("  |  "); all.Append(t); } return true; }, IntPtr.Zero);
    return all.ToString();
  }
  public static int Start(string exe, string args, string cwd, string outFile, string desktopName) {
    Desktop = CreateDesktop(desktopName, IntPtr.Zero, IntPtr.Zero, 0, 0x10000000, IntPtr.Zero);
    if (Desktop == IntPtr.Zero) throw new Exception("CreateDesktop failed " + Marshal.GetLastWin32Error());
    var sa = new SECURITY_ATTRIBUTES(); sa.nLength = Marshal.SizeOf(sa); sa.bInheritHandle = true;
    IntPtr hOut = CreateFile(outFile, 0x40000000, 1, ref sa, 2, 0x80, IntPtr.Zero);
    var si = new STARTUPINFO(); si.cb = Marshal.SizeOf(si); si.lpDesktop = desktopName;
    si.dwFlags = 0x100; si.hStdOutput = hOut; si.hStdError = hOut;
    PROCESS_INFORMATION pi;
    bool ok = CreateProcess(exe, new StringBuilder("\"" + exe + "\" " + args), IntPtr.Zero, IntPtr.Zero, true, 0, IntPtr.Zero, cwd, ref si, out pi);
    int err = Marshal.GetLastWin32Error();
    CloseHandle(hOut);
    if (!ok) { CloseDesktop(Desktop); Desktop = IntPtr.Zero; throw new Exception("CreateProcess failed " + err); }
    CloseHandle(pi.hThread); CloseHandle(pi.hProcess);
    return pi.dwProcessId;
  }
  public static void Close() { if (Desktop != IntPtr.Zero) { CloseDesktop(Desktop); Desktop = IntPtr.Zero; } }
}
'@
}

# One engine at a time on this machine (the same lock main_boottest.ps1 and the SPO runner hold).
try   { $runLock = New-Object System.Threading.Mutex($false, 'Global\doomxr_boottest_engine') }
catch { $runLock = New-Object System.Threading.Mutex($false, 'Local\doomxr_boottest_engine') }
$haveLock = $false
try { $haveLock = $runLock.WaitOne([TimeSpan]::FromSeconds($TimeoutSec + 60)) }
catch [System.Threading.AbandonedMutexException] { $haveLock = $true }
if (-not $haveLock) { throw "another engine run holds the lock -- refusing to race it" }

function Invoke-Hidden([string] $argLine, [string] $outFile, [string] $logFile, [int] $timeoutSec, [string] $deskName) {
    $procId = [HiddenDesk]::Start($exe, $argLine, $Engine, $outFile, $deskName)
    $p = Get-Process -Id $procId
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $stopPattern = 'Execution could not continue|VM execution aborted|Unknown identifier|could not find|Unknown property'
    $why = ''
    while (-not $p.HasExited) {
        if ($sw.Elapsed.TotalSeconds -gt $timeoutSec) { $why = "TIMEOUT $timeoutSec s"; break }
        if ([HiddenDesk]::HasFatalWindow()) { Start-Sleep -Milliseconds 800; $why = 'FATAL ERROR WINDOW'; break }
        if ($logFile -and (Test-Path -LiteralPath $logFile) -and (Select-String -LiteralPath $logFile -Pattern $stopPattern -Quiet)) { Start-Sleep -Milliseconds 800; $why = 'fatal text'; break }
        Start-Sleep -Milliseconds 500
    }
    $titles = ''
    try { $titles = [HiddenDesk]::WindowTitles() } catch {}
    if (-not $p.HasExited) { Stop-Process -Id $procId -Force -Confirm:$false -ErrorAction SilentlyContinue }
    $p.WaitForExit(5000) | Out-Null
    [HiddenDesk]::Close()
    $sw.Stop()
    if ($why) { Write-Output "stopped: $why  (windows: $titles)" } else { Write-Output "engine exited by itself ($([int]$sw.Elapsed.TotalSeconds) s)" }
    return $why
}

function Q([string] $s) { if ($s -match '[\s;]') { '"' + $s + '"' } else { $s } }
$base = @('-iwad', (Q $iwad), '-config', (Q $cfg), '-file') + @($Files | ForEach-Object { Q $_ }) +
        @('-nosound', '-nomusic', '-stdout', '+vr_mode', '0', '+vid_fullscreen', '0', '+i_pauseinbackground', '0')
if ($Skill -gt 0) { $base += @('-skill', "$Skill") }

try {
    # The whole in-level script is ONE "+" group: a `wait` only delays the rest of its own group.
    $group = "+wait {0}" -f $WaitTics
    foreach ($c in $Commands) { $group += "; " + $c }
    $group += "; wait 70; quit"
    $parts = $base + @('+logfile', (Q $log)) + @($ExtraArgs | ForEach-Object { Q $_ }) + @('+map', $Map, (Q $group))
    $argLine = $parts -join ' '
    Write-Output "qzd hidden run: $($Files.Count) file(s), map $Map, $WaitTics tics then $($Commands.Count) command(s); log $log"
    Write-Output "args: $argLine"
    $reason = Invoke-Hidden $argLine $con $log $TimeoutSec "qzdhidden_$stamp"
}
finally {
    if ($haveLock) { $runLock.ReleaseMutex(); $haveLock = $false }
}

foreach ($g in $guard) {
    $now = (Get-Item -LiteralPath $g.FullName).LastWriteTimeUtc
    if ($now -ne $before[$g.FullName]) { Write-Warning "GUARD: $($g.FullName) CHANGED during the run" }
}
if (-not (Test-Path -LiteralPath $log)) { Write-Output "NO LOG written. stdout: $con"; exit 2 }
$lines = @(Get-Content -LiteralPath $log)
if ($lines | Where-Object { $_ -match 'I_StartupOpenXR' }) { Write-Warning "GUARD: the log shows I_StartupOpenXR -- vr_mode 0 did NOT hold" }
# What loaded: the engine names every archive and its lump count. Match them against -Files or the gate is void.
$lines | Where-Object { $_ -match '^adding ' } | ForEach-Object { Write-Output "  $_" }
$failPattern = 'Script error|Execution could not continue|VM execution aborted|Unknown identifier|could not find|Unknown property'
$errs = New-Object Collections.Generic.List[string]
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*Script warning') { $i++; continue }
    if ($lines[$i] -match $failPattern) { $errs.Add($lines[$i].Trim()); if ($i + 1 -lt $lines.Count) { $errs.Add('    ' + $lines[$i + 1].Trim()) } }
}
$parsed = $lines | Where-Object { $_ -match 'script parsing took [0-9.]+ ms' } | Select-Object -First 1
$warns = @($lines | Where-Object { $_ -match '^\s*Script warning' })
if ($errs.Count -gt 0) {
    Write-Output "QUESTZDOOM RUN FAILED -- $($errs.Count) error line(s). log $log"
    $errs | Select-Object -First 40 | ForEach-Object { Write-Output "  $_" }
    exit 1
}
if (-not $parsed) { Write-Output "NO PASS: no 'script parsing took' line -- log $log"; $lines | Select-Object -Last 20 | ForEach-Object { "  $_" }; exit 2 }
Write-Output "LOADS AND RUNS ON QUESTZDOOM 17.3 -- $($parsed.Trim()), $($warns.Count) script warning(s), $($lines.Count) lines in all"
$warns | Select-Object -First 12 | ForEach-Object { Write-Output "  $_" }
Write-Output "log: $log"
exit 0
