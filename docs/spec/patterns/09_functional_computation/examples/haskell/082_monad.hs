module MonadExample where

half :: Int -> Maybe Int
half x = if even x then Just (x `div` 2) else Nothing

run :: Int -> Maybe Int
run x = Just x >>= half >>= half
