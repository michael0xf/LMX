#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$parent="$repo/build2/codex_primary_contract168";$stage="$repo/build2/codex_unevaluated169";$published="$repo/steps/witnesses/used-scope-20261020"
$inputs=Get-Content -LiteralPath "$published/storage168-inputs.json" -Raw|ConvertFrom-Json
if($inputs.Count -ne 281){throw 'Exact281 frozen parent inputs required'}
foreach($pin in $inputs){
 if([IO.Path]::GetFileName($pin.Path) -ieq 'l2_driver_launch.err'){throw 'Protected basename before IO'}
 $source="$parent/$($pin.Path)";$target="$stage/$($pin.Path)"
 if(Test-Path -LiteralPath $target){throw 'Preserve169 input'}
 if((Get-FileHash -LiteralPath $source).Hash -cne $pin.Sha256){throw 'Frozen168 input changed'}
 $directory=[IO.Path]::GetDirectoryName($target);if(-not(Test-Path -LiteralPath $directory)){New-Item -ItemType Directory -Path $directory|Out-Null}
 Copy-Item -LiteralPath $source -Destination $target
 if((Get-FileHash -LiteralPath $target).Hash -cne $pin.Sha256){throw '169 input differs'}
}
$e=Get-Content -LiteralPath "$published/storage168-evidence.json" -Raw|ConvertFrom-Json
foreach($item in $e.PublishedFiles.PSObject.Properties){
 $name=$item.Name;if($name -in @('prepare.ps1','receipt.ps1','audit.ps1','checkpoint.ps1','verify.ps1','post.ps1')){continue}
 if([IO.Path]::GetFileName($name) -ieq 'l2_driver_launch.err'){throw 'Protected basename before recipe IO'}
 $target="$stage/$name";if(Test-Path -LiteralPath $target){throw 'Preserve169 recipe'}
 $source="$published/$($item.Value.Path)";if((Get-FileHash -LiteralPath $source).Hash -cne $item.Value.Sha256){throw 'Published168 recipe changed'}
 Copy-Item -LiteralPath $source -Destination $target
 if($name.EndsWith('.ps1')){$text=[IO.File]::ReadAllText($target).Replace('codex_primary_contract168','codex_unevaluated169');[IO.File]::WriteAllText($target,$text,[Text.UTF8Encoding]::new($false))}
}
[pscustomobject]@{BaseMain='7de3bfcbfc0146a1425ea9aecd4f2e16b5c52d01';Inputs=$inputs.Count;SourceEdits=$false;BuildStarted=$false;OldBuildUntouched=$true}|ConvertTo-Json
