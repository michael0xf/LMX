#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$parent="$repo/build2/codex_reference_receive165";$stage="$repo/build2/codex_pointer_receive166";$published="$repo/steps/witnesses/used-scope-20261020"
$inputs=Get-Content -LiteralPath "$published/receiving165-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281){throw 'Exact281 parent inputs'}
foreach($pin in $inputs){
 if([IO.Path]::GetFileName($pin.Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 $source="$parent/$($pin.Path)";$target="$stage/$($pin.Path)"
 if(Test-Path -LiteralPath $target){throw 'Preserve166 input'}
 if((Get-FileHash -LiteralPath $source).Hash -cne $pin.Sha256){throw 'Frozen165 input changed'}
 $directory=[IO.Path]::GetDirectoryName($target);if(-not(Test-Path -LiteralPath $directory)){New-Item -ItemType Directory -Path $directory|Out-Null}
 Copy-Item -LiteralPath $source -Destination $target
 if((Get-FileHash -LiteralPath $target).Hash -cne $pin.Sha256){throw '166 input copy differs'}
}
$evidence=Get-Content -LiteralPath "$published/receiving165-evidence.json" -Raw|ConvertFrom-Json
foreach($item in $evidence.PublishedFiles.PSObject.Properties){
 $name=$item.Name;if($name -in @('prepare.ps1','receipt.ps1','audit.ps1','checkpoint.ps1') -or $name -like 'verify*' -or $name -eq 'final-fixtures.ps1'){continue}
 if([IO.Path]::GetFileName($name) -ieq 'l2_driver_launch.err'){throw 'Protected basename before recipe IO'}
 $target="$stage/$name";if(Test-Path -LiteralPath $target){throw 'Preserve166 recipe'}
 $source="$published/$($item.Value.Path)";if((Get-FileHash -LiteralPath $source).Hash -cne $item.Value.Sha256){throw 'Published165 recipe changed'}
 Copy-Item -LiteralPath $source -Destination $target
 if($name.EndsWith('.ps1')){$text=[IO.File]::ReadAllText($target).Replace('codex_reference_receive165','codex_pointer_receive166');[IO.File]::WriteAllText($target,$text,[Text.UTF8Encoding]::new($false))}
}
[pscustomobject]@{BaseMain='8a84e6ea1fc296fef838a889cc192dd3fa3a832c';Inputs=$inputs.Count;Stage=$stage;OldBuildUntouched=$true}|ConvertTo-Json
