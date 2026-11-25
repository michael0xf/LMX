module R03 where

import Data.IORef (IORef, newIORef, readIORef, writeIORef)

data Provider = Provider { owner :: IORef Int, readValue :: IO Int }

makeProvider :: Int -> IO Provider
makeProvider value = do
  cell <- newIORef value
  pure (Provider cell (readIORef cell))

copyProvider :: Provider -> IO Provider
copyProvider provider = readValue provider >>= makeProvider

example :: IO (Int, Int, Int)
example = do
  provider <- makeProvider 7
  let imported = readValue provider
  original <- imported
  copied <- copyProvider provider
  writeIORef (owner copied) 12
  result <- readValue copied
  originalAfter <- readValue provider
  pure (original * 100 + result, originalAfter, result)
