# Read-only unit controls for the generated-graph observer. Loading function
# definitions through the PowerShell AST never executes the harness/build body.
$ErrorActionPreference = 'Stop'
$harnessPath = Join-Path $PSScriptRoot 'l2_harness.ps1'
$parseTokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($harnessPath, [ref]$parseTokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw ($parseErrors | ForEach-Object { $_.Message }) }
$required = @('Resolve-BuilderIdentity', 'Get-BuilderSourceBody', 'Get-BuilderIdentityFacts', 'Get-WalkGraphFacts', 'Test-WalkShapeNode')
foreach ($name in $required) {
    $definition = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name }, $false))
    if ($definition.Count -ne 1) { throw "Expected one observer definition: $name" }
    Invoke-Expression $definition[0].Extent.Text
}
$checks = 0
function Assert-Fact([bool]$Condition, [string]$Label) {
    $script:checks++
    if (-not $Condition) { throw "Observer control failed: $Label" }
}
$text = @'
@: Lmx l2_rw1 lmx_walk_plain(l2_program_arena, l2_entry_unit, 2U)
@: Lmx l2_rw2 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_SET, 3U)
@: Lmx l2_rw3 l2_rw1
@: Lmx l2_rw4 l2_rw3
l2_rw3\parent: l2_rw2
if: lmx_arena_ref_store(l2_rw4, 0U, lmx_arena_ref_value(l2_rw_roles, (cast: (size_t) c.LMX_WALK_OP_OWN))) != 0
if: lmx_arena_ref_store(l2_rw2, 1U, (cast: (@: void) l2_rw3)) != 0
@: Lmx l2_rw5 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw2, c.LMX_WALK_OP_LIT, 2U)
if: lmx_arena_ref_store(l2_rw2, 2U, (cast: (@: void) l2_rw5)) != 0
if: lmx_arena_ref_store(l2_entry_unit, 0U, (cast: (@: void) l2_rw2)) != 0
@: Lmx l2_rw6 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_SET, 3U)
'@
$shape = [pscustomobject]@{ Op = 'SET'; Width = 3; Edges = @(
    [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
    [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2 } }
) }
$graph = Get-WalkGraphFacts $text
Assert-Fact (Test-WalkShapeNode $graph 'l2_rw2' $shape) 'deferred role through transitive aliases'
Assert-Fact ($graph.Frames.ContainsKey('l2_rw1') -and -not $graph.Frames.ContainsKey('l2_rw3') -and -not $graph.Frames.ContainsKey('l2_rw4')) 'one allocation, not three alias objects'
Assert-Fact ($graph.Frames['l2_rw1'].Owner -eq 'l2_rw2') 'FILL parent, not allocation context'
Assert-Fact ($graph.Reachable.ContainsKey('l2_rw2') -and -not $graph.Reachable.ContainsKey('l2_rw6')) 'attachment, not mere allocation, establishes reachability'
$changed = Get-WalkGraphFacts ($text.Replace('c.LMX_WALK_OP_OWN', 'c.LMX_WALK_OP_AT'))
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'wrong deferred role is rejected'
$changed = Get-WalkGraphFacts ($text.Replace('lmx_walk_plain(l2_program_arena, l2_entry_unit, 2U)', 'lmx_walk_plain(l2_program_arena, l2_entry_unit, 3U)'))
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'wrong reserved width is rejected'
$changed = Get-WalkGraphFacts ($text.Replace('(cast: (@: void) l2_rw3)', '(cast: (@: void) l2_rw5)'))
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'wrong aliased edge is rejected'
$changed = Get-WalkGraphFacts ($text + "`nif: lmx_arena_ref_store(l2_rw3, 0U, lmx_arena_ref_value(l2_rw_roles, (cast: (size_t) c.LMX_WALK_OP_AT))) != 0")
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'last physical role store wins'
$changed = Get-WalkGraphFacts ($text + "`nif: lmx_arena_ref_store(l2_rw2, 0U, lmx_arena_ref_value(l2_rw_roles, (cast: (size_t) c.LMX_WALK_OP_AT))) != 0")
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'explicit role supersedes frame constructor'
$changed = Get-WalkGraphFacts ($text + "`nif: lmx_arena_ref_store(l2_rw2, 0U, 0) != 0")
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'cleared role does not inherit constructor opcode'
$rebinding = $text + "`n@: Lmx l2_rw7 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_AT, 2U)`nl2_rw3: l2_rw7"
$changed = Get-WalkGraphFacts $rebinding
Assert-Fact (Test-WalkShapeNode $changed 'l2_rw2' $shape) 'later alias rebinding cannot rewrite a stored edge'
$numeric = Get-WalkGraphFacts ($text + "`nif: lmx_walk_store_int(l2_program_arena, l2_rw4, 1U, 42) != c.LMX_WALK_OK")
Assert-Fact ($numeric.Ints.ContainsKey('l2_rw1:1') -and $numeric.Ints['l2_rw1:1'] -eq 42) 'numeric facts use the same aliased object'
$rejected = $false
try { Get-WalkGraphFacts ($text + "`nl2_rw1: l2_rw5") | Out-Null } catch { $rejected = $true }
Assert-Fact $rejected 'allocated stable-handle rebinding is not silently inferred'
$unknown = Get-WalkGraphFacts ($text + "`nl2_rw3: l2_rw99`nif: lmx_arena_ref_store(l2_rw3, 0U, lmx_arena_ref_value(l2_rw_roles, (cast: (size_t) c.LMX_WALK_OP_AT))) != 0")
Assert-Fact (-not $unknown.Frames.ContainsKey('') -and -not $unknown.Stores.Where({ $_.Parent -eq '' }).Count) 'unknown identity never manufactures an empty frame'
$changed = Get-WalkGraphFacts ($text + "`nif: lmx_arena_ref_store(l2_rw2, 0U, (cast: (@: void) c.LMX_WALK_OP_SET)) != 0")
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'numeric opcode is not a shared role-record address'
$changed = Get-WalkGraphFacts ($text + "`nif: lmx_walk_store_int(l2_program_arena, l2_rw2, 1U, 42) != c.LMX_WALK_OK")
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'numeric helper replaces an earlier object edge'
$changed = Get-WalkGraphFacts ($text + "`nif: lmx_walk_store_int(l2_program_arena, l2_rw4, 1U, 42) != c.LMX_WALK_OK`nif: lmx_arena_ref_store(l2_rw1, 1U, (cast: (@: void) l2_rw5)) != 0")
Assert-Fact (-not $changed.Ints.ContainsKey('l2_rw1:1')) 'later reference store replaces numeric facts'
$changed = Get-WalkGraphFacts ($text + "`nif: lmx_walk_store_char(l2_program_arena, l2_rw2, 1U, 42) != c.LMX_WALK_OK")
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'other typed helper also replaces the edge'
$changed = Get-WalkGraphFacts ($text + "`nif: lmx_arena_ref_store(l2_rw2, 1U, (cast: (@: void) l2_rw1)) != 0 || lmx_walk_store_int(l2_program_arena, l2_rw2, 1U, 42) != c.LMX_WALK_OK")
Assert-Fact (-not (Test-WalkShapeNode $changed 'l2_rw2' $shape)) 'same-line writes retain physical order'
$sourceAlias = @'
@: Lmx l2_sc1 lmx_node_new_owned(l2_program_arena)
if: lmx_arena_refs_open_owned(l2_program_arena, l2_sc1, 3U) != 0
@: Lmx l2_rw1 l2_sc1
l2_rw1\parent: l2_entry_unit
if: lmx_arena_ref_store(l2_rw1, 0U, lmx_arena_ref_value(l2_rw_roles, (cast: (size_t) c.LMX_WALK_OP_SET))) != 0
if: lmx_arena_ref_store(l2_entry_unit, 0U, (cast: (@: void) l2_rw1)) != 0
@: Lmx l2_rw2 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_OWN, 2U)
l2_rw1: l2_rw2
'@
$changed = Get-WalkGraphFacts $sourceAlias
Assert-Fact ($changed.Reachable.ContainsKey('l2_sc1') -and -not $changed.Reachable.ContainsKey('l2_rw2') -and $changed.Frames['l2_sc1'].Op -eq 'SET') 'source presentation cannot retarget a stored edge after alias rebinding'
$sourceAlias = $sourceAlias.Replace('l2_rw1: l2_rw2', '@: Lmx l2_rw3 l2_sc1')
$changed = Get-WalkGraphFacts $sourceAlias
Assert-Fact ($changed.Frames.Count -eq 2 -and $changed.Reachable.Count -eq 1) 'multiple source aliases describe one allocation'
Write-Output "walk graph facts GREEN: $checks controls"
