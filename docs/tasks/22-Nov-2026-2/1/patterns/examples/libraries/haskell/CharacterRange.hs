module CharacterRange (between) where

between :: Char -> (Char, Char) -> Bool
between value (lower, upper) = lower <= value && value <= upper
