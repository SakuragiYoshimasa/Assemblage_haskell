module Main where

import Prelude hiding (readFile)
import System.IO.Strict (readFile)
import System.Environment (getArgs)
import Numeric.LinearAlgebra
import FileOp (csv2vec)
import VecOp (Parameters, Values, _G, _X, params, arrToVec, makeInitialParams, normalDist, updateG, updateP,makeInitialValue,likelihood )

dim = 3
k = 3
n = 100

main :: IO ()
main = do
  str <- readFile "resource/x.csv"
  let csvReader = map show . map csv2vec . lines
  --mapM_ putStrLn $ csvReader str

  let val = makeInitialValue (map csv2vec (lines str))
  --putStrLn (show val)

  let val2 = iter val

  putStrLn "iter fin"
  --putStrLn (show val2)
  --showLH (likelihood (_X val2) (params val2))

  --args <- getArgs
  --case args of
  --  [xcsv, zcsv, paramsdat] -> do
  --    putStrLn xcsv
  --  _ -> putStrLn "Bad arg"
  --let params = makeInitialParams k
  --putStrLn "Fin"
  --mapM_ putStrLn $ map show params
  --show params
  --mapM_ putStrLn $ show params
  --putStrLn $ case size(vector [1..6]) of
  --  5 -> "True"
  --  _ -> "What"



estep :: Values -> Values
estep v = v {_G = newG}
  where
    newG = updateG v

mstep :: Values -> Values
mstep v = v {params = newPs}
  where
    newPs = updateP 3 v

iter :: Values -> Values
iter v = mstep (estep v)

showLH :: Double -> IO ()
showLH lh = do
  putStrLn (show lh)

--readX :: String -> [Double]
--readX l =

--readCSVline :: String -> String -> [String]
--readCSVline l nl ns =


--stack exec emAlgorithm x.csv z.csv params.dat
--show the value of likelihood or lower bound at each iteration
--Output z.csv(posterior probabilities of zn) and params
--xは三次元
