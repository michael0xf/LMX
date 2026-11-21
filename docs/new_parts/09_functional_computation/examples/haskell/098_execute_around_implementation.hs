module AroundInt (around) where
import Control.Exception (SomeException, catch, throwIO)

around :: IO r -> (r -> IO ()) -> (r -> IO Int) -> IO Int
around acquire release action = do
  resource <- acquire
  let failed :: SomeException -> IO Int
      failed err = release resource >> throwIO err
  value <- action resource `catch` failed
  release resource
  pure value
