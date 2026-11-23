{-# LANGUAGE ScopedTypeVariables #-}
module Around (bracket) where
import Control.Exception (SomeException, mask, throwIO, try)

bracket :: forall resource released result.
           IO resource -> (resource -> IO released) ->
           (resource -> IO result) -> IO result
bracket acquire release action = mask $ \restore -> do
  resource <- acquire
  outcome <- try (restore (action resource)) :: IO (Either SomeException result)
  _ <- release resource
  either throwIO pure outcome
