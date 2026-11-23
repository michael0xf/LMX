# R01 — derive: usage and the complete thin implementation

The current uploaded R01 scenario has all three result fields: width=2,
height=5, depth=7. It leaves both input structures unchanged and performs one
ordinary model composition with one copy map. The expected result remains 257.

## Client and one-line equivalent

The complete scenario lives in [R01.lm3](../lmx/R01.lm3). It uses direct core
`derive(RecordModel; RecordPatch)`. The spelling `(merge(RecordModel; RecordPatch))`
uses the same composition; no second full client listing is needed.

## Complete LMX implementation

The direct current-kernel receiver is an ordinary call of this source from
[structures.lmx](../../LMX_Fn_Receivers/src/structures.lmx):

```lmx
RxDerive:
    @: base
    @: extension
    return: @
    derive:
        return: (merge(base; extension))
```
This is the complete thin helper, 71 nonwhitespace characters. It
collects the ordinary merge stream once. It does not deep-copy a second time,
remove width, manufacture a fixed record type, execute copied methods, or add
an implicit synchronization of other copies. The common implementation of
merge remains a language primitive in both versions.

## Haskell control retained from the current guide

```haskell
data Size = Size { width :: Int, height :: Int, depth :: Int }

recordExample :: Size
recordExample = (Size 2 3 0) { height = 5, depth = 7 }
```
Haskell uses its built-in record update. Its Size already contains depth;
LMX's model composition can append a new field dynamically. This difference
was already part of the scenario and is retained. No special library that
knows RecordModel is hidden on the LMX side. The helper merely names
an existing ordinary composition operation.

Client sizes and the helper's size describe different accounting boundaries.
They are not summed into the competitive client metric. The helper is fully
shown here so that the choice is reviewable. No LMX runtime, Haskell compiler,
or performance benchmark was run for this revision.
