module H03 where

add :: Int -> Int -> Int
add first second = first + second

example :: (Int, Int, Int)
example = let add5 = add 5
              add100 = add 100
          in (add5 1, add100 1, add5 1)
