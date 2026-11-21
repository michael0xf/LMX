module ExecuteAroundExample where

import Control.Exception (bracket)

around :: IO r -> (r -> IO ()) -> (r -> IO Int) -> IO Int
around acquire release action = bracket acquire release action
