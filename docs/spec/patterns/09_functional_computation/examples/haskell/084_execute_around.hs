module ExecuteAroundExample where
import Control.Exception (Exception, bracket, throwIO, try)
import Data.IORef (newIORef, modifyIORef', readIORef)

newtype Resource = Resource Int
data ResourceFailure = ResourceFailure deriving Show
instance Exception ResourceFailure

run :: Int -> IO Int
run mode = do
  events <- newIORef 0
  let note n = modifyIORef' events (\x -> x * 10 + n)
      failure = throwIO ResourceFailure
      acquire = do
        note 1
        if mode == 2 then failure else pure (Resource 42)
      action (Resource value) = do
        note 2
        if mode == 1 then failure else pure value
      release _ = note 3
  result <- try (bracket acquire release action) :: IO (Either ResourceFailure Int)
  logValue <- readIORef events
  pure (either (const (-logValue)) (\value -> value * 1000 + logValue) result)
