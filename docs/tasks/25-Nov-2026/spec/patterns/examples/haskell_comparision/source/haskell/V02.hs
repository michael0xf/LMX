module V02 where

import Data.Ix (inRange)

accepts :: String -> Bool
accepts [a,b,'-',c,d] =
  all (inRange ('A','Z')) [a,b]
    && all (inRange ('0','9')) [c,d]
accepts _ = False
