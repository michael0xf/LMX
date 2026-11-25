module R04 where

import Data.IORef (newIORef, readIORef, writeIORef, modifyIORef')

changeLocal :: IO Int -> IO Int
changeLocal initializer = do
  local <- initializer >>= newIORef
  seen <- readIORef local
  writeIORef local 99
  pure seen

example :: IO ((Int, Int), (Int, Int))
example = do
  calls <- newIORef 0
  let next = modifyIORef' calls (+1) >> ((40+) <$> readIORef calls)
  first <- changeLocal next
  second <- changeLocal next
  twice <- readIORef calls
  writeIORef calls 0
  i <- next >>= newIORef
  modifyIORef' i (+3)
  explicit <- readIORef i
  once <- readIORef calls
  pure ((first * 100 + second, twice), (explicit, once))
