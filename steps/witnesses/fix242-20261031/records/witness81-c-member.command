try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\witness81-c-member.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate81\fe81\l2trans.exe")) { throw 'nofe81' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
function Note([string]$line) { Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' ' + $line) -Encoding utf8 }
$st=@{ k = 0 }
function Tool([string[]]$a) {
  $st.k = $st.k + 1
  $nn='{0:D2}' -f $st.k
  $cwd="$p\witness81-c-member-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @a *> "$p\pins\witness81-c-member-$nn.log"
  $e=$LASTEXITCODE
  Note ("tool $nn exit=$e " + ($a -join ' '))
  if ($e -ne 0) { throw "tool $nn exit $e" }
}
Tool @('manifest', "$P2/pins/witness81-c-member-support.list", "$P2/cold-candidate81", "$P2/pins/witness81-c-member-support.sha256")
Tool @('manifest', "$P2/pins/witness81-c-member-source.list", "$P2/variants/frontend81", "$P2/pins/witness81-c-member-source.sha256")
foreach ($label in @('fe81','fe80b')) {
  $stage = if ($label -eq 'fe81') { 'cold-candidate81' } else { 'cold-candidate80b' }
  $fe="$p\$stage\$label\l2trans.exe"
  $w="$p\witness81-c-member-$label"
  if (Test-Path -LiteralPath $w) { throw "witnessexists $label" }
  Tool @('stage-copy', "$P2/pins/witness81-c-member-support.sha256", "$P2/cold-candidate81", "$P2/witness81-c-member-$label")
  Tool @('stage-copy', "$P2/pins/witness81-c-member-source.sha256", "$P2/variants/frontend81", "$P2/witness81-c-member-$label/src/l2src")
  Set-Location -LiteralPath "$w\src"
  & $fe --library --machine probe --header l2src/unit_machine_c_member_receiving.h.lm1 l2src/unit_machine_c_member_receiving.lm2 l2src/convert.lm2 l2src/primitive.lm2 l2src/unit_machine_c_member_receiving.lm1 *> "$w\l2trans.log"
  $e=$LASTEXITCODE
  $feh=(Get-FileHash -Algorithm SHA256 -LiteralPath $fe).Hash
  Note ("$label exit=$e fe=$feh cwd=$w\src")
  foreach ($o in @('l2src\unit_machine_c_member_receiving.lm1','l2src\unit_machine_c_member_receiving.h.lm1')) {
    if (Test-Path -LiteralPath "$w\src\$o") { Note ("$label out " + (Get-FileHash -Algorithm SHA256 -LiteralPath "$w\src\$o").Hash + " $o") } else { Note ("$label out absent $o") }
  }
}
Write-Output 'WITNESS81 done'
