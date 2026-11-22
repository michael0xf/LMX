module Bounce (Bounce, done, more, run) where

data Bounce a = Done a | More (() -> Bounce a)

done :: a -> Bounce a
done = Done

more :: (() -> Bounce a) -> Bounce a
more = More

run :: Bounce a -> a
run (Done answer) = answer
run (More next) = run (next ())
