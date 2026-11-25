module H05 where

import Data.IORef (IORef, newIORef, readIORef, writeIORef)

addIn :: IORef Int -> Int -> IO Int
addIn environment x = (+x) <$> readIORef environment

example :: IO (Int, Int, Int)
example = do
  source <- newIORef 5
  copied <- readIORef source >>= newIORef
  writeIORef source 8
  caller <- newIORef 25
  dynamic <- addIn caller 1
  lexical <- addIn copied 1
  sourceAfter <- readIORef source
  pure (dynamic, lexical, sourceAfter)
