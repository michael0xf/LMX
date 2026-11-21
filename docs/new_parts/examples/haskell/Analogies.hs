-- Companion examples for LMX_examples_and_analogies.ru.md.
-- Expected results are asserted here; this file is not an execution receipt.
-- Sources for the library interfaces:
-- https://www.haskell.org/onlinereport/haskell2010/
-- https://downloads.haskell.org/ghc/9.6.1/docs/libraries/base-4.18.0.0/Control-Concurrent.html
-- https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html
module Main where

import Control.Concurrent (MVar, forkIO, newEmptyMVar, putMVar, takeMVar)
import Control.Concurrent.Chan (Chan, newChan, readChan, writeChan)
import Control.Monad (unless, void)
import Data.Array (Array, listArray, (!), (//), elems)
import Data.IORef (newIORef, readIORef, modifyIORef')

assertEq :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEq name expected actual =
  unless (expected == actual) $
    error (name ++ ": expected " ++ show expected ++ ", got " ++ show actual)

apply :: (Int -> Int) -> Int -> Int
apply f x = f x

makeAdder :: Int -> Int -> Int
makeAdder n x = n + x

closureExample :: (Int, Int, Int)
closureExample =
  let add5 = makeAdder 5
      add100 = makeAdder 100
  in (add5 1, add100 1, add5 1)

addWithDefault :: Int -> Maybe Int -> Int
addWithDefault x supplied = x + maybe 5 id supplied

data Env = Env { dynamicY :: Int }

dynamicAdd :: Env -> Int -> Int
dynamicAdd env x = x + dynamicY env

lexicalAdd :: Env -> Int -> Int
lexicalAdd captured x = x + dynamicY captured

appendOne :: String -> String
appendOne s = s ++ "1"

adapted :: Int -> Int
adapted = read . appendOne . show

data Size = Size { width :: Int, height :: Int, depth :: Int }
  deriving (Eq, Show)

data Expr = Number Int | Variable | Add Expr Expr
  deriving (Eq, Show, Read)

evalExpr :: Int -> Expr -> Int
evalExpr _ (Number n) = n
evalExpr x Variable = x
evalExpr x (Add a b) = evalExpr x a + evalExpr x b

tree :: Expr
tree = Add (Add Variable (Number 3)) Variable

data Event = Sample Int | Finished

eventValue :: Event -> Int
eventValue (Sample x) = x
eventValue Finished = 0

accepts :: String -> Bool
accepts [a,b,'-',c,d] = all upper [a,b] && all digit [c,d]
  where
    upper x = x >= 'A' && x <= 'Z'
    digit x = x >= '0' && x <= '9'
accepts _ = False

-- Effects are executed explicitly. Reusing the IO action is not reusing its result.
preparedAndRaw :: IO ((Int, Int), (Int, Int))
preparedAndRaw = do
  preparedCount <- newIORef (0 :: Int)
  let preparedNext = modifyIORef' preparedCount (+1) >> readIORef preparedCount
  value <- preparedNext
  count1 <- readIORef preparedCount
  rawCount <- newIORef (0 :: Int)
  let rawNext = modifyIORef' rawCount (+1) >> readIORef rawCount
  first <- rawNext
  second <- rawNext
  count2 <- readIORef rawCount
  pure ((value + value, count1), (first + second, count2))

data SampleVariant = Good | Biased | ReadsTwice

sample :: SampleVariant -> Int -> IO Int -> IO Int
sample variant gain readSample = case variant of
  Good -> (* gain) <$> readSample
  Biased -> (\x -> x * gain + 1) <$> readSample
  ReadsTwice -> do
    _ <- readSample
    (* gain) <$> readSample

samplingCheck :: SampleVariant -> IO (Bool, Int)
samplingCheck variant = do
  calls <- newIORef (0 :: Int)
  let fixedRead = modifyIORef' calls (+1) >> pure 7
  result <- sample variant 4 fixedRead
  count <- readIORef calls
  pure (result == 28 && count == 1, count)

-- One owner loop updates an immutable numeric state and replies to explicit requests.
-- This is a library-level analogue, not an implementation of the entire LMX protocol.
data CounterRequest = AddBy Int (MVar Int) | ReadValue (MVar Int) | Stop (MVar ())

counterLoop :: Chan CounterRequest -> Int -> IO ()
counterLoop inbox value = do
  request <- readChan inbox
  case request of
    AddBy delta reply -> do
      let next = value + delta
      next `seq` putMVar reply next
      counterLoop inbox next
    ReadValue reply -> do
      putMVar reply value
      counterLoop inbox value
    Stop ack -> putMVar ack ()

counterExample :: IO Int
counterExample = do
  inbox <- newChan
  void (forkIO (counterLoop inbox 0))
  reply4 <- newEmptyMVar
  reply9 <- newEmptyMVar
  void (forkIO (writeChan inbox (AddBy 4 reply4)))
  void (forkIO (writeChan inbox (AddBy 9 reply9)))
  _ <- takeMVar reply4
  _ <- takeMVar reply9
  finalReply <- newEmptyMVar
  writeChan inbox (ReadValue finalReply)
  finalValue <- takeMVar finalReply
  stopped <- newEmptyMVar
  writeChan inbox (Stop stopped)
  takeMVar stopped
  pure finalValue

-- Evaluate each source exactly once, then fan its value out to all three sinks.
fanOutExample :: IO (Int, [Int])
fanOutExample = do
  sourceCalls <- newIORef (0 :: Int)
  sinks <- mapM (const (newIORef (0 :: Int))) [1..3 :: Int]
  let source = modifyIORef' sourceCalls (+1) >> pure (7 :: Int)
      deliver value = mapM_ (\sink -> modifyIORef' sink (+ value)) sinks
  first <- source
  deliver first
  second <- source
  deliver second
  calls <- readIORef sourceCalls
  receivedSums <- mapM readIORef sinks
  pure (calls, receivedSums)

main :: IO ()
main = do
  assertEq "H01 apply" 14 (apply (*2) 7)
  assertEq "H03 closure" (6,101,6) closureExample
  assertEq "H04 explicit default model" [6,26,1,6]
    (map (addWithDefault 1) [Nothing, Just 25, Just 0, Nothing])
  assertEq "H05 explicit environment model" (26,6)
    (dynamicAdd (Env 25) 1, lexicalAdd (Env 5) 1)
  assertEq "H06 composition" (9,10) (((+1) . (*2)) (4 :: Int), ((*2) . (+1)) (4 :: Int))
  preparedAndRaw >>= assertEq "H07 values/actions" ((2,1),(3,2))
  assertEq "H09 finite prefix" (12 :: Int) (sum (take 3 (map (*2) [1..])))
  assertEq "H11 conversion route" 101 (adapted 10)
  assertEq "H12 variants" (7,0) (eventValue (Sample 7), eventValue Finished)
  assertEq "R01 known record update" (Size 2 5 7)
    ((Size 2 3 0) {height = 5, depth = 7})
  assertEq "R07 explicit syntax tree" 20 (evalExpr 2 tree + evalExpr 5 tree)
  assertEq "R08 AST serialization" tree (read (show tree))
  let original = listArray (0,2) [10,20,30] :: Array Int Int
      changed = original // [(1,27)]
  assertEq "A02 immutable array update" (20,27,[10,27,30])
    (original ! 1, changed ! 1, elems changed)
  assertEq "A05 map" [2,4,6,8 :: Int] (map (*2) [1,2,3,4])
  assertEq "A05 filter" [2,4 :: Int] (filter even [1,2,3,4])
  assertEq "A05 reduce" (10 :: Int) (foldl (+) 0 [1,2,3,4])
  assertEq "A05 inclusive scan" [1,3,6,10 :: Int] (tail (scanl (+) 0 [1,2,3,4]))
  assertEq "A05 elementwise/dot" ([4,10,18],32 :: Int)
    (zipWith (*) [1,2,3] [4,5,6], sum (zipWith (*) [1,2,3] [4,5,6]))
  assertEq "V02 whole text" [True,False,False,False]
    (map accepts ["AB-09", "AB-090", "AB-0X", ['A','B','\0','0','9']])
  samplingCheck Good >>= assertEq "V03 good" (True,1)
  samplingCheck Biased >>= assertEq "V03 bias" (False,1)
  samplingCheck ReadsTwice >>= assertEq "V03 duplicate read" (False,2)
  counterExample >>= assertEq "M01 owner" 13
  fanOutExample >>= assertEq "M02 evaluate then fan out" (2,[14,14,14])
  putStrLn "All Haskell companion assertions passed."
