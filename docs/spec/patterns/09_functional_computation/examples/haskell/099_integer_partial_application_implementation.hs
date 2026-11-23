{-# LANGUAGE DataKinds, GADTs, KindSignatures, TypeFamilies, TypeOperators #-}
module Partial (Args(..), Callable(..), Append, appendArgs, partial) where
import Data.Kind (Type)

data Args (types :: [Type]) where
  Nil :: Args '[]
  (:&) :: value -> Args rest -> Args (value ': rest)
infixr 5 :&

type family Append prefix rest where
  Append '[] rest = rest
  Append (value ': prefix) rest = value ': Append prefix rest

appendArgs :: Args prefix -> Args rest -> Args (Append prefix rest)
appendArgs Nil rest = rest
appendArgs (value :& prefix) rest = value :& appendArgs prefix rest

newtype Callable inputs result = Callable { invoke :: Args inputs -> result }

partial :: Callable (Append prefix rest) result -> Args prefix -> Callable rest result
partial (Callable operation) prefix =
  Callable (\rest -> operation (appendArgs prefix rest))
