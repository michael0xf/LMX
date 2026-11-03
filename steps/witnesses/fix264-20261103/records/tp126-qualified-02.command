$ErrorActionPreference='Stop'
$p='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$src="$p/tp126-split-baseline-01/names-02"
$term="$p/pins/tp126-qualified-02.terminal.txt"
$dir="$p/tp126-qualified-02-run"
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $dir)) { throw 'existing operation' }
New-Item -ItemType Directory -Path $dir|Out-Null
$bad=0
foreach ($fixture in @('unit_n4_split_immutable_data_read','unit_n4_split_immutable_code_assigns')){
 foreach ($mode in @('native','forced')){
  $exe="$src/$fixture-$mode/p-prod.exe"
  $unit=Get-Content -Raw -LiteralPath "$src/$fixture-$mode/p.lm1"
  if ($unit -notmatch 'return: 1U'){throw 'qualified program does not declare one root'}
  foreach ($walk in @(0,1)){
   $cwd=Join-Path $dir "$fixture-$mode-$walk"
   New-Item -ItemType Directory -Path $cwd|Out-Null
   Set-Location -LiteralPath $cwd
   $argsRun=@('1','entry','7')
   if($walk -eq 1){ $argsRun+=@('walkroot','1') }
   & 'C:/Git/usr/bin/timeout.exe' '120' $exe @argsRun *> "$cwd/run.log"
   $exitCase=$LASTEXITCODE
   Add-Content -LiteralPath $term -Encoding utf8 -Value ("$fixture $mode walkroot=$walk qualified=1 entry=7 exit=$exitCase sha256="+(Get-FileHash -LiteralPath $exe).Hash)
   if($exitCase -ne 0){$bad++}
  }
 }
}
Add-Content -LiteralPath $term -Encoding utf8 -Value ("EndUTC "+[DateTime]::UtcNow.ToString('o')+" failures=$bad")
exit $bad
