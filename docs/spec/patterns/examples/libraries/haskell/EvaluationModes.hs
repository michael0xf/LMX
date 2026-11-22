module EvaluationModes (preparedTwice, rawTwice) where

preparedTwice :: Int -> Int
preparedTwice value = value + value

rawTwice :: IO Int -> IO Int
rawTwice action = do
  first <- action
  second <- action
  pure (first + second)
