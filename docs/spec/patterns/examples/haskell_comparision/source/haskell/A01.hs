module A01 where

import Data.IORef (newIORef, readIORef, modifyIORef')

data Field = Field { name :: String, value :: Int } deriving (Eq, Show)

replaceAt :: Int -> a -> [a] -> [a]
replaceAt index replacement xs = take index xs ++ [replacement] ++ drop (index+1) xs

example :: IO (Int, [String])
example = do
  slots <- newIORef [Field "x" 1, Field "y" 2]
  let same = slots
      replacement = [Field "z" 9]
  modifyIORef' same (replaceAt 1 (head replacement))
  fields <- readIORef slots
  let Just z = lookup "z" [(name field,value field) | field <- fields]
  pure (length fields * 100 + z, map name fields)
