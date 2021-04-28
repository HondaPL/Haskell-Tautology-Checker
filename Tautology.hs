module Tautology where

--Declaring types
data Prop = Const Bool
       | Var Char
       | Not Prop
       | Prop `Or` Prop
       | Prop `And` Prop
       | Prop `Imply` Prop
       | Prop `DoubleImply` Prop
       deriving(Show,Eq,Read)

type Subst = Assoc Char Bool
type Assoc k v = [(k,v)]

{- 
       Find function gets value of the key
       eg. find 'a' [('a',False)] 
       return False
-}
find :: Eq k => k -> Assoc k v -> v
find k t = head [v | (k',v) <- t, k ==k']

{- 
       Evaluating a formulas 
       eg. eval [('a',False)] (Var 'a')
       returns False
-}
eval :: Subst -> Prop -> Bool
eval _ (Const b) = b
eval s (Var x)   = find x s
eval s (Not p)   = not (eval s p)
eval s (p `Or` q)  = eval s p || eval s q
eval s (p `And` q) = eval s p && eval s q
eval s (p `Imply` q) = eval s p <= eval s q
eval s (p `DoubleImply` q) = eval s p == eval s q

{- 
       Getting all arguments of formula
       eg. vars ((Var 'p' `Or` (Var 'q' `And` Var 'r')) 
              `DoubleImply` ((Var 'p' `Or` Var 'q') 
              `And` (Var 'p' `Or` Var 'r')))
       returns "pqrpqpr"
-}
vars :: Prop -> [Char]
vars (Const _)   = []
vars (Var x)     = [x]
vars (Not p)     = vars p
vars (p `Or` q)    = vars p ++ vars q
vars (p `And` q)   = vars p ++ vars q
vars (p `Imply` q) = vars p ++ vars q
vars (p `DoubleImply` q) = vars p ++ vars q

{- 
       Generating all posible values for truth table 
       eg. bools 2
       returns [[False,False],[False,True],[True,False],[True,True]]
-}
bools :: Int -> [[Bool]]
bools 0 = [[]]
bools n = map (False:) bss ++ map (True:) bss
       where bss = bools (n-1)

{-
       Variables in truth tables
       eg. substs (Var 'a') 
       returns [[('a',False)],[('a',True)]]
-}
substs :: Prop -> [Subst]
substs p = map (zip vs) (bools (length vs))
       where vs = rmdups (vars p)

rmdups :: Eq a => [a] -> [a]
rmdups [] = []
rmdups (x:xs) = x: filter (/= x) (rmdups xs)

{-
       Checking if formula is a tautology
-}
isTaut :: Prop -> Bool
isTaut p = and [eval s p | s <- substs p]