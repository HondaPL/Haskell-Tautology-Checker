-- 26 Apr 2021 Adam Hącia

{- 
     I'm importing two modules:
     1.   Parsing - written in parts by Professor Graham Hutton https://youtu.be/dDtZLm7HIJs
          I added three extra functions: numb, prop and prop'/
     2.   Tautology - module I written with help of "Programming in Haskell" book
          http://www.cs.nott.ac.uk/~pszgmh/pih.html
-}
import Parsing
import Tautology

{-
     We define: 
     - Disjunction as |
     - Conjunction as &
     - Implication as ->
     - Biconditional as <=>
     - Negation as ~
     - Brackets as ()
-}

{-
     To run the program you can use two functions

     1. getFormula - function which gets formula from keyboard
          np. getFormula 
              a|a|b
     2. runFormula- function which gets formula as a parameter
          np. runFormula "a|v|a"
-}

-- Tests set

-- De Morgana's first law
test1 = runFormula "~(p&q)<=>~p|~q"
-- Formula written incorrectly
test2 = runFormula "a|b|c|a->a&a|s)"
-- Formula which is not a tautology
test3 = runFormula "p->(p&q)"
-- Next formula which is not a tautology
test4 = runFormula "p|q->p"
-- Law for Disjunction
test5 = runFormula "((p->r)&(q->r))->((p|q)->(r|s))"
-- Distributivity
test6 = runFormula "(p|(q&r))<=>((p|q)&(p|r))"
-- Long disjunction
test7 = runFormula "t|h|e|f|a|b|~f|o|u|r"
-- Formula written incorrectly
test8 = runFormula "()p"
-- Law of double negation
test9 = runFormula "~(~p)<=>p"

{- 
     First type of parsing
     
     eg. parse disjunction "a|b|c"
     gives [("a || b || c","")]
     
     eg. parse disjunction "a|b&&c"
     gives [("a || b","&&c")]
-}
disjunction = do 
     x <- conjunction
     char '|'
     y <- disjunction
     return (x++" || "++y)
  <|> conjunction

conjunction = do 
     x <- implication
     char '&'
     y <- conjunction
     return (x++" && "++y)
  <|> implication

implication = do 
     x <- biconditional
     char '-'
     char '>'
     y <- implication
     return (x++" => "++y)
  <|> biconditional

biconditional = do 
     x <- negation
     char '<'
     char '='
     char '>'
     y <- biconditional
     return (x++" <=> "++y)
  <|> negation

negation = do 
     char '~'
     x <- brackets
     return ("~"++x)
  <|> brackets

brackets = do 
     char '('
     x <- disjunction
     char ')'
     return ("("++x++")")
  <|> prop 

{-   
     Checking if formula was parsed correctly
-}
checkIfFormula a = 
     if (parse disjunction a /= [] && snd (head (parse disjunction a)) == "") 
          then True 
     else False

{-
     Running program from keyboard
-}

getFormula = do
    putStrLn "Write a logical formula"
    a <- getLine
    runFormula a

{-
     Main function
-}

runFormula a = do
    putStrLn $ "\x1b[34m" ++ "Entered text is: " ++ show (a) ++ "\x1b[0m" 
    checkIfParsed a
    checkIfTaut2 a

{-
     Function which for well parsed farmula returns if it's a tautology
-}

checkIfTaut a = isTaut a 

{-
     Checking if formula was parsed correctly
-}
checkIfParsed a = do 
          if (checkIfFormula a) 
          then do 
               putStrLn $ "\x1b[32m" ++ "Formula (first option) parsed to: " ++ (show (fst ((head (parse disjunction a))))) ++ "\x1b[0m" 
               putStrLn $ "\x1b[32m" ++ "Formula (second option) parsed to: " ++ (show (fst ((head (parse disjunction' a))))) ++ "\x1b[0m" 
          else if (parse disjunction a /= []) 
                    then 
                         putStrLn $ "\x1b[31m" ++ "Parse error at " ++  (show (snd ((head (parse disjunction a))))) ++ "\x1b[0m"
               else putStrLn $ "\x1b[31m" ++ "Some problems with parsing" ++ "\x1b[0m"

{-
     Checking if tautology
-}
checkIfTaut2 a = do 
     if (checkIfFormula a) 
          then if (checkIfTaut(fst (head (parse disjunction' a)))) 
               then putStrLn $ "\x1b[32m" ++ "It's a tautology :)" ++ "\x1b[0m" 
          else putStrLn $ "\x1b[35m" ++ "Unfortunately it is not a tautology :(" ++ "\x1b[0m" 
     else putStr ""


{-
     Second version of parsing, I use it to test if the formula is a tautology
     
     eg. parse disjunction' "a|b|"
     gives [(Var 'a' `Or` Var 'b',"|")]

     eg. parse disjunction' "a|b&a->c"
     gives [(Var 'a' `Or` (Var 'b' `And` (Var 'a' `Imply` Var 'c')),"")]
-}

disjunction' = do 
     x <- conjunction'
     char '|'
     y <- disjunction'
     return (x `Or` y)
  <|> conjunction' 

conjunction' = do 
     x <- implication'
     char '&'
     y <- conjunction'
     return (x `And` y)
  <|> implication'

implication' = do 
     x <- biconditional'
     char '-'
     char '>'
     y <- implication'
     return (x `Imply` y)
  <|> biconditional'

biconditional' = do 
     x <- negation'
     char '<'
     char '='
     char '>'
     y <- biconditional'
     return (x `DoubleImply` y)
  <|> negation'

negation' = do 
     char '~'
     x <- brackets'
     return (Not x)
  <|> brackets'

brackets' = do 
     char '('
     x <- disjunction'
     char ')'
     return (x)
  <|> prop'

