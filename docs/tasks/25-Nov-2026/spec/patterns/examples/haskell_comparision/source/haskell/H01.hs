module H01 where

import Data.IORef (newIORef, readIORef, writeIORef)

example :: IO Int
example = do
  chosen <- newIORef ((*2) :: Int -> Int)
  firstOperation <- readIORef chosen
  let first = firstOperation 7
  writeIORef chosen (+1)
  secondOperation <- readIORef chosen
  pure (first * 100 + secondOperation 7)
