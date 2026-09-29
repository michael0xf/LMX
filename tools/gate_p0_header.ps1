param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
# D-104 (steps/defects.md): the sandbox's copy of the parser (dev\l2src_sandbox\l1src, the one l2trans
# parses programs with) used two P0 flags its own header did not define -- the C of the translator
# takes the seed's generated header first (-I lm1\build), so the build stayed green while the copy
# was no longer described by its header.  The rules: every c.LM_P0_* constant the sandbox's l1src and
# l2trans spell is a `define:` of the sandbox's own l1src\p0.h.lm1; and each of those defines has the
# same value in lm1\build\l1src\p0.lm1.h, the header the translator's C is compiled with -- so the
# copy compiled against the seed's header is compiled against its own values.  A value compares as
# text (REVIEW ee3ae73-1): `4` and `4U` differ -- spell a define as p0.lm1.h spells it.  Each file is
# read as one text (build memory, next_core_tasks.md §0).
$sandbox = Join-Path $Root 'dev\l2src_sandbox'
$header = Join-Path $sandbox 'l1src\p0.h.lm1'
$seedHeader = Join-Path $Root 'lm1\build\l1src\p0.lm1.h'
$files = @()
$files += Get-ChildItem -LiteralPath (Join-Path $sandbox 'l1src') -File -Filter '*.lm1'
$files += Get-Item -LiteralPath (Join-Path $sandbox 'l2trans.lm1')
$opt = [System.Text.RegularExpressions.RegexOptions]::Multiline
$defRe = New-Object System.Text.RegularExpressions.Regex('^define:[ \t]+(LM_P0_\w+)[ \t]+(\S+)[ \t]*\r?$', $opt)
$seedRe = New-Object System.Text.RegularExpressions.Regex('^#define[ \t]+(LM_P0_\w+)[ \t]+(\S+)[ \t]*\r?$', $opt)
$useRe = New-Object System.Text.RegularExpressions.Regex('\bc\.(LM_P0_\w+)\b')
$defined = New-Object System.Collections.Generic.HashSet[string]
$bad = New-Object System.Collections.Generic.List[string]
$seed = @{}
foreach ($m in $seedRe.Matches([System.IO.File]::ReadAllText($seedHeader))) { $seed[$m.Groups[1].Value] = $m.Groups[2].Value }
foreach ($m in $defRe.Matches([System.IO.File]::ReadAllText($header))) {
  $name = $m.Groups[1].Value
  $defined.Add($name) | Out-Null
  if (-not $seed.ContainsKey($name)) { $bad.Add(("dev\l2src_sandbox\l1src\p0.h.lm1: {0} is not in lm1\build\l1src\p0.lm1.h" -f $name)) | Out-Null }
  elseif ($seed[$name] -ne $m.Groups[2].Value) { $bad.Add(("dev\l2src_sandbox\l1src\p0.h.lm1: {0} is {1}, lm1\build\l1src\p0.lm1.h has {2}" -f $name, $m.Groups[2].Value, $seed[$name])) | Out-Null }
}
foreach ($f in $files) {
  $rel = $f.FullName.Substring($Root.Length).TrimStart('\','/')
  $seen = New-Object System.Collections.Generic.HashSet[string]
  foreach ($m in $useRe.Matches([System.IO.File]::ReadAllText($f.FullName))) {
    $name = $m.Groups[1].Value
    if (-not $defined.Contains($name) -and $seen.Add($name)) { $bad.Add(("{0}: {1} is not defined in dev\l2src_sandbox\l1src\p0.h.lm1" -f $rel, $name)) | Out-Null }
  }
}
if ($bad.Count -gt 0) {
  Write-Output 'GATE FAIL: the sandbox P0 header does not describe what the sandbox spells and compiles:'
  $bad | ForEach-Object { Write-Output ('  ' + $_) }
  exit 1
}
Write-Output ("gate_p0_header: OK ({0} P0 defines, {1} files)" -f $defined.Count, $files.Count)
exit 0
