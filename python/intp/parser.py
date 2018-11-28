from intp import ast
from intp import token

LOWEST = 0


class Parser:
    def __init__(self, lexer):
        self.lexer = lexer
        self.cur_token = None
        self.peek_token = None
        self.errors = []
        self.prefix_parse_fns = {
            token.IDENT: self._parse_identifier,
        }

        self._next_token()
        self._next_token()

    def _next_token(self):
        self.cur_token = self.peek_token
        self.peek_token = self.lexer.next_token()

    def _parse_statement(self):
        if self.cur_token.type == token.LET:
            return self._parse_let_statement()
        elif self.cur_token.type == token.RETURN:
            return self._parse_return_statement()
        else:
            return self._parse_expression_statement()

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

    def _parse_return_statement(self):
        stmt = ast.ReturnStatement(self.cur_token)
        self._next_token()

        while not self._cur_token_is(token.SEMICOLON):
            self._next_token()

        return stmt

    def _parse_expression_statement(self):
        stmt = ast.ExpressionStatement(self.cur_token)
        stmt.expression = self._parse_expression(LOWEST)
        if self._peek_token_is(token.SEMICOLON):
            self._next_token()
        return stmt

    def _parse_expression(self, precedence):
        prefix = self.prefix_parse_fns[self.cur_token.type]
        if not prefix:
            return None
        left_exp = prefix()
        return left_exp

    def _parse_identifier(self):
        return ast.Identifier(self.cur_token, self.cur_token.literal)

    def _cur_token_is(self, tp):
        return self.cur_token.type == tp

    def _peek_token_is(self, tp):
        return self.peek_token.type == tp

    def _expect_peek(self, tp):
        if self._peek_token_is(tp):
            self._next_token()
            return True
        else:
            self._peek_error(tp)
            return False

    def _peek_error(self, tp):
        msg = "expected next token to be %s, got %s instead" % (tp, self.peek_token.type)
        self.errors.append(msg)

    def parse_program(self):
        program = ast.Program()
        while self.cur_token.type != token.EOF:
            stmt = self._parse_statement()
            if stmt:
                program.statements.append(stmt)
            self._next_token()

        return program
