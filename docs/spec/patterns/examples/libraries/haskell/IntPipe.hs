module IntPipe (pipe, pipeIO, pipe2, pipeIO2) where

pipe :: a -> [a -> a] -> a
pipe value [] = value
pipe value (stage : rest) =
  let next = stage value
  in next `seq` pipe next rest

pipeIO :: a -> [a -> IO a] -> IO a
pipeIO value [] = pure value
pipeIO value (stage : rest) = do
  next <- stage value
  next `seq` pipeIO next rest

pipe2 :: (a -> b) -> (b -> c) -> a -> c
pipe2 first second = second . first

pipeIO2 :: (a -> IO b) -> (b -> IO c) -> a -> IO c
pipeIO2 first second input = first input >>= second
