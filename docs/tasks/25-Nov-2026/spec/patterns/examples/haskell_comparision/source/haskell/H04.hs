module H04 where

addWithDefault :: Int -> Maybe Int -> Int
addWithDefault x supplied = x + maybe 5 id supplied

example :: [Int]
example = map (addWithDefault 1) [Nothing, Just 25, Just 0, Nothing]
