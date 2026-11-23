module CurryingExample where

add :: Int -> Int -> Int
add first second = first + second

demo :: Int
demo = let add5 = add 5
           add100 = add 100
           saved = 1000
       in add5 1 * 1000000 + add100 1 * 1000 + add5 1
