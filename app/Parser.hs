module Parser where 

import Data.Void

import Text.Megaparsec 
import Text.Megaparsec.Char

type Parser = Parsec Void String

data SymbolExpr = StringExpr String | IntExpr Int deriving Eq

instance Show SymbolExpr where 
    show (StringExpr str) = "[" ++ str ++ "]"
    show (IntExpr i) = "#" ++ show i

data Expr = Identifier String 
  | Lambda String Expr
  | Application Expr Expr
  | Symbol SymbolExpr
  deriving Eq

instance Show Expr where    
  show (Identifier i) = i
  show (Lambda i e) = "λ" ++ i ++ "." ++ show e
  show (Application e1 e2) = "(" ++ show e1 ++ ")(" ++ show e2 ++ ")" 
  show (Symbol s) = show s

parseIdentifier :: Parser String 
parseIdentifier = some alphaNumChar

parseExpr :: Parser Expr 
parseExpr = parseLambda <|> try parseApplication <|> (Identifier <$> (parseIdentifier <* space))

parseLambda :: Parser Expr 
parseLambda = do 
    param <- char 'λ' *> space *> parseIdentifier 
    body  <- char '.' *> space *> parseExpr <* space

    return (Lambda param body)

parseApplication :: Parser Expr 
parseApplication = do 
    e1 <- char '(' *> space *> parseExpr <* char ')' <* space
    e2 <- char '(' *> space *> parseExpr <* char ')' <* space

    return (Application e1 e2)
