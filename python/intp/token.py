class Token:
    def __init__(self, type, literal):
        self.type = type
        self.literal = literal


ILLEGAL = "ILLEGAL"
EOF = "EOF"

IDENT = "IDENT"
INT = "INT"

ASSIGN = "="
PLUS = "+"
MINUS = "-"
BANG = "!"
ASTERISK = "*"
SLASH = "/"

LT = "<"
GT = ">"

COMMA = ","
SEMICOLON = ";"

LPAREN = "("
RPAREN = ")"
LBRACE = "{"
RBRACE = "}"

FUNCTION = "FUNCTION"
LET = "LET"
TRUE = "TRUE"
FALSE = "FALSE"
IF = "IF"
ELSE = "ELSE"
RETURN = "RETURN"

_keywords = {
    "fn": FUNCTION,
    "let": LET,
    "true": TRUE,
    "false": FALSE,
    "if": IF,
    "else": ELSE,
    "return": RETURN,
}


def lookup_ident(ident):
    return _keywords.get(ident, IDENT)
