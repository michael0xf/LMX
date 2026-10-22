#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$parent="$repo/build2/codex_primary_children160";$stage="$repo/build2/codex_application_values161"
$manifest="$repo/steps/witnesses/used-scope-20261020/primary160-inputs.json"
$inputs=Get-Content -LiteralPath $manifest -Raw|ConvertFrom-Json
if($inputs.Count -ne 281){throw 'Exact281 parent inputs'}
$rows=@()
foreach($p in $inputs){
 if([IO.Path]::GetFileName($p.Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 $source="$parent/$($p.Path)";$target="$stage/$($p.Path)"
 if(Test-Path -LiteralPath $target){throw 'Preserve161 input'}
 if((Get-FileHash -LiteralPath $source).Hash -cne $p.Sha256){throw 'Frozen160 parent changed'}
 $directory=[IO.Path]::GetDirectoryName($target);if(-not(Test-Path -LiteralPath $directory)){New-Item -ItemType Directory -Path $directory|Out-Null}
 Copy-Item -LiteralPath $source -Destination $target
 if((Get-FileHash -LiteralPath $target).Hash -cne $p.Sha256){throw '161 copy differs'}
 $rows+=@{Path=$p.Path;Sha256=$p.Sha256;Bytes=$p.Bytes}
}
foreach($name in 'build.ps1','owned-test.c','primary-test.c','primary.ps1'){
 $target="$stage/$name";if(Test-Path -LiteralPath $target){throw 'Preserve161 recipe'}
 Copy-Item -LiteralPath "$parent/$name" -Destination $target
 if($name.EndsWith('.ps1')){$text=[IO.File]::ReadAllText($target).Replace('codex_primary_children160','codex_application_values161').Replace('frontend-04','frontend-01');[IO.File]::WriteAllText($target,$text,[Text.UTF8Encoding]::new($false))}
}
[IO.File]::WriteAllText("$stage/parent-inputs.json",(($rows|ConvertTo-Json -Depth 5).Replace([string][char]13,'')+[char]10),[Text.UTF8Encoding]::new($false))
[pscustomobject]@{BaseMain='ac5d8540b496f31426831654cb9d4dfea04073da';SourceHeaderFiles=$inputs.Count;Stage=$stage;NoOldBuildIO=$true}|ConvertTo-Json
