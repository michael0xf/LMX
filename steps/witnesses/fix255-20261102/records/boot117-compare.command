try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot117 (fable_pc): G1 and G2 compared from the receipts, after the bootstrap's `done`.  Quick mode does not compare the
# generations; this reads the `<sha256>  <path>` lines of the two generation logs (G1's part of pins/boot117<TP_TRY>-quick.log
# up to `PASS bootstrap: G0 builds and tests whole G1`, and quick117<TP_TRY>/g2-build.log), keys them by the path with the
# generation directory normalised (quick117x/g1 and quick117x/g2 -> quick117x/gN; stage paths are the same in both), and reports
# raw equality first.  Every pair that differs raw is then compared byte for byte: for PE images the differing offsets (the
# link stamp TimeDateStamp at 136 and CheckSum at 216 of these images are the known class), for text files the sizes and the
# first differing line.  No tool, no compiler runs; only named files are read.  Output: pins/boot117<TP_TRY>-compare.txt.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$label="quick117$try"
$Q="$p\cold-boot117$try\$label"
$out="$p\pins\boot117$try-compare.txt"
if (Test-Path -LiteralPath $out) { throw 'output exists' }
if (-not (Select-String -LiteralPath "$p\pins\boot117$try-detached.terminal.txt" -Pattern '^done ' -Quiet)) { throw 'boot117 not done' }
function Pairs([string[]]$lines, [string]$gen) {
  $h=[ordered]@{}
  foreach ($l in $lines) {
    if ($l -cmatch '^([0-9a-f]{64})  (C:/\S.*)$') { $h[($Matches[2] -replace "/$label/$gen/", "/$label/gN/")]=@($Matches[1], $Matches[2]) }
  }
  return $h
}
$quick=@(Get-Content -LiteralPath "$p\pins\boot117$try-quick.log")
$cut=-1
for ($i=0; $i -lt $quick.Count; $i++) { if ($quick[$i] -like 'PASS bootstrap: G0 builds and tests whole G1*') { $cut=$i; break } }
if ($cut -lt 0) { throw 'G1 pass line not found' }
$g1=Pairs $quick[0..$cut] 'g1'
$g2=Pairs @(Get-Content -LiteralPath "$Q\g2-build.log") 'g2'
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('boot117' + $try + ' compare ' + [DateTime]::UtcNow.ToString('o') + ' G1 paths ' + $g1.Count + ' G2 paths ' + $g2.Count)
$both=@($g1.Keys | Where-Object { $g2.Contains($_) })
$onlyG1=@($g1.Keys | Where-Object { -not $g2.Contains($_) }); $onlyG2=@($g2.Keys | Where-Object { -not $g1.Contains($_) })
$equal=@($both | Where-Object { $g1[$_][0] -eq $g2[$_][0] })
$diff=@($both | Where-Object { $g1[$_][0] -ne $g2[$_][0] })
$lines.Add('in both ' + $both.Count + ' raw-equal ' + $equal.Count + ' differ ' + $diff.Count + ' only-G1 ' + $onlyG1.Count + ' only-G2 ' + $onlyG2.Count)
foreach ($k in $onlyG1) { $lines.Add('only-G1 ' + $k) }
foreach ($k in $onlyG2) { $lines.Add('only-G2 ' + $k) }
$byExt=@{}
foreach ($k in $equal) { $e=[IO.Path]::GetExtension($k); if ($k -match '\.h\.lm1$') { $e='.h.lm1' }; if ($k -match '\.lm1\.h$') { $e='.lm1.h' }; if (-not $byExt.Contains($e)) { $byExt[$e]=0 }; $byExt[$e]++ }
foreach ($e in ($byExt.Keys | Sort-Object)) { $lines.Add('raw-equal ' + $e + ' ' + $byExt[$e]) }
foreach ($k in $diff) {
  $a=$g1[$k][1]; $b=$g2[$k][1]
  $lines.Add('DIFF ' + $k + ' g1 ' + $g1[$k][0].Substring(0,16) + ' g2 ' + $g2[$k][0].Substring(0,16))
  if (-not (Test-Path -LiteralPath $a) -or -not (Test-Path -LiteralPath $b)) { $lines.Add('  file missing now: ' + (Test-Path -LiteralPath $a) + ' ' + (Test-Path -LiteralPath $b)); continue }
  $ha=(Get-FileHash -Algorithm SHA256 -LiteralPath $a).Hash.ToLowerInvariant(); $hb=(Get-FileHash -Algorithm SHA256 -LiteralPath $b).Hash.ToLowerInvariant()
  if ($ha -ne $g1[$k][0] -or $hb -ne $g2[$k][0]) { $lines.Add('  files changed since the logs: ' + $ha.Substring(0,16) + ' ' + $hb.Substring(0,16)) }
  $ba=[IO.File]::ReadAllBytes($a); $bb=[IO.File]::ReadAllBytes($b)
  $lines.Add('  sizes ' + $ba.Length + ' ' + $bb.Length)
  if ($ba.Length -eq $bb.Length) {
    $offs=New-Object System.Collections.Generic.List[int]
    for ($i=0; $i -lt $ba.Length; $i++) { if ($ba[$i] -ne $bb[$i]) { $offs.Add($i); if ($offs.Count -ge 64) { break } } }
    $lines.Add('  differing byte offsets (first 64 at most): ' + $offs.Count + ' : ' + ($offs -join ' '))
  } elseif ($k -match '\.(lm1|c|h|log|txt|lm2)$') {
    $la=@(Get-Content -LiteralPath $a); $lb=@(Get-Content -LiteralPath $b)
    $first=-1
    for ($i=0; $i -lt [Math]::Min($la.Count,$lb.Count); $i++) { if ($la[$i] -cne $lb[$i]) { $first=$i+1; break } }
    $lines.Add('  lines ' + $la.Count + ' ' + $lb.Count + ' first differing line ' + $first)
    $pa=($la -join "`n") -replace '[()]',''; $pb=($lb -join "`n") -replace '[()]',''
    $lines.Add('  equal after deleting parentheses: ' + ($pa -ceq $pb))
  }
}
$lines.Add('done ' + [DateTime]::UtcNow.ToString('o'))
[IO.File]::WriteAllText($out, (($lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Output ('COMPARE117' + $try + ' in-both ' + $both.Count + ' raw-equal ' + $equal.Count + ' differ ' + $diff.Count)
