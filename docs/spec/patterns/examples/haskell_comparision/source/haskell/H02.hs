module H02 where

data Arguments = Arguments { a :: Int, b :: Int }

encode :: Int -> Int -> Int
encode bValue aValue = bValue * 10 + aValue

bySignatureNames, byCandidateNames :: Arguments -> Int
bySignatureNames args = encode (a args) (b args)
byCandidateNames args = encode (b args) (a args)

example :: Int
example = let args = Arguments { a = 2, b = 7 }
          in bySignatureNames args * 100 + byCandidateNames args
