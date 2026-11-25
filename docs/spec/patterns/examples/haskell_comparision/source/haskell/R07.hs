module R07 where

data Expr = Number Int | Variable | Add Expr Expr

eval :: Int -> Expr -> Int
eval _ (Number n) = n
eval x Variable = x
eval x (Add a b) = eval x a + eval x b

tree :: Expr
tree = Add (Add Variable (Number 3)) Variable

example :: Int
example = eval 2 tree + eval 5 tree
