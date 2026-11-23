-- Comparison implementation only; usage clients import monad-loops whileJust_.
module StepIterator (Step(..), iterateUntilStop, whileJust) where

data Step a = Yield a | Stop

-- This loop is polymorphic in both the yielded value and the effect carrier.
-- Stop ends only the source; exceptions from source/body propagate unchanged.
iterateUntilStop :: Monad m => m (Step a) -> (a -> m b) -> m ()
iterateUntilStop next body = go
  where
    go = do
      step <- next
      case step of
        Stop -> pure ()
        Yield value -> body value >> go

-- Same loop with the real library's Maybe protocol, shown for direct comparison.
whileJust :: Monad m => m (Maybe a) -> (a -> m b) -> m ()
whileJust next body = iterateUntilStop (convert <$> next) body
  where
    convert Nothing = Stop
    convert (Just value) = Yield value
