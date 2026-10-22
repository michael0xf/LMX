#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$parent="$repo/build2/codex_candidate_values164";$stage="$repo/build2/codex_reference_receive165";$published="$repo/steps/witnesses/used-scope-20261020"
$inputs=Get-Content -LiteralPath "$published/candidate164-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281){throw 'Exact281 parent inputs'}
foreach($pin in $inputs){
 if([IO.Path]::GetFileName($pin.Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 $source="$parent/$($pin.Path)";$target="$stage/$($pin.Path)"
 if(Test-Path -LiteralPath $target){throw 'Preserve165 source'}
 if((Get-FileHash -LiteralPath $source).Hash -cne $pin.Sha256){throw 'Frozen164 input changed'}
 $directory=[IO.Path]::GetDirectoryName($target);if(-not(Test-Path -LiteralPath $directory)){New-Item -ItemType Directory -Path $directory|Out-Null}
 Copy-Item -LiteralPath $source -Destination $target
 if((Get-FileHash -LiteralPath $target).Hash -cne $pin.Sha256){throw '165 input copy differs'}
}
$evidence=Get-Content -LiteralPath "$published/candidate164-evidence.json" -Raw|ConvertFrom-Json
foreach($item in $evidence.PublishedFiles.PSObject.Properties){
 $name=$item.Name;if($name -in @('prepare.ps1','receipt.ps1','audit.ps1','checkpoint.ps1','verify08.ps1')){continue}
 if([IO.Path]::GetFileName($name) -ieq 'l2_driver_launch.err'){throw 'Protected basename before recipe IO'}
 $target="$stage/$name";if(Test-Path -LiteralPath $target){throw 'Preserve165 recipe'}
 $source="$published/$($item.Value.Path)";if((Get-FileHash -LiteralPath $source).Hash -cne $item.Value.Sha256){throw 'Published164 recipe changed'}
 Copy-Item -LiteralPath $source -Destination $target
 if($name.EndsWith('.ps1')){$text=[IO.File]::ReadAllText($target).Replace('codex_candidate_values164','codex_reference_receive165');[IO.File]::WriteAllText($target,$text,[Text.UTF8Encoding]::new($false))}
}
[pscustomobject]@{BaseMain='b3b870bad035222c9b4fcdbd244d0718dad7c442';Inputs=$inputs.Count;Stage=$stage;OldBuildUntouched=$true}|ConvertTo-Json
