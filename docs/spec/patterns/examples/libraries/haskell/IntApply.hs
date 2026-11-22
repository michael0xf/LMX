module IntApply (apply) where

apply :: (a -> b) -> a -> b
apply operation value = operation value
