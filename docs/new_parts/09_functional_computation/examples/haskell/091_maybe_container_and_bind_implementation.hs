module MaybeInt (MaybeInt(..), unit, none, bind) where

data MaybeInt = Absent | Present Int deriving (Eq, Show)

unit :: Int -> MaybeInt
unit = Present

none :: MaybeInt
none = Absent

infixl 1 `bind`
bind :: MaybeInt -> (Int -> MaybeInt) -> MaybeInt
bind Absent _ = Absent
bind (Present value) next = next value
