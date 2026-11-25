module H08 where

import Data.IORef (IORef, newIORef, readIORef, modifyIORef')

freeStep, ownStep :: IORef Int -> IO ()
freeStep place = modifyIORef' place (+3)
ownStep caller = readIORef caller >>= newIORef >>= freeStep

stateProbe :: (IORef Int -> IO ()) -> IO Int
stateProbe action = do
  caller <- newIORef 0
  action caller
  readIORef caller
