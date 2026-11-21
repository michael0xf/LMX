module CurryingExample where

add :: Int -> Int -> Int
add saved x = saved + x

demo :: Int
demo = let add5 = add 5
           add100 = add 100
       in add5 1 * 1000000 + add100 1 * 1000 + add5 1
