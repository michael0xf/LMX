module CurryingExample where
import Partial (partial)

add :: Int -> Int -> Int
add first second = first + second

demo :: Int
demo = let add5 = partial add 5
           add100 = partial add 100
       in add5 1 * 1000000 + add100 1 * 1000 + add5 1
