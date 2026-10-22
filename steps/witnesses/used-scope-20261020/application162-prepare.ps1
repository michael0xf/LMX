#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$parent="$repo/build2/codex_application_values161";$stage="$repo/build2/codex_application_sites162"
$inputs=Get-Content -LiteralPath "$repo/steps/witnesses/used-scope-20261020/application161-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281){throw 'Exact281 parent inputs'}
foreach($pin in $inputs){
 if([IO.Path]::GetFileName($pin.Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 $source="$parent/$($pin.Path)";$target="$stage/$($pin.Path)"
 if(Test-Path -LiteralPath $target){throw 'Preserve162 input'}
 if((Get-FileHash -LiteralPath $source).Hash -cne $pin.Sha256){throw 'Frozen161 parent changed'}
 $directory=[IO.Path]::GetDirectoryName($target);if(-not(Test-Path -LiteralPath $directory)){New-Item -ItemType Directory -Path $directory|Out-Null}
 Copy-Item -LiteralPath $source -Destination $target
 if((Get-FileHash -LiteralPath $target).Hash -cne $pin.Sha256){throw '162 copy differs'}
}
foreach($name in 'build.ps1','owned-test.c','primary-test.c','primary.ps1','application-test.c','application.ps1','routes.ps1'){
 $target="$stage/$name";if(Test-Path -LiteralPath $target){throw 'Preserve162 recipe'}
 Copy-Item -LiteralPath "$parent/$name" -Destination $target
 if($name.EndsWith('.ps1')){$text=[IO.File]::ReadAllText($target).Replace('codex_application_values161','codex_application_sites162').Replace('frontend-05','frontend-01');[IO.File]::WriteAllText($target,$text,[Text.UTF8Encoding]::new($false))}
}
[pscustomobject]@{BaseMain='b6854e5d52d3eaf65afce0a167239e0892838351';SourceHeaderFiles=$inputs.Count;Stage=$stage;NoOldBuildIO=$true}|ConvertTo-Json
