module MonadExample where
import MaybeValue (MaybeValue, some, none, bind)

half :: Int -> MaybeValue Int
half x = if even x then some (x `div` 2) else none

run :: Int -> MaybeValue Int
run x = (some x `bind` half) `bind` half
