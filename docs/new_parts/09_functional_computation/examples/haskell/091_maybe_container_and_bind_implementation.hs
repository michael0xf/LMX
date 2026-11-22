module MaybeValue (MaybeValue(..), some, none, bind) where

data MaybeValue a = Absent | Present a deriving (Eq, Show)

some :: a -> MaybeValue a
some = Present

none :: MaybeValue a
none = Absent

infixl 1 `bind`
bind :: MaybeValue a -> (a -> MaybeValue b) -> MaybeValue b
bind Absent _ = Absent
bind (Present value) next = next value
