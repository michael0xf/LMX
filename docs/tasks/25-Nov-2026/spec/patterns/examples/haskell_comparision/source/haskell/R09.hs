module R09 where

import Data.IORef (IORef, newIORef, readIORef, writeIORef)

data Payload a = Uninitialized | Ready a deriving (Eq, Show)

localWrite, graphWrite :: IORef (Payload Int) -> IO Int
localWrite source = do
  local <- readIORef source >>= newIORef
  writeIORef local (Ready 5)
  Ready value <- readIORef local
  pure value
graphWrite source = do
  writeIORef source (Ready 5)
  Ready value <- readIORef source
  pure value

readyNumber :: Payload Int
readyNumber = Ready 0

readyReference :: Payload (Maybe Int)
readyReference = Ready Nothing
