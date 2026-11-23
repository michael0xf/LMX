-- Comparison implementation only. Clients import Data.Ix.inRange.
module CharacterRange (between) where

-- Inclusive endpoints; reversed intervals and unordered floating values are false.
-- A lawful Ord instance supplies the ordering; neither endpoint is converted.
between :: Ord a => a -> (a, a) -> Bool
between value (lower, upper) = lower <= value && value <= upper
