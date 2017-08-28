module VecOp ( Parameters, Values, _G, _X, params, arrToVec, makeInitialParams, normalDist, updateG, updateP,makeInitialValue,likelihood  ) where

import Numeric.LinearAlgebra
import Params

data Parameters = Parameters {
  pi_ :: PIvec,
  mu_ :: Muvec,
  delta_ :: DeltaM } deriving Show

data Values = Values {
  _X :: [Xvec],
  _G :: [[Double]],
  params :: [Parameters]
} deriving Show

makeInitialValue :: [Xvec] -> Values
makeInitialValue x = Values x [[]] (makeInitialParams 3)

arrToVec :: [Double] -> Vector R
arrToVec arr = vector arr

--TODO Randomize
initParams :: Parameters
initParams = Parameters (1.0 / 3.0) (vector [0,0,0]) ((3><3) [1, 1, 1, 1, 1, 1, 1, 1, 1] :: Matrix R)

makeInitialParams :: Integer -> [Parameters]
makeInitialParams 0 = []
makeInitialParams k = initParams : makeInitialParams (k - 1)

normalDist :: Integer -> Xvec -> Muvec -> DeltaM -> Double
--normalDist d x mu de = 10

normalDist d x mu de = exp ((v <# de) <.> v) * (- 0.5) /  (((2.0 * pi)**l) * sqrt (det (inv de)))
--
-- /(((2.0 * pi)**l :: Double) * sqrt (det (inv de)))
  --realToFrac (exp (- 0.5 * ((v <# de) <.> v))) :: Double -- * 0.01 --(sqrt (det (inv de)))
--
  where
    v = x - mu
    l = 0.5 * (fromInteger d) :: Double


{-
E-step
-}
updateG :: Values -> [[Double]]
updateG (Values [] _ _) = []
updateG (Values (x : xs) _ p) = if (calcGammaDenominator x p) /= 0 then (calcGammaOfn x (calcGammaDenominator x p) p) : updateG (Values xs [] p) else [[]]

calcGammaOfn :: Xvec -> Double -> [Parameters] -> [Double]
--calcGammaOfn _ _ _ = [20, 30, 10]
calcGammaOfn _ _ [] = []
calcGammaOfn x denom (p : ps) = ((calcGammaNumerato x p) / denom) : (calcGammaOfn x denom ps)

calcGammaNumerato :: Xvec -> Parameters -> Double
--calcGammaNumerato _ _ = 10
calcGammaNumerato x p = (pi_ p) * (normalDist 3 x (mu_ p) (delta_ p))

calcGammaDenominator :: Xvec -> [Parameters] -> Double
--calcGammaDenominator _ _ = 10
calcGammaDenominator x [] = 0
calcGammaDenominator x (p : ps) = (pi_ p) * (normalDist 3 x (mu_ p) (delta_ p)) + (calcGammaDenominator x ps)


{-
M-step
-}
updateP :: Int -> Values -> [Parameters]
updateP 0 _ = []
updateP k v = (Parameters newPi newMu newDelta) : updateP (k - 1) v
  where
    newPi = updatePi k v
    newMu = updateMu k v
    newDelta = updateDelta k v

updatePi :: Int -> Values -> PIvec
updatePi k v = (calcSk1 k (_G v)) / 3.0

updateMu :: Int -> Values -> Muvec
updateMu k v = (calcSkx k (_X v) (_G v)) * dom
  where sk1 = (calcSk1 k (_G v)); dom = vector [1 / sk1, 1 / sk1, 1 / sk1]


updateDelta :: Int -> Values -> DeltaM
updateDelta k v = (calcSkxx k (_X v) (_G v)) * dom - (matX mu)
  where
    mu = arrarAccMu (params v) k;
    sk1 = calcSk1 k (_G v);
    dom = (3><3) [1 / sk1, 1 / sk1, 1 / sk1, 1 / sk1, 1 / sk1, 1 / sk1, 1 / sk1, 1 / sk1, 1 / sk1] :: Matrix R

calcSk1 :: Int -> [[Double]] -> Double
calcSk1 _ [] = 0
calcSk1 k (g : gs) = (arrarAcc g k) + calcSk1 k gs


calcSkx :: Int -> [Xvec] -> [[Double]] -> Vector R
calcSkx _ [] [] = 0
calcSkx k (x : xs) (g : gs) = x * v + calcSkx k xs gs
  where
    c = (arrarAcc g k)
    v = vector [c, c, c]

calcSkxx :: Int -> [Xvec] -> [[Double]] -> Matrix R
calcSkxx _ [] [] = 0
calcSkxx k (x : xs) (g : gs) = mat * (matX x) + calcSkxx k xs gs
  where
    c = (arrarAcc g k)
    mat = (3><3) [c,c,c,c,c,c,c,c,c] :: Matrix R

matX :: Xvec -> Matrix R
matX = undefined

arrarAccMu :: [Parameters] -> Int -> Vector R
arrarAccMu (p : ps) 1 = mu_ p
arrarAccMu (p : ps) n = arrarAccMu ps (n - 1)

arrarAcc :: [a] -> Int -> a
arrarAcc (x : xs) 1 = x
arrarAcc (x : xs) n = arrarAcc xs (n - 1)

{-
Other Func
-}
likelihood :: [Xvec] -> [Parameters] -> Double
likelihood [] _ = 0
likelihood (x : xs) p = log (nlikelihood x p) + likelihood xs p

nlikelihood :: Xvec -> [Parameters] -> Double
nlikelihood _ [] = 0
nlikelihood x (p : ps) = (pi_ p) * (normalDist 3 x (mu_ p) (delta_ p))

--
