module Main where

import Control.Concurrent (forkIO, newEmptyMVar, putMVar, takeMVar)
import Control.Concurrent.Chan (newChan, writeChan)
import Control.Exception (SomeException, try, throwIO)
import Control.Monad (unless, void)
import Data.IORef (newIORef, readIORef, writeIORef, modifyIORef')
import Data.List (sort)
import qualified Data.Map.Strict as Map
import qualified H01
import qualified H02
import qualified H03
import qualified H04
import qualified H05
import qualified H06
import qualified H07
import qualified H08
import qualified H09
import qualified R01
import qualified R02
import qualified R03
import qualified R04
import qualified R06a
import qualified R06b
import qualified R07
import qualified R09
import qualified A01
import qualified V02
import qualified V03
import qualified V04
import qualified V05
import qualified M01
import qualified M05

assertEq :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEq label expected actual = do
  unless (expected == actual) $
    error (label ++ ": expected " ++ show expected ++ ", got " ++ show actual)
  putStrLn ("PASS " ++ label)

iteratorFixture :: [Int] -> (Int -> Int) -> IO (Int, Int, Int)
iteratorFixture input observe = do
  remaining <- newIORef input
  steps <- newIORef 0
  bodies <- newIORef 0
  total <- newIORef 0
  let next = do
        modifyIORef' steps (+1)
        values <- readIORef remaining
        case values of
          [] -> throwIO H09.Stop
          item:rest -> writeIORef remaining rest >> pure item
      body item = do
        modifyIORef' bodies (+1)
        modifyIORef' total (+ observe item)
  H09.iterateUntil next body
  (,,) <$> readIORef total <*> readIORef steps <*> readIORef bodies

counterFixture :: IO (Int, [Int])
counterFixture = do
  inbox <- newChan
  void (forkIO (M01.counterLoop inbox 0))
  reply4 <- newEmptyMVar
  reply9 <- newEmptyMVar
  void (forkIO (writeChan inbox (M01.AddBy 4 reply4)))
  void (forkIO (writeChan inbox (M01.AddBy 9 reply9)))
  first <- takeMVar reply4
  second <- takeMVar reply9
  reply <- newEmptyMVar
  writeChan inbox (M01.ReadValue reply)
  final <- takeMVar reply
  stopped <- newEmptyMVar
  writeChan inbox (M01.Stop stopped)
  takeMVar stopped
  pure (final, sort [first,second])

lampFixture :: IO Int
lampFixture = do
  inbox <- newChan
  state <- newIORef 0
  finished <- newEmptyMVar
  let worker = try (M05.lampLoop inbox state) :: IO (Either SomeException ())
  void (forkIO (worker >>= putMVar finished))
  writeChan inbox (Just 1)
  writeChan inbox Nothing
  outcome <- takeMVar finished
  either throwIO pure outcome
  readIORef state

main :: IO ()
main = do
  H01.example >>= assertEq "H01 replaced callable" 1408
  assertEq "H02 positional and candidate names" 2772 H02.example
  assertEq "H03 independent prefixes" (6,101,6) H03.example
  assertEq "H03 original function unchanged" 9 (H03.add 2 7)
  assertEq "H04 absent/explicit/repeated defaults" [6,26,1,6] H04.example
  H05.example >>= assertEq "H05 environments and mutated source" (26,6,8)
  assertEq "H06 both composition orders" (9,10) H06.example
  H07.example >>= assertEq "H07 values and calls" ((2,4,2),(3,7,4))
  H08.stateProbe H08.ownStep >>= assertEq "H08 owned place" 0
  H08.stateProbe H08.freeStep >>= assertEq "H08 caller place" 3
  H09.example >>= assertEq "H09 sum" 12
  iteratorFixture [1,2,3] (*2) >>= assertEq "H09 iteration counts" (12,4,3)
  iteratorFixture [-2,0,4] (\x -> let item = x+3 in item+item)
    >>= assertEq "H09 zero and repeated reads" (22,4,3)
  stopped <- try (H09.iterateUntil (pure ()) (\_ -> throwIO H09.Stop))
    :: IO (Either H09.Stop ())
  assertEq "H09 body Stop propagates" True
    (case stopped of { Left H09.Stop -> True; Right () -> False })
  assertEq "R01 extension and overwrite" 257 R01.example
  assertEq "R01 source lacks depth" False (Map.member "depth" R01.model)
  assertEq "R01 source height unchanged" (Just 3) (Map.lookup "height" R01.model)
  assertEq "R01 patch unchanged" [("depth",7),("height",5)] (Map.toAscList R01.patch)
  assertEq "R02 field order and unpacking" (Just 27) R02.example
  R03.example >>= assertEq "R03 independent owners" (712,7,12)
  R04.example >>= assertEq "R04 reactivation and explicit initializer" ((4142,2),(44,1))
  R06a.example >>= assertEq "R06a sharing and fresh copy" (2107,True,True)
  R06b.example >>= assertEq "R06b cycle and snapshot" (83,True,True,3)
  assertEq "R07 retained expression" 20 R07.example
  assertEq "R07 first environment" 7 (R07.eval 2 R07.tree)
  assertEq "R07 second environment" 13 (R07.eval 5 R07.tree)
  source <- newIORef R09.Uninitialized
  R09.localWrite source >>= assertEq "R09 local result" 5
  readIORef source >>= assertEq "R09 local write keeps source uninitialized" R09.Uninitialized
  R09.graphWrite source >>= assertEq "R09 graph result" 5
  readIORef source >>= assertEq "R09 graph source replaced" (R09.Ready 5)
  assertEq "R09 zero is ready" (R09.Ready 0) R09.readyNumber
  assertEq "R09 null representation is ready" (R09.Ready Nothing) R09.readyReference
  assertEq "R09 absence differs from zero" False (R09.Uninitialized == R09.readyNumber)
  A01.example >>= assertEq "A01 shared slot and changed field name" (209,["x","z"])
  assertEq "V02 whole ASCII ticket code"
    [True,True,False,False,False,False,False,False,False,False,False]
    (map V02.accepts ["AB-09","QZ-70","","AB-9","AB-090","ab-09","AB-0X",
      "XAB-09Y",['A','B','\0','0','9'],"\x00c4\&B-09","AB-\x0660\&9"])
  V03.check V03.sample >>= assertEq "V03 good" (True,1)
  V03.check V03.biased >>= assertEq "V03 biased" (False,1)
  V03.check V03.readsTwice >>= assertEq "V03 duplicate read" (False,2)
  V03.check (\gain readSample -> (*gain) <$> readSample)
    >>= assertEq "V03 arbitrary candidate" (True,1)
  V04.check V04.unavailable >>= assertEq "V04 named NoSample" 1
  V04.check V04.zero >>= assertEq "V04 ordinary zero" 0
  anotherFailure <- try (V04.check (throwIO H09.Stop)) :: IO (Either H09.Stop Int)
  assertEq "V04 other exception propagates" True
    (case anotherFailure of { Left H09.Stop -> True; Right _ -> False })
  mapM_ (\(fault,expected,sensed) -> do
    (device,state) <- V05.makeDevice fault
    V05.check device >>= assertEq ("V05 result fault=" ++ show fault) expected
    readIORef state >>= assertEq ("V05 all effects fault=" ++ show fault)
      (V05.State 0 sensed 2 2 1202)) [(0,True,0),(1,False,0),(2,False,1)]
  (final,replies) <- counterFixture
  assertEq "M01 serialized final value" 13 final
  assertEq "M01 two legal intermediate replies" True
    (replies == [4,13] || replies == [9,13])
  lampFixture >>= assertEq "M05 state after no-reply command" 1
  putStrLn "All 24 comparison scenarios passed."
