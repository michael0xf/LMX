module CurryInt (capture) where

capture :: (Int -> Int -> Int) -> Int -> (Int -> Int)
capture binary first = \second -> binary first second
