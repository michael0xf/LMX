module TrampolineExample where
import Bounce (Bounce, done, more, run)

evenStep, oddStep :: Int -> Bounce Bool
evenStep 0 = done True
evenStep n = more (\() -> oddStep (n - 1))
oddStep 0 = done False
oddStep n = more (\() -> evenStep (n - 1))

parity :: Int -> Bool
parity n = run (evenStep n)
