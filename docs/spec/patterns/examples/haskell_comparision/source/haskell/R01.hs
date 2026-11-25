module R01 where

import qualified Data.Map.Strict as Map

model, patch, extended :: Map.Map String Int
model = Map.fromList [("width",2),("height",3)]
patch = Map.fromList [("height",5),("depth",7)]
extended = Map.union patch model

example :: Int
example = extended Map.! "width" * 100
        + extended Map.! "height" * 10 + extended Map.! "depth"
