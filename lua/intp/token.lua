-- token.lua
local Token = {}

Token.ILLEGAL = "ILLEGAL"
Token.EOF     = "EOF"

Token.IDENT = "IDENT"
Token.INT   = "INT"

Token.ASSIGN = "="
Token.PLUS   = "+"

Token.COMMA     = ","
Token.SEMICOLON = ";"

Token.LPAREN = "("
Token.RPAREN = ")"
Token.LBRACE = "{"
Token.RBRACE = "}"

Token.FUNCTION = "FUNCTION"
Token.LET      = "LET"

local keywords = { fn = Token.FUNCTION, let = Token.LET }
Token.lookupIdent = function(ident)
   v = keywords[ident]
   return v and v or Token.IDENT
end

return Token
