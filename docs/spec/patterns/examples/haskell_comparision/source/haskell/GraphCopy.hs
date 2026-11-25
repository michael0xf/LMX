module GraphCopy (Node(..), copyGraph) where

import Data.IORef (IORef, newIORef, readIORef, writeIORef, modifyIORef')

data Node a = Node a [IORef (Node a)]

copyGraph :: IORef (Node a) -> IO (IORef (Node a))
copyGraph root = do
  memo <- newIORef []
  let visit source = do
        seen <- readIORef memo
        case lookup source seen of
          Just target -> pure target
          Nothing -> do
            Node value children <- readIORef source
            target <- newIORef (Node value [])
            modifyIORef' memo ((source,target):)
            copiedChildren <- mapM visit children
            writeIORef target (Node value copiedChildren)
            pure target
  visit root
