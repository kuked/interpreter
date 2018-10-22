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

return Token
