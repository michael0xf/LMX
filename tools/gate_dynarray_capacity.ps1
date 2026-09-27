param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
$sandbox = Join-Path $Root 'dev\l2src_sandbox'
$bad = New-Object System.Collections.Generic.List[string]
$files = @()
$files += Get-ChildItem -LiteralPath $sandbox -File -Filter '*.lm1'
$tests = Join-Path $sandbox 'tests'
if (Test-Path -LiteralPath $tests) { $files += Get-ChildItem -LiteralPath $tests -File -Filter '*.lm1' }
$l3 = Join-Path $Root 'dev\l3_interp'
if (Test-Path -LiteralPath $l3) { $files += Get-ChildItem -LiteralPath $l3 -File -Filter '*.lm1' }

# Author 2026-09-24 / FABLE-140: LmxByteArray is a removed twin of LmxCharArray.
# L2_spec §2 (VoidArray migration): the Array descriptor is VoidArray {size, data}, embedded first
# in Lmx; the transitional alias LmxArrayDesc and its LmxArrayDynamicArray are gone.
# Active sandbox sources, tests and dev/l3_interp must not spell the old names (blog/plan history may).
$banned = @('LmxByteArray', 'LmxByteDynamicArray', 'LmxArrayDesc', 'LmxArrayDynamicArray')

# The rule: a `size_t: capacity` field only in a struct whose name ends in DynamicArray.
# Each file is searched as one text by regexes, not interpreted line by line
# (next_core_tasks.md §0, build memory): a PowerShell loop over the kernel's ~40 000 lines peaked at
# 130 MB and Get-Content into arrays at 251 MB -- more than any compiler of the gate.  A line number
# is counted only for a finding.
$opt = [System.Text.RegularExpressions.RegexOptions]::Multiline
$structRe = New-Object System.Text.RegularExpressions.Regex('^[ \t]*struct:[ \t]+(\w+)[ \t]*\r?$', $opt)
$capRe = New-Object System.Text.RegularExpressions.Regex('^[ \t]*size_t:[ \t]*capacity\b', $opt)
function Get-LineNumber([string]$Text, [int]$Index) {
  $n = 1
  for ($k = $Text.IndexOf("`n"); $k -ge 0 -and $k -lt $Index; $k = $Text.IndexOf("`n", $k + 1)) { $n++ }
  return $n
}
foreach ($f in $files) {
  $rel = $f.FullName.Substring($Root.Length).TrimStart('\','/')
  $text = [System.IO.File]::ReadAllText($f.FullName)
  foreach ($name in $banned) {
    $at = $text.IndexOf($name, [StringComparison]::Ordinal)
    while ($at -ge 0) {
      $bad.Add(("{0}:{1}: banned name {2}" -f $rel, (Get-LineNumber $text $at), $name)) | Out-Null
      $at = $text.IndexOf($name, $at + $name.Length, [StringComparison]::Ordinal)
    }
  }
  if (-not $text.Contains('capacity')) { continue }
  foreach ($m in $structRe.Matches($text)) {
    $name = $m.Groups[1].Value
    $endRe = New-Object System.Text.RegularExpressions.Regex(('^[ \t]*end:[ \t]+' + [regex]::Escape($name) + '[ \t]*\r?$'), [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $end = $endRe.Match($text, $m.Index + $m.Length)
    $stop = $(if ($end.Success) { $end.Index } else { $text.Length })
    $body = $text.Substring($m.Index + $m.Length, $stop - $m.Index - $m.Length)
    if ($name -like '*DynamicArray') { continue }
    foreach ($c in $capRe.Matches($body)) {
      $at = $m.Index + $m.Length + $c.Index
      $lineEnd = $text.IndexOf("`n", $at)
      if ($lineEnd -lt 0) { $lineEnd = $text.Length }
      $bad.Add(("{0}:{1}: in struct {2}: {3}" -f $rel, (Get-LineNumber $text $at), $name, $text.Substring($at, $lineEnd - $at).Trim())) | Out-Null
    }
  }
}
if ($bad.Count -gt 0) {
  Write-Output 'GATE FAIL: dynarray capacity / banned removed names:'
  $bad | ForEach-Object { Write-Output ('  ' + $_) }
  exit 1
}
Write-Output 'GATE OK: capacity fields only on *DynamicArray; no LmxByteArray / LmxByteDynamicArray / LmxArrayDesc / LmxArrayDynamicArray'
exit 0
