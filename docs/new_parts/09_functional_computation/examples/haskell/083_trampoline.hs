module TrampolineExample where

data Bounce a = Done a | More (() -> Bounce a)

run :: Bounce a -> a
run (Done value) = value
run (More next) = run (next ())

evenStep, oddStep :: Int -> Bounce Bool
evenStep 0 = Done True
evenStep n = More (\() -> oddStep (n - 1))
oddStep 0 = Done False
oddStep n = More (\() -> evenStep (n - 1))

demo :: Bool
demo = run (evenStep 100001)
