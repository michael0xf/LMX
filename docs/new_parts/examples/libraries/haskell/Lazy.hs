module Lazy (lazyIO) where

import Control.Exception (evaluate, mask, onException)
import Data.IORef (newIORef, readIORef, writeIORef)

data LazyState a = Cold | Busy | Ready a

lazyIO :: IO a -> IO (IO a)
lazyIO action = do
  cell <- newIORef Cold
  pure $ mask $ \restore -> do
    state <- readIORef cell
    case state of
      Ready value -> pure value
      Busy -> ioError (userError "LazyCycle")
      Cold -> do
        writeIORef cell Busy
        value <- restore (action >>= evaluate) `onException` writeIORef cell Cold
        writeIORef cell (Ready value)
        pure value
