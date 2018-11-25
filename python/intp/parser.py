from intp import ast
from intp import token


class Parser:
    def __init__(self, lexer):
        self.lexer = lexer
        self.cur_token = None
        self.peek_token = None

        self._next_token()
        self._next_token()

    def _next_token(self):
        self.cur_token = self.peek_token
        self.peek_token = self.lexer.next_token()

    def _parse_statement(self):
        if self.cur_token.type == token.LET:
            return self._parse_let_statement()
        else:
            return None

    def _parse_let_statement(self):
        stmt = ast.LetStatement(self.cur_token)
        if not self._expect_peek(token.IDENT):
            return None
        stmt.name = ast.Identifier(self.cur_token, self.cur_token.literal)
        if not self._expect_peek(token.ASSIGN):
            return None
        while not self._cur_token_is(token.SEMICOLON):
            self._next_token()
        return stmt

    def _cur_token_is(self, tp):
        return self.cur_token.type == tp

    def _peek_token_is(self, tp):
        return self.peek_token.type == tp

    def _expect_peek(self, tp):
        if self._peek_token_is(tp):
            self._next_token()
            return True
        return False

    def parse_program(self):
        program = ast.Program()
        while self.cur_token.type != token.EOF:
            stmt = self._parse_statement()
            if stmt:
                program.statements.append(stmt)
            self._next_token()

        return program
