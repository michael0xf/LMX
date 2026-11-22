module V02TicketCode (accepts) where

import CharacterRange (between)

accepts :: String -> Bool
accepts [a,b,'-',c,d] =
  all (\x -> x `between` ('A','Z')) [a,b] &&
  all (\x -> x `between` ('0','9')) [c,d]
accepts _ = False
