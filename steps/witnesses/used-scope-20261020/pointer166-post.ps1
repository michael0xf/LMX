#requires -Version 7.0
param([string]$Label='additional-06b')
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_pointer_receive166";$out="$stage/$Label"
if(Test-Path -LiteralPath $out){throw 'Preserve additional observations'}
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
New-Item -ItemType Directory -Path $out|Out-Null
. "$repo/tools/ps51_proc.ps1"
if(-not(Test-Path -LiteralPath "$stage/pointer-06b/results.json")){& "$stage/pointer.ps1" -Frontend frontend-06 -Label pointer-06b}
$pointer=Get-Content -LiteralPath "$stage/pointer-06b/results.json" -Raw|ConvertFrom-Json
if($pointer.Exit -ne 0 -or $pointer.FrontendCSha256 -cne (Get-FileHash -LiteralPath "$stage/frontend-06/frontend.c").Hash -or $pointer.FixtureSha256 -cne (Get-FileHash -LiteralPath "$stage/pointer-test.c").Hash){throw 'Only reuse exact completed pointer observation'}
$parentC='C:/Nyasha_Planet/LMX/build2/codex_reference_receive165/frontend-02/frontend.c'
if(-not(Test-Path -LiteralPath "$stage/receive-parent-06/results.json")){& "$stage/call-route.ps1" -Frontend frontend-06 -Label receive-parent-06 -Sources @('machine-values','letter-receiving') -ObserveRemaining -CompilerC $parentC}
$parent=Get-Content -LiteralPath "$stage/receive-parent-06/results.json" -Raw|ConvertFrom-Json
if($parent.Count -ne 4 -or @($parent|Where-Object {$_.Exit -ne 0 -or $_.FrontendCSha256 -cne (Get-FileHash -LiteralPath $parentC).Hash}).Count -or (Get-FileHash -LiteralPath "$stage/receive-parent-06/fixture.c").Hash -cne (Get-FileHash -LiteralPath "$stage/call-route-test.c").Hash){throw 'Only reuse same completed parent probe'}
$shell166=(Get-Command pwsh.exe -ErrorAction Stop).Source
$rows=@()
foreach($case in @(@{Source='letter-receiving.lm2';Label='letter-full-06';Bodies=2},@{Source='letter-asserted.lm2';Label='asserted-full-06';Bodies=1})){
 $result=Invoke-ProcBounded -Exe $shell166 -Argv @('-NoProfile','-File',"$stage/named-values.ps1",'-Frontend','frontend-06','-Label',$case.Label,'-SourceFile',$case.Source,'-ForcedBodies',[string]$case.Bodies) -TimeoutSec 180 -Log "$out/$($case.Label).log"
 if(-not $result.Started -or $result.TimedOut -or $result.Code -notin @(0,1)){throw 'Additional positive execution failed before an observed verdict'}
 $runs=@(Get-Content -LiteralPath "$stage/$($case.Label)/results.json" -Raw|ConvertFrom-Json)
 $builds=@(Get-Content -LiteralPath "$stage/$($case.Label)/builds.json" -Raw|ConvertFrom-Json)
 $okay=$result.Code -eq 0 -and $runs.Count -eq 8 -and -not @($runs|Where-Object {-not $_.Success}).Count
 $rows+=@{Source=$case.Source;SourceSha256=(Get-FileHash -LiteralPath "$stage/$($case.Source)").Hash;Label=$case.Label;ScriptExit=$result.Code;Compilation=$builds;Runs=$runs;ExpectedEntry=7;AllFullPositive=$okay;StillOpen=(-not $okay);RefusalOracle=$false}
 [IO.File]::WriteAllText("$out/results.json",(($rows|ConvertTo-Json -Depth 10).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
}
$rows|Select-Object Source,ScriptExit,ExpectedEntry,AllFullPositive,StillOpen,RefusalOracle|ConvertTo-Json
