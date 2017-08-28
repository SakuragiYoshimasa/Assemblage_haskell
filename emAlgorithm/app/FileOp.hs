module FileOp (csv2vec) where

import Numeric.LinearAlgebra
import VecOp (arrToVec)
import Params (Xvec)

split::(a->Bool)->[a]->([a],[a])
split _ [] = ([],[])
split p (x:xs)
      | p x       = ([],xs)
      | otherwise = (x:ys,zs)
      where (ys,zs) = split p xs

csv2list::String->[Double]
csv2list [] = []
csv2list line = (read first::Double):csv2list other
  where (first,other) = split (\x->x==',') line

csv2vec :: String -> Xvec
csv2vec = arrToVec . csv2list
