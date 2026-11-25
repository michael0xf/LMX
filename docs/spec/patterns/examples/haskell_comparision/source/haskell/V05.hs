module V05 where

import Prelude hiding (reads)
import Data.IORef (IORef, newIORef, readIORef, modifyIORef')

data State = State
  { commanded :: Int, sensed :: Int, writes :: Int, reads :: Int, trace :: Int }
  deriving (Eq, Show)
data Device = Device { set :: Int -> IO Int, observe :: IO Int }

makeDevice :: Int -> IO (Device, IORef State)
makeDevice fault = do
  state <- newIORef (State 0 0 0 0 0)
  let mark event = modifyIORef' state (\s -> s { trace = trace s * 10 + event })
      setCommand command = do
        modifyIORef' state (\s -> s { commanded = command, writes = writes s + 1,
          sensed = case fault of { 0 -> command; 1 -> 0; 2 -> 1; _ -> sensed s } })
        mark command
        pure 1
      readSensor = do
        modifyIORef' state (\s -> s { reads = reads s + 1 })
        mark 2
        sensed <$> readIORef state
  pure (Device setCommand readSensor, state)

cycleDevice :: Device -> Int -> IO Bool
cycleDevice candidate command = do
  ack <- set candidate command
  seen <- observe candidate
  pure (ack == 1 && seen == command)

check :: Device -> IO Bool
check candidate = do
  on <- cycleDevice candidate 1
  off <- cycleDevice candidate 0
  pure (on && off)
