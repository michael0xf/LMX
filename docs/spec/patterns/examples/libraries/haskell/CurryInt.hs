module CurryInt (capture) where

capture :: (a -> b -> c) -> a -> b -> c
capture binary first = \second -> binary first second
