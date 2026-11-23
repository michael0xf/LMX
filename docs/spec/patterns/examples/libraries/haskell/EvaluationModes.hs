-- Comparison fixtures for evaluation count; clients use native do / replicateM.
module EvaluationModes (preparedTwice, rawTwice) where

preparedTwice :: Num a => a -> a
preparedTwice value = value + value

rawTwice :: (Monad m, Num a) => m a -> m a
rawTwice action = do
  first <- action
  second <- action
  pure (first + second)
