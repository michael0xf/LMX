#requires -Version 7.0
# Parent168 observations of the SAME new programs and of the historical OPEN
# C-door counterexample. They are OPEN evidence of the eager adapter, never a
# green execution and never a refusal oracle.
param([string]$Frontend='frontend-02',[int]$Attempt=2)
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_unevaluated169";$parent="$repo/build2/codex_primary_contract168/frontend-06/l2trans.exe"
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
$tag='{0:d2}' -f $Attempt
$observations=@()
foreach($case in @(@{Source='unevaluated-values';Roots=@(0,1)},@{Source='unevaluated-obligations';Roots=@(0,1)},@{Source='unevaluated-deferred';Roots=@(0,1)},@{Source='unevaluated-opaque';Roots=@(0,1)},@{Source='unevaluated-callable-class';Roots=@(0,1)},@{Source='unevaluated-callable-input';Roots=@(0,1)},@{Source='unevaluated-entry';Roots=@(0)},@{Source='machine-unevaluated-open';Roots=@(0,1)})){
 $label="$($case.Source)-parent168-$tag"
 & "$stage/program-values.ps1" -Frontend $Frontend -Label $label -SourceFile "$($case.Source).lm2" -CompilerPath $parent -Roots $case.Roots -Observe
 $phases=@(Get-Content -LiteralPath "$stage/$label/phases.json" -Raw|ConvertFrom-Json)
 $runs=@();if(Test-Path -LiteralPath "$stage/$label/results.json"){$runs=@(Get-Content -LiteralPath "$stage/$label/results.json" -Raw|ConvertFrom-Json)}
 $failed=@($phases|Where-Object Exit -ne 0)
 if(-not $failed.Count -and -not @($runs|Where-Object {-not $_.Success}).Count){throw "Parent168 unexpectedly satisfies the unevaluated contract: $($case.Source); inspect"}
 $observations+=@{Source=$case.Source;Label=$label;Tier='parent168';FailedPhases=@($failed|ForEach-Object {"$($_.Mode) $($_.Phase)"});Runs=$runs.Count;SuccessfulRuns=@($runs|Where-Object Success).Count;State='OPEN parent observation of the eager adapter; not a refusal oracle';SourceSha256=(Get-FileHash -LiteralPath "$stage/$($case.Source).lm2").Hash;CompilerSha256=(Get-FileHash -LiteralPath $parent).Hash;NotPositiveGate=$true}
}
[IO.File]::WriteAllText("$stage/parent-observations-$tag.json",(($observations|ConvertTo-Json -Depth 6).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
Write-Output 'POST169 parent168 observations of the unevaluated programs TERMINAL'
