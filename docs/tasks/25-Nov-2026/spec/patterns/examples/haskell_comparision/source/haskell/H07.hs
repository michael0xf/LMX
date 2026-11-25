module H07 where

import Control.Monad (replicateM)
import Data.IORef (newIORef, modifyIORef', readIORef)

example :: IO ((Int, Int, Int), (Int, Int, Int))
example = do
  preparedCount <- newIORef 0
  let preparedNext = modifyIORef' preparedCount (+1) >> readIORef preparedCount
  first <- (\value -> value + value) <$> preparedNext
  second <- (\value -> value + value) <$> preparedNext
  preparedCalls <- readIORef preparedCount
  rawCount <- newIORef 0
  let rawNext = modifyIORef' rawCount (+1) >> readIORef rawCount
  third <- sum <$> replicateM 2 rawNext
  fourth <- sum <$> replicateM 2 rawNext
  rawCalls <- readIORef rawCount
  pure ((first, second, preparedCalls), (third, fourth, rawCalls))
