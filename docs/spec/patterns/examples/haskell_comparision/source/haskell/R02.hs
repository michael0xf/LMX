module R02 where

data Pair = Pair { first :: Int, second :: Int }

fieldStream :: Pair -> [Int]
fieldStream pair = [first pair, second pair]

example :: Maybe Int
example = case fieldStream (Pair 2 7) of
  [a,b] -> Just (a * 10 + b)
  _ -> Nothing
