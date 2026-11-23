module Around (bracket) where
import Control.Exception (SomeException, catch, throwIO)

bracket :: IO r -> (r -> IO ()) -> (r -> IO a) -> IO a
bracket acquire release action = do
  resource <- acquire
  let failed :: SomeException -> IO a
      failed err = release resource >> throwIO err
  value <- action resource `catch` failed
  release resource
  pure value
