module StepIterator (Step(..), iterateUntilStop) where

data Step a = Yield a | Stop

iterateUntilStop :: IO (Step a) -> (a -> IO ()) -> IO ()
iterateUntilStop next body = do
  step <- next
  case step of
    Stop -> pure ()
    Yield value -> do
      body value
      iterateUntilStop next body
