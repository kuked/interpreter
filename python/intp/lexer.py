from . import token


class Lexer:
    def __init__(self, input):
        self.input = input
        self.position = 0
        self.read_position = 0
        self.ch = None
        self._read_char()

    def _read_char(self):
        if self.read_position >= len(self.input):
            self.ch = None
        else:
            self.ch = self.input[self.read_position]
        self.position = self.read_position
        self.read_position += 1

    def next_token(self):
        def _new_token(type):
            return token.Token(type, self.ch)

        if self.ch == "=":
            tok = _new_token(token.ASSIGN)
        elif self.ch == ";":
            tok = _new_token(token.SEMICOLON)
        elif self.ch == "(":
            tok = _new_token(token.LPAREN)
        elif self.ch == ")":
            tok = _new_token(token.RPAREN)
        elif self.ch == ",":
            tok = _new_token(token.COMMA)
        elif self.ch == "+":
            tok = _new_token(token.PLUS)
        elif self.ch == "{":
            tok = _new_token(token.LBRACE)
        elif self.ch == "}":
            tok = _new_token(token.RBRACE)
        else:
            tok = token.Token(token.EOF, "")

        self._read_char()
        return tok
