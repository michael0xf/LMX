module M05 where

import Control.Concurrent.Chan (Chan, readChan)
import Data.IORef (IORef, writeIORef)

set :: IORef Int -> Int -> IO ()
set = writeIORef

lampLoop :: Chan (Maybe Int) -> IORef Int -> IO ()
lampLoop inbox state = do
  request <- readChan inbox
  case request of
    Just command -> set state command >> lampLoop inbox state
    Nothing -> pure ()
