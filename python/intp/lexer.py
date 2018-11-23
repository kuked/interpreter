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

    def _read_identifier(self):
        position = self.position
        while is_letter(self.ch):
            self._read_char()
        return self.input[position:self.position]

    def _skip_white_space(self):
        while self.ch == " " or self.ch == "\t" or self.ch == "\n" or self.ch == "\r":
            self._read_char()

    def _read_number(self):
        position = self.position
        while is_digit(self.ch):
            self._read_char()
        return self.input[position:self.position]

    def _peek_char(self):
        if self.read_position >= len(self.input):
            return None
        else:
            return self.input[self.read_position]

    def next_token(self):
        def _new_token(type):
            return token.Token(type, self.ch)

        self._skip_white_space()

        if self.ch == "=":
            if self._peek_char() == "=":
                ch = self.ch
                self._read_char()
                tok = token.Token(token.EQ, ch + self.ch)
            else:
                tok = _new_token(token.ASSIGN)
        elif self.ch == ";":
            tok = _new_token(token.SEMICOLON)
        elif self.ch == "(":
            tok = _new_token(token.LPAREN)
        elif self.ch == ")":
            tok = _new_token(token.RPAREN)
        elif self.ch == ",":
            tok = _new_token(token.COMMA)
        elif self.ch == "!":
            if self._peek_char() == "=":
                ch = self.ch
                self._read_char()
                tok = token.Token(token.NOT_EQ, ch + self.ch)
            else:
                tok = _new_token(token.BANG)
        elif self.ch == "+":
            tok = _new_token(token.PLUS)
        elif self.ch == "-":
            tok = _new_token(token.MINUS)
        elif self.ch == "*":
            tok = _new_token(token.ASTERISK)
        elif self.ch == "/":
            tok = _new_token(token.SLASH)
        elif self.ch == "<":
            tok = _new_token(token.LT)
        elif self.ch == ">":
            tok = _new_token(token.GT)
        elif self.ch == "{":
            tok = _new_token(token.LBRACE)
        elif self.ch == "}":
            tok = _new_token(token.RBRACE)
        elif self.ch is None:
            tok = token.Token(token.EOF, "")
        else:
            if is_letter(self.ch):
                literal = self._read_identifier()
                return token.Token(token.lookup_ident(literal), literal)
            elif is_digit(self.ch):
                return token.Token(token.INT, self._read_number())
            else:
                tok = _new_token(token.ILLEGAL)

        self._read_char()
        return tok


def is_letter(ch):
    if ch is None:
        return False
    return "a" <= ch and ch <= "z" or "A" <= ch and ch <= "Z" or ch == "_"


def is_digit(ch):
    if ch is None:
        return False
    return "0" <= ch and ch <= "9"
