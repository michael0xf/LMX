module IntPipe (pipe, pipeIO) where

pipe :: Int -> [Int -> Int] -> Int
pipe value [] = value
pipe value (stage : rest) =
  let next = stage value
  in next `seq` pipe next rest

pipeIO :: Int -> [Int -> IO Int] -> IO Int
pipeIO value [] = pure value
pipeIO value (stage : rest) = do
  next <- stage value
  next `seq` pipeIO next rest
