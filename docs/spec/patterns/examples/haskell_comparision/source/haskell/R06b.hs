module R06b where

import Data.IORef (newIORef, readIORef, writeIORef, modifyIORef')
import GraphCopy (Node(..), copyGraph)

example :: IO (Int, Bool, Bool, Int)
example = do
  ring <- newIORef (Node 3 [])
  writeIORef ring (Node 3 [ring])
  copied <- copyGraph ring
  Node snapshotValue [self] <- readIORef copied
  modifyIORef' self (\(Node _ links) -> Node 8 links)
  Node value _ <- readIORef copied
  Node original _ <- readIORef ring
  pure (value * 10 + original, self == copied, copied /= ring, snapshotValue)
