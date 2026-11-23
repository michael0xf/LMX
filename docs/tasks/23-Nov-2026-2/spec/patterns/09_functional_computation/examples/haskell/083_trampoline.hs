module TrampolineExample where
import Control.Monad.Free (Free(..), iter)
import Data.Functor.Identity (Identity(..))

evenStep, oddStep :: Int -> Free Identity Bool
evenStep 0 = Pure True
evenStep n = Free (Identity (oddStep (n - 1)))
oddStep 0 = Pure False
oddStep n = Free (Identity (evenStep (n - 1)))

parity :: Int -> Bool
parity = iter runIdentity . evenStep
