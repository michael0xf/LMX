module IntApply (apply) where

apply :: (Int -> Int) -> Int -> Int
apply operation value = operation value
