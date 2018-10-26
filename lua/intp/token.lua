-- token.lua
local Token = {}

Token.ILLEGAL = "ILLEGAL"
Token.EOF     = "EOF"

Token.IDENT = "IDENT"
Token.INT   = "INT"

Token.ASSIGN   = "="
Token.PLUS     = "+"
Token.MINUS    = "-"
Token.BANG     = "!"
Token.ASTERISK = "*"
Token.SLASH    = "/"

Token.LT = "<"
Token.GT = ">"

Token.COMMA     = ","
Token.SEMICOLON = ";"

Token.LPAREN = "("
Token.RPAREN = ")"
Token.LBRACE = "{"
Token.RBRACE = "}"

Token.FUNCTION = "FUNCTION"
Token.LET      = "LET"
Token.TRUE     = "TRUE"
Token.FALSE    = "FALSE"
Token.IF       = "IF"
Token.ELSE     = "ELSE"
Token.RETURN   = "RETURN"

local keywords = {
   fn      = Token.FUNCTION,
   let     = Token.LET,
   true_   = Token.TRUE,
   false_  = Token.FALSE,
   if_     = Token.IF,
   else_   = Token.ELSE,
   return_ = Token.RETURN
} 

Token.lookupIdent = function(ident)
   local key = ident
   if string.match(key, "true") or string.match(key, "false") or string.match(key, "if") or string.match(key, "else") or string.match(key, "return") then
      key = ident.."_"
   end
   v = keywords[key]
   return v and v or Token.IDENT
end

return Token
