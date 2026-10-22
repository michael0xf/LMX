#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$parent="$repo/build2/codex_application_sites162";$stage="$repo/build2/codex_reference_values163";$published="$repo/steps/witnesses/used-scope-20261020"
$inputs=Get-Content -LiteralPath "$published/application162-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281){throw 'Exact281 parent inputs'}
foreach($pin in $inputs){
 if([IO.Path]::GetFileName($pin.Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 $source="$parent/$($pin.Path)";$target="$stage/$($pin.Path)"
 if(Test-Path -LiteralPath $target){throw 'Preserve163 source'}
 if((Get-FileHash -LiteralPath $source).Hash -cne $pin.Sha256){throw 'Frozen162 input changed'}
 $directory=[IO.Path]::GetDirectoryName($target);if(-not(Test-Path -LiteralPath $directory)){New-Item -ItemType Directory -Path $directory|Out-Null}
 Copy-Item -LiteralPath $source -Destination $target
 if((Get-FileHash -LiteralPath $target).Hash -cne $pin.Sha256){throw '163 copy differs'}
}
$evidence=Get-Content -LiteralPath "$published/application162-evidence.json" -Raw|ConvertFrom-Json
foreach($item in $evidence.PublishedFiles.PSObject.Properties){
 $name=$item.Name;if($name -eq 'prepare.ps1' -or $name -eq 'receipt.ps1' -or $name -eq 'audit.ps1' -or $name -eq 'checkpoint.ps1' -or $name.StartsWith('verify24')){continue}
 if([IO.Path]::GetFileName($name) -ieq 'l2_driver_launch.err'){throw 'Protected basename before recipe IO'}
 $target="$stage/$name";if(Test-Path -LiteralPath $target){throw 'Preserve163 recipe'}
 $source="$published/$($item.Value.Path)";if((Get-FileHash -LiteralPath $source).Hash -cne $item.Value.Sha256){throw 'Published recipe/test changed'}
 Copy-Item -LiteralPath $source -Destination $target
 if($name.EndsWith('.ps1')){$text=[IO.File]::ReadAllText($target).Replace('codex_application_sites162','codex_reference_values163');[IO.File]::WriteAllText($target,$text,[Text.UTF8Encoding]::new($false))}
}
[pscustomobject]@{BaseMain='328d684a38b70d72645ac28f946a8030136a4d68';Inputs=$inputs.Count;Stage=$stage;OldBuildUntouched=$true}|ConvertTo-Json
