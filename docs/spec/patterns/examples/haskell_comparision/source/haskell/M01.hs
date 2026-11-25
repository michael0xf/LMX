module M01 where

import Control.Concurrent (MVar, putMVar)
import Control.Concurrent.Chan (Chan, readChan)

data CounterRequest = AddBy Int (MVar Int) | ReadValue (MVar Int) | Stop (MVar ())

counterLoop :: Chan CounterRequest -> Int -> IO ()
counterLoop inbox value = do
  request <- readChan inbox
  case request of
    AddBy delta reply -> do
      let next = value + delta
      next `seq` putMVar reply next
      counterLoop inbox next
    ReadValue reply -> putMVar reply value >> counterLoop inbox value
    Stop ack -> putMVar ack ()
