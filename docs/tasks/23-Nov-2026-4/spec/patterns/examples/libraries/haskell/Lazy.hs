-- Comparison implementation only: one owning thread, like one LMX Message.
module Lazy (lazyIO, onceIO, LazyFailure(..)) where

import Control.Concurrent (myThreadId)
import Control.Exception (Exception, evaluate, mask, onException, throwIO)
import Data.IORef (newIORef, readIORef, writeIORef)

data LazyFailure = LazyCycle | LazyForeignOwner deriving (Eq, Show)
instance Exception LazyFailure

data LazyState a = Cold | Busy | Ready a

-- Cache the first successful result, independently of later input values.
-- input can be any product/record/argument-vector type; output is unrestricted.
-- A failed call leaves the cache Cold, so a later call may use different input.
-- The action and result are evaluated only on a cache miss, to ordinary WHNF.
onceIO :: (input -> IO a) -> IO (input -> IO a)
onceIO action = do
  owner <- myThreadId
  cell <- newIORef Cold
  pure $ \input -> mask $ \restore -> do
    caller <- myThreadId
    if caller /= owner then throwIO LazyForeignOwner else pure ()
    state <- readIORef cell
    case state of
      Ready value -> pure value
      Busy -> throwIO LazyCycle
      Cold -> do
        writeIORef cell Busy
        value <- restore (action input >>= evaluate) `onException` writeIORef cell Cold
        writeIORef cell (Ready value)
        pure value

-- Allocation does not run the action. Ordinary async exceptions are masked
-- during the state bookkeeping and restored during the action; a failure resets
-- Cold and escapes unchanged. Foreign owners must send a request to this owner.
lazyIO :: IO a -> IO (IO a)
lazyIO action = do
  cached <- onceIO (const action)
  pure (cached ())
