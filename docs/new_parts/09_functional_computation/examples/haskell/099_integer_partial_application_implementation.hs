module Partial (partial) where

partial :: (a -> b -> r) -> a -> (b -> r)
partial binary first = \second -> binary first second
