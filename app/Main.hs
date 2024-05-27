{-# LANGUAGE LambdaCase #-}

module Main where

import Data.Char

import Parser
import System.Environment
import System.IO

import Text.Megaparsec

eval :: (String, Expr) -> Expr -> Expr 
eval _ s@(Symbol _) = s
eval (name, value) e@(Identifier i)
  | name == i = value
  | otherwise = e
eval input@(name, _) (Lambda l e)
  | name == l = eval input e
  | otherwise = Lambda l (eval input e)
eval input (Application (Lambda l e) x) = eval input (eval (l, x) e)
eval input (Application f x) = Application (eval input f) (eval input x)

giveSymbol :: String -> Expr -> Expr 
giveSymbol name (Lambda l e) = eval (l, toSymbolExpr name) e 
giveSymbol _ e = e

giveSymbols :: [String] -> Expr -> Expr 
giveSymbols [] e = e 
giveSymbols (x:xs) e = giveSymbols xs (giveSymbol x e)

findNumbers :: Expr -> Expr 
findNumbers (Identifier "Z") = Symbol (IntExpr 0)
findNumbers e@(Application (Identifier "S") x) = case findNumbers x of 
    Symbol (IntExpr n) -> Symbol (IntExpr (n + 1))
    _ -> e 
findNumbers e = e

initExpr :: Expr -> Expr 
initExpr = eval ("", Symbol (StringExpr ("IMPOSSIBLE")))

fullyReduced :: Expr -> Bool 
fullyReduced (Symbol _) = True 
fullyReduced (Identifier _) = True 
fullyReduced (Lambda _ body) = fullyReduced body
fullyReduced (Application (Lambda _ _) _) = False 
fullyReduced (Application f x) = fullyReduced f && fullyReduced x

fullyReduce :: Expr -> Expr
fullyReduce e 
  | fullyReduced e = e 
  | otherwise = fullyReduce (eval ("", Symbol (StringExpr "IMPOSSIBLE")) e)

reduceExpr :: Expr -> Expr 
reduceExpr = fullyReduce . findNumbers

toSymbolExpr :: String -> Expr 
toSymbolExpr "true" = (Lambda "t" (Lambda "f" (Identifier "t")))
toSymbolExpr "false" = (Lambda "t" (Lambda "f" (Identifier "f")))
toSymbolExpr xs 
  | all isDigit xs = Symbol (IntExpr (read xs))
  | otherwise = Symbol (StringExpr xs)

main :: IO ()
main = getArgs >>= \case 
    (name:inputs) -> do 
        handle   <- openFile name ReadMode 
        hSetEncoding handle utf8
        hSetEncoding stdout utf8
        contents <- hGetContents handle

        case parse parseExpr name contents of 
            Left err -> putStrLn (errorBundlePretty err)
            Right e  -> print (reduceExpr $ giveSymbols inputs (initExpr e))

        hClose handle
    _ -> putStrLn "Bad arguments."

