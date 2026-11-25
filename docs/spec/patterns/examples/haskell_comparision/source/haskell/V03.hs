module V03 where

import Data.IORef (newIORef, readIORef, modifyIORef')

type Candidate = Int -> IO Int -> IO Int

sample, biased, readsTwice :: Candidate
sample gain readSample = (*gain) <$> readSample
biased gain readSample = (+1) <$> sample gain readSample
readsTwice gain readSample = readSample >> sample gain readSample

check :: Candidate -> IO (Bool, Int)
check candidate = do
  calls <- newIORef 0
  let fixedRead = modifyIORef' calls (+1) >> pure 7
  result <- candidate 4 fixedRead
  count <- readIORef calls
  pure (result == 28 && count == 1, count)
