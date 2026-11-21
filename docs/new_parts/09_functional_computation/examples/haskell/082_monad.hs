module MonadExample where
import MaybeInt (MaybeInt, unit, none, bind)

half :: Int -> MaybeInt
half x = if even x then unit (x `div` 2) else none

run :: Int -> MaybeInt
run x = (unit x `bind` half) `bind` half
