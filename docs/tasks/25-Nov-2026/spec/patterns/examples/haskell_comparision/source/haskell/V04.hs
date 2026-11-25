module V04 where

import Control.Exception (Exception, catch, throwIO)

data NoSample = NoSample deriving Show
instance Exception NoSample

unavailable, zero :: IO Int
unavailable = throwIO NoSample
zero = pure 0

check :: IO Int -> IO Int
check candidate = (candidate >> pure 0) `catch` (\NoSample -> pure 1)
