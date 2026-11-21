module BounceBool (Bounce, done, more, run) where

data Bounce = Done Bool | More (Int -> Bounce) Int

done :: Bool -> Bounce
done = Done

more :: (Int -> Bounce) -> Int -> Bounce
more = More

run :: Bounce -> Bool
run (Done answer) = answer
run (More next argument) = run (next argument)
