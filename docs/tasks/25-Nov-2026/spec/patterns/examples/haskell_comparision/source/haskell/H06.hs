module H06 where

example :: (Int, Int)
example = (((+1) . (*2)) 4, ((*2) . (+1)) 4)
