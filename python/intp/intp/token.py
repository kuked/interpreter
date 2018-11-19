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

COMMA = ","
SEMICOLON = ";"

LPAREN = "("
RPAREN = ")"
LBRACE = "{"
RBRACE = "}"

FUNCTION = "FUNCTION"
LET = "LET"
