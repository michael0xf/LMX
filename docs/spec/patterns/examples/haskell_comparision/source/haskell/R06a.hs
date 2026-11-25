module R06a where

import Data.IORef (newIORef, readIORef, modifyIORef')
import GraphCopy (Node(..), copyGraph)

example :: IO (Int, Bool, Bool)
example = do
  shared <- newIORef (Node 7 [])
  pair <- newIORef (Node 0 [shared,shared])
  copied <- copyGraph pair
  Node _ [left,right] <- readIORef copied
  modifyIORef' left (\(Node _ links) -> Node 21 links)
  Node rightValue _ <- readIORef right
  Node originalValue _ <- readIORef shared
  pure (rightValue * 100 + originalValue, left == right, left /= shared)
