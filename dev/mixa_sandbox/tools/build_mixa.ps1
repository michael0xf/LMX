# build_mixa.ps1 -- translate mixa_manager under dev\mixa_sandbox to C and compile.
# Modeled on tools\build_l2src.ps1. All inputs -- translator, L2 core sources,
# kernel headers, and lm1/build -- must be local to this LMX repository tree. There is NO runtime
# fallback to C:\Nyasha_Planet\L1 or any other external path: absent local inputs, the
# build fails BEFORE translation with the exact missing path.#
#   powershell -NoProfile -ExecutionPolicy Bypass -File dev\mixa_sandbox\tools\build_mixa.ps1 -Run
param(
    [string]$Translator,
    [string]$OutDir,
    [switch]$Run,
    [switch]$Strict,
    # -BuildOnly: build and link everything, run NO probe (rows say "linked (build only)").
    # -RunOnly <stamp>: run the probes of an already built evidence dir, translating and
    # compiling nothing.  Both exist because a run can be killed BY THE SYSTEM (low memory,
    # measured 20.09 05:33) and phases must be repeatable separately.
    [switch]$BuildOnly,
    [string]$RunOnly,
    # -ManagerLinkOnly -ReuseStamp <exact dir>: the FOCUSED link path for the manager executable
    # (DEEPSEEK-MANAGER-EXECUTABLE-20260920-01, approved scope items 3-4).  It links
    # obj/mixa_app_main.o against an EXISTING stamp's object pool, read-only, into a private output,
    # and launches nothing.  There is NO DEFAULT STAMP on purpose: the newest directory on this
    # machine at the time of writing was 20260920_212506, the empty husk a memory-killed run left
    # behind, and defaulting to it would have failed in a way that looked like a defect in the
    # manager target rather than in the choice of evidence.
    [switch]$ManagerLinkOnly,
    [string]$ReuseStamp
)
$ErrorActionPreference = 'Stop'
$migRoot = Split-Path -Parent $PSScriptRoot
$l1Root = Split-Path -Parent (Split-Path -Parent $migRoot)  # .../L1
if (-not (Test-Path (Join-Path $l1Root 'bin\l1trans.exe'))) {
    # migRoot = L1\dev\mixa_sandbox; parent of migRoot is L1 when nested under L1\dev
    $l1Root = Split-Path -Parent $migRoot
}
# The port moved to LMX (Mikhail, 20.09: "перенесите все текущие дела в LMX").  There the
# derivation above lands on C:\Nyasha_Planet, which has no core at all, so walk up to the
# nearest ancestor that actually holds a PINNED translator.
if (-not (Test-Path (Join-Path $l1Root 'bin\l1trans.exe'))) {
    $walk = $migRoot
    for ($i = 0; $i -lt 4 -and $walk; $i++) {
        $walk = Split-Path -Parent $walk
        if ($walk -and (Test-Path (Join-Path $walk 'bin\l1trans.exe'))) { $l1Root = $walk; break }
    }
}
# GUARD: every input must be local.  No fallback to C:\Nyasha_Planet\L1 or any
# external path -- it exists on this disk and would be silently consumed.
# Fail BEFORE translation with the exact missing path.  The two kernel-evidence
# locations are ALTERNATIVES (tree-root build/l2src for LMX;
# dev/l2src_sandbox/build/l2src for L1-nested); either satisfies the requirement.
$kernelRoot = $l1Root
$lm1Root = $l1Root
if (-not $ManagerLinkOnly) {
    $mustHave = @(
        @{ Name = 'translator (bin\l1trans.exe)'; Path = (Join-Path $l1Root 'bin\l1trans.exe') },
        @{ Name = 'L1_PIN.txt'; Path = (Join-Path $l1Root 'L1_PIN.txt') },
        @{ Name = 'L2 core sources (dev/l2src_sandbox)'; Path = (Join-Path $l1Root 'dev\l2src_sandbox') },
        @{ Name = 'lm1/build'; Path = (Join-Path $l1Root 'lm1\build') }
    )
    foreach ($m in $mustHave) {
        if (-not (Test-Path -LiteralPath $m.Path)) {
            throw "build_mixa: missing local input -- $($m.Name) not found at $($m.Path). All inputs must be local; no external fallback."
        }
    }
    $kernelEvidenceHere = (Test-Path -LiteralPath (Join-Path $l1Root 'build\l2src')) -or
                          (Test-Path -LiteralPath (Join-Path $l1Root 'dev\l2src_sandbox\build\l2src'))
    if (-not $kernelEvidenceHere) {
        throw "build_mixa: missing local input -- kernel evidence not found at $l1Root\build\l2src or $l1Root\dev\l2src_sandbox\build\l2src. All inputs must be local; no external fallback."
    }
}

Set-Location $migRoot

if (-not $Translator) { $Translator = Join-Path $l1Root 'bin\l1trans.exe' }
if (-not (Test-Path -LiteralPath $Translator)) { throw "translator not found: $Translator" }
$pinFile = Join-Path $l1Root 'L1_PIN.txt'
$pinChecked = 'not checked (a translator was named explicitly)'
if ($Translator -eq (Join-Path $l1Root 'bin\l1trans.exe')) {
    if (-not (Test-Path -LiteralPath $pinFile)) { throw "missing $pinFile" }
    $pin = (Get-Content -LiteralPath $pinFile -TotalCount 1).Trim()
    if ($pin -notmatch '^[0-9A-Fa-f]{64}$') { throw "L1_PIN.txt must hold one 64-hex SHA256, got '$pin'" }
    $got = (Get-FileHash -LiteralPath $Translator -Algorithm SHA256).Hash
    if ($got -ne $pin.ToUpper()) { throw "translator pin mismatch: bin\l1trans.exe is $got, L1_PIN.txt says $pin" }
    $pinChecked = "matches L1_PIN.txt ($($pin.Substring(0,16))...)"
}
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
if (-not $OutDir) { $OutDir = Join-Path $migRoot "build\$stamp" }
$headers = Join-Path $OutDir 'headers'
$objDir = Join-Path $OutDir 'obj'
$binDir = Join-Path $OutDir 'bin'
$logDir = Join-Path $OutDir 'logs'
foreach ($d in @($headers, (Join-Path $headers 'mixa_manager'), (Join-Path $headers 'mixa_manager\tests\l1_gaps'), $objDir, $binDir, $logDir)) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
$gcc = (Get-Command gcc -ErrorAction Stop).Source
$nm = (Get-Command nm -ErrorAction Stop).Source
$winrtSdk = 'C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\winrt'
$flags = @('-std=c99', '-Wall', '-Wextra', '-Wpedantic',
           '-I', $migRoot, '-I', $l1Root, '-I', (Join-Path $lm1Root 'lm1\build'), '-I', $headers,
           # THE VENDORED HOST-INGRESS SEAM (49D).  Its own MANIFEST says how it is meant to be
           # reached: "-I mixa_manager/vendor/lmx_msg_host_ingress_v0 so #include
           # \"l2src/lmx_message.h\" resolves here".  That file is a HAND-WRITTEN C header carrying
           # LmxMsgRuntime/LmxMsgEnv, and it is NOT the kernel's generated lmx_message.lm1.h: the
           # two answer to different names on purpose, so both include roots can stand side by side.
           '-I', (Join-Path $migRoot 'mixa_manager\vendor\lmx_msg_host_ingress_v0'),
           '-Werror=incompatible-pointer-types', '-Werror=discarded-qualifiers',
           '-Werror=implicit-function-declaration', '-Werror=implicit-int')
# WinRT headers for mixa_share_win32 (must be -idirafter, not -I — see mixa_share.txt)
if (Test-Path -LiteralPath $winrtSdk) { $flags += @('-idirafter', $winrtSdk) }
if ($Strict) { $flags += @('-Werror', '-O2') }

$rows = @()
$failed = @()
# Rows are RECORDED here and PRINTED ONCE, AT THE END, from $rows -- never from inside a helper.
# A helper that writes its row to the output stream has it CAPTURED by the caller's
# `if (Compile-C ...)`: the row disappears from the log, and the captured @(row, $false) array is
# non-empty and therefore TRUTHY, so the caller adds an OK row for a target that just failed.
# Measured 20260919: 13 targets failed to build and every one of them printed OK, which is worse
# than printing nothing -- the log claimed work that was never done.
function Add-Row([string]$State, [string]$Label, [string]$Note) {
    $script:rows += ('{0,-4} {1,-48} {2}' -f $State, $Label, $Note)
    if ($State -eq 'FAIL') { $script:failed += $Label }
}
function Get-SafeName([string]$Name) { return ($Name -replace '[:/\\*?"<>|]', '_') }
function Invoke-Captured([string]$Label, [string]$Exe, [string[]]$ArgList, [string]$LogName) {
    $log = Join-Path $logDir ((Get-SafeName $LogName) + '.log')
    $eap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    # ENCODING IS CHOSEN HERE, NOT INHERITED (measured 20.09).  The header is written as UTF-8 and
    # the child's streams are appended by Out-File with the same explicit encoding, so the log has
    # ONE encoding from its first byte to its last.
    #
    # WHY NOT `*>>`, which was the first shape and is not broken in THIS file: `*>>` uses the
    # redirection path, whose encoding for native-command output is whatever the host decided, and
    # it produced mixed UTF-16LE-below-a-UTF-8-BOM logs in the sibling scripts (build_l2src.ps1,
    # l2_harness.ps1 -- lmx_uds measured that failure and fixed it there).  It did NOT reproduce
    # here, and the whole difference is one token: this header used to be written with no -Encoding
    # at all, i.e. ANSI with no BOM, and the UTF-16 append follows the BOM rather than the operator.
    # That is exactly why the implicit form is not good enough: the logs came out readable only by
    # accident of which codepage the header happened to use, and this project puts Cyrillic in
    # comments and messages -- a diagnostic carrying non-ASCII would be mangled by it.
    #
    # MEMORY IS UNCHANGED BY THIS: Out-File streams each record to the file as it arrives, so the
    # accumulation that this function was fixed for (Out-String building the whole output, then a
    # second copy for the header) is still gone.  LASTEXITCODE is read immediately, before anything
    # else can overwrite it.
    #
    # ARGUMENT QUOTING IS DELIBERATELY UNCHANGED: `& $Exe @ArgList` passes argv as an ARRAY, which
    # is the only form that survives a path with a space in it -- and this build passes exactly such
    # a path (the WinRT include dir, "-idirafter C:\Program Files (x86)\...").  Start-Process
    # -ArgumentList would have joined the array back into one unquoted string and broken it.
    Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" " + ($ArgList -join ' ')) -Encoding utf8
    & $Exe @ArgList 2>&1 | Out-File -LiteralPath $log -Append -Encoding utf8
    $code = $LASTEXITCODE
    $ErrorActionPreference = $eap
    return $code
}
function Convert-Source([string]$Label, [string]$RelSource, [string]$Target) {
    $parent = Split-Path -Parent $Target
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $code = Invoke-Captured $Label $Translator @($RelSource, $Target) $Label
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $Target)) {
        Add-Row 'FAIL' $Label "translate exit $code; log $logDir"
        return $false
    }
    return $true
}
function Compile-C([string]$Label, [string]$Source, [string]$Object) {
    $code = Invoke-Captured $Label $gcc ($flags + @('-c', $Source, '-o', $Object)) $Label
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $Object)) {
        Add-Row 'FAIL' $Label "gcc exit $code; log $logDir"
        return $false
    }
    return $true
}
# MEMOISED WITHIN ONE RUN, AND ONLY WITHIN ONE RUN (approved scope, item 2).  Resolve-Link asks the
# same object for its symbols in EVERY round -- up to 64 rounds over a couple of hundred objects --
# and each ask was a fresh `nm` process whose entire output was captured into a string.  An object
# cannot change while the gate runs, so the answer cannot change either; the table is script-scope
# and dies with the process, never persisted, so no later run can inherit a stale answer.  This is
# the bigger of the two memory fixes: the process spawns and their string captures are gone, not
# merely buffered better.
$script:symCache = @{}
function Get-Symbols([string]$File, [switch]$Undefined) {
    # An object that is not there has no symbols -- and must not TAKE THE WHOLE GATE DOWN.
    # Measured 20260919: a unit whose compile was reported (wrongly) as OK left no .o, `nm` wrote
    # its complaint to stderr, $ErrorActionPreference='Stop' turned that into a terminating error,
    # and the script died before printing any verdict at all.
    if (-not (Test-Path -LiteralPath $File)) { return @() }
    $opt = if ($Undefined) { '-u' } else { '--defined-only' }
    $key = $File + '|' + $opt
    if ($script:symCache.ContainsKey($key)) { return $script:symCache[$key] }
    $eap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = & $nm $opt $File 2>&1 | Out-String
    $ErrorActionPreference = $eap
    $syms = @()
    foreach ($line in ($out -split "`r?`n")) {
        $parts = @($line.Trim() -split '\s+' | Where-Object { $_ })
        if ($parts.Count -ge 2 -and $parts[-1] -match '^[A-Za-z_][A-Za-z_0-9]*$') { $syms += $parts[-1] }
    }
    $script:symCache[$key] = $syms
    return $syms
}
function Resolve-Link([string]$SelftestObject, [string[]]$AllObjects) {
    $chosen = @(); $selected = @{}
    for ($round = 0; $round -lt 64; $round++) {
        $need = @{}; $have = @{}
        foreach ($s in @(Get-Symbols $SelftestObject -Undefined)) { $need[$s] = $true }
        foreach ($o in $chosen) {
            foreach ($s in @(Get-Symbols $o -Undefined)) { $need[$s] = $true }
            foreach ($s in @(Get-Symbols $o)) { $have[$s] = $true }
        }
        $missing = @($need.Keys | Where-Object { -not $have.ContainsKey($_) })
        if ($missing.Count -eq 0) { break }
        $added = $false
        foreach ($o in $AllObjects) {
            if ($selected.ContainsKey($o)) { continue }
            $defs = @(Get-Symbols $o)
            foreach ($s in $missing) {
                if ($defs -contains $s) { $chosen += $o; $selected[$o] = $true; $added = $true; break }
            }
            if ($added) { break }
        }
        if (-not $added) { break }
    }
    return $chosen
}

Write-Output "build_mixa: translator $Translator ($pinChecked)"
Write-Output "build_mixa: gcc $gcc"
Write-Output "build_mixa: migRoot $migRoot"
Write-Output "build_mixa: l1Root $l1Root"
# Provenance, for the audit Codex asked for (LMX-L1FIXPOINT-AUDIT-20260920-01): which tool, by
# which hash, and which tree each dependency actually came from.  A NOTE alone is a claim; these
# are the paths an auditor can re-hash.
$translatorHash = (Get-FileHash -LiteralPath $Translator -Algorithm SHA256).Hash
Write-Output "build_mixa: resolved translator $Translator sha256 $($translatorHash.Substring(0,16))"
Write-Output "build_mixa: resolved kernelRoot $kernelRoot | lm1Root $lm1Root"
Write-Output "build_mixa: evidence $OutDir"

$sourceDir = Join-Path $migRoot 'mixa_manager'

# WHERE `predef: "l2src/..."` RESOLVES.  The translator resolves predefs ITSELF, FROM THE WORKING
# DIRECTORY -- gcc's -I does not enter into it (the same rule that cost the kernel gate 28 probes).
# This build stands in $migRoot, and mixa_event_source.lm1:1 asks for "l2src/lmx_message.h.lm1":
# there is no l2src\ here, so the import cannot resolve however the file is spelled, and the unit
# failed with "cannot read import" -- which read like a language gap and was nothing of the kind
# (found by lmx_uds; the file exists in the kernel tree all along).
# So the kernel's sources are STAGED beside the port, exactly as the kernel gate stages them, and
# the staging is named out loud.  It is a copy: the kernel tree is not mine to restructure.
if (-not (Test-Path -LiteralPath (Join-Path $migRoot 'l2src'))) {
    $kernelForPort = Join-Path $kernelRoot 'dev\l2src_sandbox'
    if (-not (Test-Path -LiteralPath (Join-Path $kernelForPort 'lmx_message.h.lm1'))) {
        $kernelForPort = Join-Path $kernelRoot 'l2src'
    }
    if (Test-Path -LiteralPath (Join-Path $kernelForPort 'lmx_message.h.lm1')) {
        $portL2 = Join-Path $migRoot 'l2src'
        New-Item -ItemType Directory -Force -Path $portL2 | Out-Null
        $n = 0
        foreach ($f in @(Get-ChildItem -LiteralPath $kernelForPort -File -Filter '*.lm1')) {
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $portL2 $f.Name) -Force; $n++
        }
        Write-Output "build_mixa: staged $n kernel .lm1 into $portL2 so predef 'l2src/...' resolves from the CWD"
    } else {
        Write-Output "build_mixa: NOTE no kernel sources found to stage for predef 'l2src/...' (looked in $kernelForPort)"
    }
}

# Targets that CANNOT pass in THIS tree, and why.  They are SKIPPED WITH A REASON, never dropped
# silently: the row stays in the verdict, so the record keeps showing them and the count stays
# honest (Mikhail's rule: knowledge must not live only in chat).
#
# THE SET IS EMPTY NOW, and it is empty because the tree changed rather than because the rows were
# forgotten.  Its last entry -- tests_mixa_ingress_host_harness -- read "the host-ingress API was
# never migrated to LMX: the types it needs exist in the frozen project and NOWHERE in this tree".
# That was true when written and stopped being true at 49D, when the pinned seam was copied in and
# verified against its own MANIFEST (sha256 of lmx_message.h and lmx_message.lm1 both match).  A
# SKIP that outlives its reason hides a real result, so the harness is now an ordinary target and
# section 2d) supplies the objects it needs.
$skipTargets = @{}

# -RunOnly <stamp>: run the probes of an ALREADY BUILT evidence directory, translating and
# compiling nothing.  Rationale from experience: a run can be killed by the system during the
# probe phase (critically low memory, 20.09 05:33) while build\<stamp>\{bin,obj} survives
# intact -- without this the whole ~20 minutes is repeated for a verdict that was one phase away.
if ($RunOnly) {
    $OutDir = Join-Path $migRoot "build\$RunOnly"
    $binDir = Join-Path $OutDir 'bin'
    $logDir = Join-Path $OutDir 'logs'
    Write-Output "build_mixa: RUN-ONLY over $OutDir (no translation, no compilation)"
    if (-not (Test-Path -LiteralPath $binDir)) { throw "RunOnly: no bin directory in $OutDir" }
    foreach ($e in @(Get-ChildItem -LiteralPath $binDir -Filter '*_selftest.exe' -File | Sort-Object Name)) {
        $label = "selftest:$($e.BaseName)"
        if ($skipTargets.ContainsKey($label)) { Add-Row 'SKIP' $label $skipTargets[$label]; continue }
        $argvForProbe = @()
        if ($probeArgv.ContainsKey($label)) { $argvForProbe = $probeArgv[$label] }
        $code = Invoke-Captured "run:$label" $e.FullName $argvForProbe "run:$label"
        if ($code -eq 0) { Add-Row 'OK' $label 'ran, exit 0' }
        else { Add-Row 'FAIL' $label "ran, exit $code" }
    }
    foreach ($r in $rows) { Write-Output $r }
    Write-Output ''
    if ($failed.Count -gt 0) {
        Write-Output ("build_mixa RED (run-only, probes only): {0} of {1} failed ({2}); evidence {3}" -f $failed.Count, $rows.Count, ($failed -join ', '), $OutDir)
        exit 1
    }
    Write-Output ("build_mixa GREEN (run-only, probes only): {0} probes, no failures; evidence {1}" -f $rows.Count, $OutDir)
    exit 0
}

# -ManagerLinkOnly: THE FOCUSED LINK PATH (approved scope items 3-4), and it lives HERE, after the
# function definitions, because Resolve-Link and Get-Symbols are plain functions of this script --
# PowerShell must have seen them before anything calls them.  That is also WHY it is a mode inside
# this file rather than a helper outside it: an outside caller would have to run the whole gate to
# reach them, and the alternative -- a second copy of the resolver in another script -- is the
# duplication this tree has already paid for twice.
#
# It reuses an existing stamp's object pool READ-ONLY, links to a PRIVATE output under %TEMP%, and
# launches nothing.  It prints the selected objects, because the point of the exercise is not only
# that the manager links but that the SECOND main (mixa_app_main_msg.o) was not swept in: both
# objects sit in the same pool, and a resolver that took everything would have produced a
# duplicate-main error rather than a manager.
if ($ManagerLinkOnly) {
    if (-not $ReuseStamp) {
        Write-Output 'build_mixa: -ManagerLinkOnly requires -ReuseStamp <exact directory>. There is no default: the newest stamp may be the empty husk of a killed run.'
        exit 2
    }
    if (-not (Test-Path -LiteralPath $ReuseStamp)) { Write-Output "build_mixa: -ReuseStamp does not exist: $ReuseStamp"; exit 2 }
    $reuseFull = (Resolve-Path -LiteralPath $ReuseStamp).Path
    $buildRoot = (Resolve-Path -LiteralPath (Join-Path $migRoot 'build')).Path
    if (-not $reuseFull.StartsWith($buildRoot, [StringComparison]::OrdinalIgnoreCase)) {
        Write-Output "build_mixa: -ReuseStamp must live under $buildRoot; got $reuseFull"; exit 2
    }
    $poolObjDir = Join-Path $reuseFull 'obj'
    $poolMain = Join-Path $poolObjDir 'mixa_app_main.o'
    if (-not (Test-Path -LiteralPath $poolMain)) { Write-Output "build_mixa: the reused pool has no mixa_app_main.o: $poolMain"; exit 3 }
    $poolObjects = @(Get-ChildItem -LiteralPath $poolObjDir -Filter '*.o' -File | Sort-Object Name | ForEach-Object { $_.FullName })
    $sel = @(Resolve-Link $poolMain $poolObjects)
    Write-Output ('build_mixa: ManagerLinkOnly; HEAD ' + ((git rev-parse HEAD) -join '').Substring(0,8) + '; pin ' + $pinChecked)
    Write-Output ('build_mixa: reused pool ' + $reuseFull + ' (' + $poolObjects.Count + ' objects); selected ' + $sel.Count)
    foreach ($o in $sel) { Write-Output ('  selected ' + (Split-Path -Leaf $o)) }
    if ($sel -contains (Join-Path $poolObjDir 'mixa_app_main_msg.o')) {
        Write-Output 'build_mixa: REFUSED -- the second main (mixa_app_main_msg.o) was selected. The manager executable must not link it, and this is a defect of the resolver, not of the target.'
        exit 4
    }
    $outExe = Join-Path $env:TEMP ('mixa_app_main.linkonly.' + $PID + '.exe')
    $linkArgs = @($poolMain) + $sel + @('-o', $outExe, '-lkernel32', '-luser32', '-lgdi32', '-lwinmm', '-lole32', '-luuid', '-lshell32')
    $code = Invoke-Captured 'exe:mixa_app_main' $gcc $linkArgs 'exe_mixa_app_main_linkonly'
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $outExe)) {
        Write-Output ('build_mixa: ManagerLinkOnly LINK FAILED, gcc exit ' + $code + '; log ' + $logDir)
        exit 5
    }
    $outItem = Get-Item -LiteralPath $outExe
    Write-Output ('build_mixa: linked ' + $outExe + ' (' + $outItem.Length + ' bytes, sha256 ' + (Get-FileHash -LiteralPath $outExe -Algorithm SHA256).Hash.Substring(0,16) + '...)')
    Write-Output 'build_mixa: NOT launched -- interactive Win32 (argv[1] selects a root; a gate that ran it would wait on input or paint a window)'
    Write-Output ('build_mixa: the stamp directory this run created (' + $OutDir + ') holds THIS LINK''S LOG ONLY and is not a measurement; the measurement above is the reused pool ' + $reuseFull)
    exit 0
}

# 1) headers
$hdrFiles = @(Get-ChildItem -LiteralPath $sourceDir -Filter '*.h.lm1' -File -Recurse |
    Where-Object { $_.FullName -notmatch '\\vendor\\|\\recovery_' } | Sort-Object FullName)
foreach ($h in $hdrFiles) {
    $rel = $h.FullName.Substring($migRoot.Length + 1).Replace('\','/')
    $baseRel = $rel -replace '\.h\.lm1$','.lm1.h'
    $target = Join-Path $headers ($baseRel -replace '/','\')
    $label = 'header:' + ($rel -replace '^mixa_manager/','' -replace '\.h\.lm1$','')
    if (Convert-Source $label $rel $target) { Add-Row 'OK' $label '' }
}

# 1b) Copy l2src kernel headers into the include path.  The mixa headers include
# l2src_kernel/*.lm1.h, but the l2src build produces them under l2src/.  Find the
# latest l2src build and link them into BOTH directories: l2src/ for internal
# includes (l2src headers reference each other as l2src/...) and l2src_kernel/
# for the mixa include: directives.  If no l2src build exists, skip silently —
# units that need kernel types will FAIL at compile time with a clear message.
$l2srcSandbox = Join-Path $kernelRoot 'dev\l2src_sandbox'
# WHERE THE STAMPS ARE.  L1 nests them under the sandbox; LMX keeps them at the tree root (same
# stamps, different parent).  Both are tried, and if neither holds a headers\ dir the port says so
# instead of quietly compiling against nothing.
if (-not (Test-Path -LiteralPath (Join-Path $l2srcSandbox 'build\l2src'))) {
    if (Test-Path -LiteralPath (Join-Path $kernelRoot 'build\l2src')) { $l2srcSandbox = $kernelRoot }
}
Write-Output "build_mixa: kernel evidence searched under $l2srcSandbox\build\l2src"
if (Test-Path -LiteralPath $l2srcSandbox) {
    # A build directory is a STAMP (yyyyMMdd_HHmmss) and the newest one is the newest BY NAME.
    # Sorting every directory by name alone picked `trace_app_min` -- letters sort above digits --
    # so the gate compiled the app against a kernel snapshot from days earlier and every
    # kernel-facing unit failed with "conflicting types for lmx_thread_turn" (measured 20260919).
    # Named directories are still usable, but only as a fallback, and the choice is printed.
    $allBuilds = @(Get-ChildItem -LiteralPath (Join-Path $l2srcSandbox 'build\l2src') -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'headers\l2src') })
    $l2srcBuilds = @($allBuilds | Where-Object { $_.Name -match '^\d{8}_\d{6}$' } | Sort-Object Name -Descending)
    if ($l2srcBuilds.Count -eq 0) { $l2srcBuilds = @($allBuilds | Sort-Object LastWriteTime -Descending) }
    if ($l2srcBuilds.Count -gt 0) {
        $l2srcHeaders = Join-Path $l2srcBuilds[0].FullName 'headers\l2src'
        $kernelsDir = Join-Path $headers 'l2src_kernel'
        $srcDir = Join-Path $headers 'l2src'
        foreach ($d in @($kernelsDir, $srcDir)) {
            New-Item -ItemType Directory -Force -Path $d | Out-Null
        }
        foreach ($f in @(Get-ChildItem -LiteralPath $l2srcHeaders -Filter '*.lm1.h' -File)) {
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $srcDir $f.Name) -Force
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $kernelsDir $f.Name) -Force
        }
        Write-Output "build_mixa: l2src kernel headers linked from $($l2srcBuilds[0].Name)"
    } else {
        Write-Output "build_mixa: WARNING no l2src build found at $l2srcSandbox\build\l2src\<stamp>\headers\l2src — kernel-dependent units will FAIL"
    }
}

# 2) units (skip selftests, skip .h.lm1)
$objects = @()
$unitFiles = @(Get-ChildItem -LiteralPath $sourceDir -Filter '*.lm1' -File -Recurse |
    Where-Object {
        $_.Name -notlike '*.h.lm1' -and $_.Name -notlike '*_selftest.lm1' -and
        $_.FullName -notmatch '\\vendor\\|\\recovery_'
    } | Sort-Object FullName)
foreach ($u in $unitFiles) {
    $rel = $u.FullName.Substring($migRoot.Length + 1).Replace('\','/')
    $safe = ($rel -replace '^mixa_manager/','' -replace '[\\/]','_' -replace '\.lm1$','')
    $cFile = Join-Path $objDir "$safe.c"
    $objFile = Join-Path $objDir "$safe.o"
    $label = "unit:$safe"
    if ($skipTargets.ContainsKey($label)) { Add-Row 'SKIP' $label $skipTargets[$label]; continue }
    if (-not (Convert-Source $label $rel $cFile)) { continue }
    if (Compile-C $label $cFile $objFile) { $objects += $objFile; Add-Row 'OK' $label '' }
}

# 2b) fixture PROGRAMS.  Files named *_fixture*.lm1 carry their own `fn: main` and are meant
# to be RUN by probes, which look them up by a RELATIVE name in the sandbox root
# (mixa_process_selftest.lm1:89 asks for "mixa_process_fixture.exe").  The unit pass above
# only compiles everything to OBJECTS, so a fixture was never linked and never staged: the
# probe spawned a name that did not exist and cmd answered "not recognized", which the probe
# reported as exit code 1 instead of 0 and instead of 7 (gate RED 27/361, 20.09).  This is the
# runner role the gate was missing; the staged copy lands in the sandbox root because that is
# where the probes' relative path points.
foreach ($fp in @(Get-ChildItem -LiteralPath $sourceDir -Filter '*_fixture*.lm1' -File -Recurse |
    Where-Object { $_.FullName -notmatch '\\vendor\\|\\recovery_' } | Sort-Object FullName)) {
    $rel = $fp.FullName.Substring($migRoot.Length + 1).Replace('\','/')
    $safe = ($rel -replace '^mixa_manager/','' -replace '[\\/]','_' -replace '\.lm1$','')
    $staged = ($safe -replace '^tests_','')
    $fixtureObj = Join-Path $objDir "$safe.o"
    if (-not (Test-Path -LiteralPath $fixtureObj)) { continue }
    $exe = Join-Path $binDir "$staged.exe"
    $link = $flags + @('-o', $exe, $fixtureObj) + (Resolve-Link $fixtureObj $objects)
    $link += @('-lkernel32', '-luser32', '-lgdi32', '-lwinmm', '-lole32', '-luuid', '-lshell32')
    $code = Invoke-Captured "fixture:$staged" $gcc $link "fixture:$staged"
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $exe)) {
        Add-Row 'FAIL' "fixture:$staged" "link exit $code; log $logDir\$(Get-SafeName "fixture:$staged").log"
        continue
    }
    Copy-Item -LiteralPath $exe -Destination (Join-Path $migRoot "$staged.exe") -Force
    Add-Row 'OK' "fixture:$staged" 'linked and staged into the sandbox root'
}

# 2c) Probes that consume a fixture PROGRAM must be TOLD where it is.  Staging alone is not
# enough: the probe starts its child with the FIXTURE DIRECTORY as the child's working
# directory (mixa_process_selftest.lm1:251 passes `base` to mixa_process_spawn), so the default
# relative name "mixa_process_fixture.exe" resolves against that directory and never against
# the sandbox root where the file is staged -- measured: the probe reported
# `'"mixa_process_fixture.exe"' is not recognized as an internal or external command` even
# though the staged file was present and the gate said OK.  The probe already accepts both
# paths as argv[1] (base) and argv[2] (fixture) at :80-89; the gate is the only party that
# knows the staged location.  argv[1] must be passed too -- argv[2] alone would be read as base.
$probeArgv = @{
    'selftest:tests_mixa_process_selftest' = @('build/mixa/claude/process/tmp', (Join-Path $migRoot 'mixa_process_fixture.exe'))
}

# 2d) THE VENDORED HOST-INGRESS SEAM (49D/50D).  mixa_event_source and the ingress harness are
# written against the PINNED host-ingress v0 seam, not against the kernel's Message record: the
# vendored lmx_message.h defines LmxMsgRuntime/LmxMsgEnv AND the constants they use (LMX_MSG_OK
# :14, LMX_MSG_KIND_ITEM :27), none of which the kernel's lmx_message.h.lm1 has.  The two also
# define `LmxMsg` with DIFFERENT LAYOUTS, so they must never meet in one translation unit -- that
# is why the consumer's header no longer predefs the kernel's.
#
# WHY THE WORKING DIRECTORY IS THE VENDOR ROOT, and it is not a style choice: BOTH translators
# resolve `predef:`/`include:` THEMSELVES, from the process working directory; gcc's -I does not
# enter into it.  The vendored lmx_message.lm1 opens with
#   include: "l2src/lmx_message.h" "l2src/lmx_message_host.h"
# so those names resolve only when the translator STANDS in the vendor root.  Running it from the
# port root would find nothing -- or, worse, the wrong thing, which is the same mistake that cost
# the kernel gate 28 probes.
#
# JUDGED BY THE OUTPUT FILE, NEVER BY THE EXIT CODE: both translators print a diagnostic and
# return 0, so an exit-code test would record a REFUSED seam as a silent success with no object,
# and the failure would surface much later as undefined lmx_msg_* at link.
#
# LINK SCOPING IS NOT DONE HERE.  Both seam objects join the SAME pool the units join, and the
# existing Resolve-Link (:351, :419) already picks an object only when a program's undefined
# symbols name it -- so a probe that never touches the seam does not get it linked in.
$vendorRoot = Join-Path $migRoot 'mixa_manager\vendor\lmx_msg_host_ingress_v0'
if (-not (Test-Path -LiteralPath (Join-Path $vendorRoot 'l2src\lmx_message.lm1'))) {
    Add-Row 'FAIL' 'vendor:seam' "the pinned host-ingress seam is MISSING at $vendorRoot -- mixa_event_source and the ingress harness cannot compile without it (types and constants live there, not in the kernel)"
} else {
    $seamC = Join-Path $objDir 'vendor_lmx_message.c'
    Push-Location $vendorRoot
    try {
        $null = Invoke-Captured 'vendor:seam' $Translator @('l2src/lmx_message.lm1', $seamC) 'vendor:seam'
    } finally { Pop-Location }
    if (-not (Test-Path -LiteralPath $seamC)) {
        Add-Row 'FAIL' 'vendor:seam' "translation produced NO output file (log $logDir; the translator reports a refusal by printing, not by an exit code)"
    } else {
        Add-Row 'OK' 'vendor:seam' ''
        $seamObj = Join-Path $objDir 'vendor_lmx_message.o'
        if (Compile-C 'vendor:seam' $seamC $seamObj) { $objects += $seamObj; Add-Row 'OK' 'vendor:seam' '' }
    }
    # The host side is hand-written C that ships with the seam; it includes "l2src/lmx_message_host.h",
    # which resolves through the vendor root already on the include path.
    $hostC = Join-Path $vendorRoot 'l2src\lmx_message_host.c'
    if (Test-Path -LiteralPath $hostC) {
        $hostObj = Join-Path $objDir 'vendor_lmx_message_host.o'
        if (Compile-C 'vendor:host' $hostC $hostObj) { $objects += $hostObj; Add-Row 'OK' 'vendor:host' '' }
    } else {
        Add-Row 'FAIL' 'vendor:host' "lmx_message_host.c is missing from $vendorRoot (the MANIFEST lists it)"
    }
}

# 2e) THE MANAGER EXECUTABLE (DEEPSEEK-MANAGER-EXECUTABLE-20260920-01).  Until now the gate
# produced 366 rows and NOT ONE of them was the manager: `grep -c mixa_app_main` over this file
# returned 0, so run_manager_smoke.ps1 exited 3 asking for an executable nothing built.  This
# section is that target, and it is ADDING one rather than repairing one.
#
# WHY ONLY A LINK STEP: `mixa_app_main.lm1` is an ordinary unit, so the unit pass above has
# already translated and compiled it to obj\mixa_app_main.o and put it in $objects.  Nothing new
# has to be translated for the manager itself, and the closure its `predef` names
# (mixa_app_controller.h.lm1 -> the controller unit) is in the same pool.  Judged by the OUTPUT
# FILE, exactly as the fixture section is.
#
# THE ENTRY IS CHOSEN HERE, DELIBERATELY: the port carries TWO files with `fn: main` --
# mixa_app_main.lm1:36 and mixa_app_main_msg.lm1:512 (the stepped driver).  The manager is the
# FIRST; the second is not linked into it.  Whoever later wants the stepped driver builds a
# target for IT, rather than discovering a duplicate-main at link time and "fixing" it by
# dropping one of the two.
#
# BUILD-ONLY, AND THAT IS A REQUIREMENT RATHER THAN A LIMITATION: this is an interactive Win32
# program that opens a window (argv[1] selects a root), so a gate that ran it unattended would
# either hang for input or paint a window on whatever machine the gate runs on.  The row says so
# in its detail.  A headless run, if one is wanted, is a separate act with its own seam.
$mainObj = Join-Path $objDir 'mixa_app_main.o'
if (-not (Test-Path -LiteralPath $mainObj)) {
    Add-Row 'FAIL' 'exe:mixa_app_main' "object never built: $mainObj (see the unit: rows above)"
} else {
    $mainExe = Join-Path $binDir 'mixa_app_main.exe'
    $link = $flags + @('-o', $mainExe, $mainObj) + (Resolve-Link $mainObj $objects)
    $link += @('-lkernel32', '-luser32', '-lgdi32', '-lwinmm', '-lole32', '-luuid', '-lshell32')
    $code = Invoke-Captured 'exe:mixa_app_main' $gcc $link 'exe:mixa_app_main'
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $mainExe)) {
        Add-Row 'FAIL' 'exe:mixa_app_main' "link exit $code; log $logDir\$(Get-SafeName 'exe:mixa_app_main').log"
    } else {
        Add-Row 'OK' 'exe:mixa_app_main' 'linked, build-only: NOT launched (interactive Win32)'
    }
}

# 3) conscious hand-written C kept on purpose
$keepC = @(
    'mixa_backend_tableref.h',  # header only
    'mixa_file_win32_l2_win.h',
    'tests\l1_gaps\vt.h',
    'tests\mixa_win32_smoke_harness.c',
    'tests\mixa_ingress_host_harness.c'
)
# Compile remaining top-level .c that are NOT harness/vendor/recovery/abi (abi later)
foreach ($c in @(Get-ChildItem -LiteralPath $sourceDir -Filter '*.c' -File | Sort-Object Name)) {
    if ($c.Name -eq 'test.c') {
        Add-Row 'SKIP' "handC:$($c.BaseName)" 'generated draft / dead probe — see CONVERSION.md'
        continue
    }
    # Prefer .lm1 twin: do not compile residual .c when unit .lm1 already exists (ticket 20260917-081239)
    $lm1Twin = Join-Path $sourceDir ($c.BaseName + '.lm1')
    if (Test-Path -LiteralPath $lm1Twin) {
        Add-Row 'SKIP' "handC:$($c.BaseName)" 'residual .c; .lm1 twin preferred — see CONVERSION.md'
        continue
    }
    # mixa_event_source.c needs L1\l2src\lmx_message.h (only .h.lm1 exists) — skip until converted
    if ($c.Name -eq 'mixa_event_source.c') {
        Add-Row 'SKIP' "handC:$($c.BaseName)" 'pending .lm1; L1\l2src has lmx_message.h.lm1 only (no plain .h)'
        continue
    }
    $objFile = Join-Path $objDir "$($c.BaseName).o"
    if (Compile-C "handC:$($c.BaseName)" $c.FullName $objFile) {
        $objects += $objFile; Add-Row 'OK' "handC:$($c.BaseName)" 'still-C unit pending .lm1'
    }
}

# 4) selftests
$selftests = @(Get-ChildItem -LiteralPath $sourceDir -Filter '*_selftest.lm1' -File -Recurse |
    Where-Object { $_.FullName -notmatch '\\vendor\\|\\recovery_' } | Sort-Object FullName)
foreach ($t in $selftests) {
    $rel = $t.FullName.Substring($migRoot.Length + 1).Replace('\','/')
    $safe = ($rel -replace '^mixa_manager/','' -replace '[\\/]','_' -replace '\.lm1$','')
    $cFile = Join-Path $objDir "$safe.c"
    $testObj = Join-Path $objDir "$safe.selftest.o"
    $exe = Join-Path $binDir "$safe.exe"
    $label = "selftest:$safe"
    if ($skipTargets.ContainsKey($label)) { Add-Row 'SKIP' $label $skipTargets[$label]; continue }
    if (-not (Convert-Source $label $rel $cFile)) { continue }
    if (-not (Compile-C $label $cFile $testObj)) { continue }
    $linkObjects = Resolve-Link $testObj $objects
    $link = $flags + @('-o', $exe, $testObj) + $linkObjects
    # Win32 libs commonly needed
    $link += @('-lkernel32', '-luser32', '-lgdi32', '-lwinmm', '-lole32', '-luuid', '-lshell32')
    $code = Invoke-Captured $label $gcc $link $label
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $exe)) {
        Add-Row 'FAIL' $label "link exit $code; log $logDir\$(Get-SafeName $label).log"
        continue
    }
    if (-not $Run -or $BuildOnly) { Add-Row 'OK' $label 'linked (build only)'; continue }
    $argvForProbe = @()
    if ($probeArgv.ContainsKey($label)) { $argvForProbe = $probeArgv[$label] }
    $code = Invoke-Captured "run:$label" $exe $argvForProbe "run:$label"
    if ($code -eq 0) { Add-Row 'OK' $label 'ran, exit 0' }
    else { Add-Row 'FAIL' $label "ran, exit $code" }
}

# The one place rows reach the log: the whole ordered record, every target with its true state.
foreach ($r in $rows) { Write-Output $r }
Write-Output ''
if ($failed.Count -gt 0) {
    Write-Output ("build_mixa RED: {0} of {1} targets failed ({2}); evidence {3}" -f $failed.Count, $rows.Count, ($failed -join ', '), $OutDir)
    exit 1
}
Write-Output ("build_mixa GREEN: {0} targets, no failures; evidence {1}" -f $rows.Count, $OutDir)
exit 0
