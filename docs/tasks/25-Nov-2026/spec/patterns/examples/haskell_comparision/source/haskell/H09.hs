module H09 where

import Control.Exception (Exception, catch, throwIO)
import Data.IORef (newIORef, readIORef, writeIORef, modifyIORef')

data Stop = Stop deriving Show
instance Exception Stop

iterateUntil :: IO a -> (a -> IO ()) -> IO ()
iterateUntil next body = do
  item <- (Just <$> next) `catch` (\Stop -> pure Nothing)
  case item of
    Nothing -> pure ()
    Just value -> body value >> iterateUntil next body

example :: IO Int
example = do
  position <- newIORef 0
  total <- newIORef 0
  let next = do
        value <- readIORef position
        if value >= 3 then throwIO Stop else do
          writeIORef position (value + 1)
          pure (value + 1)
  iterateUntil next (\item -> modifyIORef' total (+ (item * 2)))
  readIORef total
