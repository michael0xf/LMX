try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 287. Read-only acceptance of the finished boot149b (the second whole of the slice, after the index reception
# check): no compiler, no tool, only named files are read.
# (1) the stage against its frozen manifest; (2) every producer record of both generations: steps, inner exits, the exe of each
# frontend step; (3) the sha256 lines of the two generation logs, each path rehashed now, generations compared raw, every
# differing pair compared byte for byte; (4) consumed inputs of both generations; (5) working tool and bundle against G2;
# (6) the runtime objects and the tool against the G2 of boot148b (no kernel or tools source changed in slice 287).
# Output: pins/boot149b-compare.txt.  Expected numbers are not substituted: the file reports what it measured.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$label='quick149b'
$stage="$p\cold-boot149b"
$Q="$stage\$label"
$out="$p\pins\boot149b-compare.txt"
if (Test-Path -LiteralPath $out) { throw 'output exists' }
if (-not (Select-String -LiteralPath "$p\pins\boot149b-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot149b did not pass' }
function ShaOf([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('boot149b compare ' + [DateTime]::UtcNow.ToString('o'))
foreach ($l in @(Get-Content -LiteralPath "$p\pins\boot149b-quick.terminal.txt")) { $lines.Add('terminal ' + $l) }

# (1) stage
$man=@(Get-Content -LiteralPath "$p\pins\source-boot149b.sha256" | Where-Object { $_ -ne '' })
$bad=0
foreach ($l in $man) {
  $parts=$l -split '  ',2
  $f=Join-Path $stage ($parts[1] -replace '/','\')
  if (-not (Test-Path -LiteralPath $f)) { $bad++; $lines.Add('source missing ' + $parts[1]); continue }
  if ((ShaOf $f) -ne $parts[0].ToLowerInvariant()) { $bad++; $lines.Add('source differs ' + $parts[1]) }
}
$lines.Add('source inputs ' + $man.Count + ' mismatches ' + $bad + ' manifest ' + (ShaOf "$p\pins\source-boot149b.sha256") + ' source-tp149 ' + (ShaOf "$p\pins\source-tp149.sha256"))

# (2) producers
foreach ($g in @('g1','g2')) {
  foreach ($part in @('frontend','runtime','tool')) {
    $rec="$Q\$g\$part\record.txt"
    $rl=@(Get-Content -LiteralPath $rec)
    $steps=@($rl | Where-Object { $_.StartsWith('$ ') })
    $kinds=@($rl | Where-Object { $_ -cmatch '^  kind ' })
    $nonzero=@($kinds | Where-Object { $_ -cnotmatch '^  kind \d+ exit 0( |$)' })
    $lines.Add("producers $g/$part steps " + $steps.Count + ' kind-lines ' + $kinds.Count + ' nonzero ' + $nonzero.Count)
    foreach ($n in $nonzero) { $lines.Add('  nonzero: ' + $n) }
    $fes=@{}
    for ($i=0; $i -lt $rl.Count; $i++) {
      if ($rl[$i].StartsWith('$ ') -and ($rl[$i] -cmatch '^\$ (\S*/l2trans\.exe) ')) {
        $sha=''
        if ($rl[$i+1] -cmatch '^  exe ([0-9a-f]{64})') { $sha=$Matches[1] }
        $fes[($Matches[1] + ' ')]=$true
        if ($rl[$i] -cmatch '^\$ (\S*/l2trans\.exe) ') { $fes.Remove(($Matches[1] + ' ')); $fes[($Matches[1] + ' ' + $sha)]=$true }
      }
    }
    foreach ($k in ($fes.Keys | Sort-Object)) { $lines.Add('  l2trans ' + $k) }
  }
}

# (3) inventories
function Pairs([string[]]$src, [string]$gen) {
  $h=[ordered]@{}
  foreach ($l in $src) {
    if ($l -cmatch '^([0-9a-f]{64})  (C:/\S.*)$') { $h[($Matches[2] -replace "/$label/$gen/", "/$label/gN/")]=@($Matches[1], $Matches[2]) }
  }
  return $h
}
$quick=@(Get-Content -LiteralPath "$p\pins\boot149b-quick.log")
$cut=-1
for ($i=0; $i -lt $quick.Count; $i++) { if ($quick[$i] -like 'PASS bootstrap: G0 builds and tests whole G1*') { $cut=$i; break } }
if ($cut -lt 0) { throw 'G1 pass line not found' }
$g1=Pairs $quick[0..$cut] 'g1'
$g2=Pairs @(Get-Content -LiteralPath "$Q\g2-build.log") 'g2'
$lines.Add('inventory G1 paths ' + $g1.Count + ' G2 paths ' + $g2.Count)
$stale=0
foreach ($set in @($g1,$g2)) {
  foreach ($k in @($set.Keys)) {
    $f=$set[$k][1]
    if (-not (Test-Path -LiteralPath $f)) { $stale++; $lines.Add('stale missing ' + $f); continue }
    if ((ShaOf $f) -ne $set[$k][0]) { $stale++; $lines.Add('stale differs ' + $f) }
  }
}
$lines.Add('actual hashes checked ' + ($g1.Count + $g2.Count) + ' stale ' + $stale)
$both=@($g1.Keys | Where-Object { $g2.Contains($_) })
$onlyG1=@($g1.Keys | Where-Object { -not $g2.Contains($_) })
$onlyG2=@($g2.Keys | Where-Object { -not $g1.Contains($_) })
$equal=@($both | Where-Object { $g1[$_][0] -eq $g2[$_][0] })
$diff=@($both | Where-Object { $g1[$_][0] -ne $g2[$_][0] })
$lines.Add('in both ' + $both.Count + ' raw-equal ' + $equal.Count + ' differ ' + $diff.Count + ' only-G1 ' + $onlyG1.Count + ' only-G2 ' + $onlyG2.Count)
foreach ($k in $onlyG1) { $lines.Add('only-G1 ' + $k) }
foreach ($k in $onlyG2) { $lines.Add('only-G2 ' + $k) }
foreach ($k in $diff) {
  $a=$g1[$k][1]; $b=$g2[$k][1]
  $ba=[IO.File]::ReadAllBytes($a); $bb=[IO.File]::ReadAllBytes($b)
  $lines.Add('DIFF ' + $k + ' g1 ' + $g1[$k][0].Substring(0,16) + ' g2 ' + $g2[$k][0].Substring(0,16) + ' sizes ' + $ba.Length + ' ' + $bb.Length)
  if ($ba.Length -eq $bb.Length) {
    $offs=New-Object System.Collections.Generic.List[int]
    for ($i=0; $i -lt $ba.Length; $i++) { if ($ba[$i] -ne $bb[$i]) { $offs.Add($i); if ($offs.Count -ge 64) { break } } }
    $lines.Add('  differing byte offsets (first 64 at most): ' + $offs.Count + ' : ' + ($offs -join ' '))
  }
}

# (4) consumed inputs
$c1="$Q\g1\consumed-inputs.sha256"; $c2="$Q\g2\consumed-inputs.sha256"
$lines.Add('consumed lines ' + @(Get-Content -LiteralPath $c1).Count + ' ' + @(Get-Content -LiteralPath $c2).Count + ' raw-equal ' + ((ShaOf $c1) -eq (ShaOf $c2)))

# (5) working tool and bundle
$lines.Add('working tool ' + (ShaOf "$Q\lmxtool.exe") + ' g2 tool ' + (ShaOf "$Q\g2\tool\lmxtool-tool.exe"))
$lines.Add('working bundle ' + (ShaOf "$Q\working-bundle.sha256") + ' g2 bundle ' + (ShaOf "$Q\g2\bundle.sha256"))
foreach ($n in @('frontend\l2trans.exe','frontend\l1trans.exe','frontend\l2_libc.o','runtime\driver.o','runtime\driver-observe.o','tool\lmxtool-tool.exe')) {
  $lines.Add('g1 ' + $n + ' ' + (ShaOf "$Q\g1\$n"))
  $lines.Add('g2 ' + $n + ' ' + (ShaOf "$Q\g2\$n"))
}

# (6) the G2 of boot148b: runtime objects and tool; the candidate frontend fe149b
$lines.Add('boot148b g2 runtime driver ' + (ShaOf "$p\cold-boot148b\quick148b\g2\runtime\driver.o") + ' observe ' + (ShaOf "$p\cold-boot148b\quick148b\g2\runtime\driver-observe.o"))
$lines.Add('boot148b g2 tool ' + (ShaOf "$p\cold-boot148b\quick148b\g2\tool\lmxtool-tool.exe") + ' working tool ' + (ShaOf "$p\cold-boot148b\quick148b\lmxtool.exe"))
$lines.Add('candidate fe149b l2trans ' + (ShaOf "$p\cold-tp140\fe149b\l2trans.exe") + ' l1trans ' + (ShaOf "$p\cold-tp140\fe149b\l1trans.exe"))
$lines.Add('done ' + [DateTime]::UtcNow.ToString('o'))
[IO.File]::WriteAllText($out, (($lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Output ('COMPARE149b in-both ' + $both.Count + ' raw-equal ' + $equal.Count + ' differ ' + $diff.Count + ' stale ' + $stale + ' source-mismatches ' + $bad)
