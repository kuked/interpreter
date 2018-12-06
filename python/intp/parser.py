from intp import ast
from intp import token

LOWEST = 0
EQUALS = 1
LESSGREATER = 2
SUM = 3
PRODUCT = 4
PREFIX = 5
CALL = 6


class Parser:
    def __init__(self, lexer):
        self.lexer = lexer
        self.cur_token = None
        self.peek_token = None
        self.errors = []
        self.prefix_parse_fns = {
            token.IDENT: self._parse_identifier,
            token.INT: self._parse_integer_literal,
            token.BANG: self._parse_prefix_expression,
            token.MINUS: self._parse_prefix_expression,
        }
        self.infix_parse_fns = {
            token.PLUS: self._parse_infix_expression,
            token.MINUS: self._parse_infix_expression,
            token.SLASH: self._parse_infix_expression,
            token.ASTERISK: self._parse_infix_expression,
            token.EQ: self._parse_infix_expression,
            token.NOT_EQ: self._parse_infix_expression,
            token.LT: self._parse_infix_expression,
            token.GT: self._parse_infix_expression,
        }
        self.precedences = {
            token.EQ: EQUALS,
            token.NOT_EQ: EQUALS,
            token.LT: LESSGREATER,
            token.GT: LESSGREATER,
            token.PLUS: SUM,
            token.MINUS: SUM,
            token.SLASH: PRODUCT,
            token.ASTERISK: PRODUCT,
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
            self.errors.append(f"no prefix parse function for %s found" % self.cur_token.type)
            return None
        left_exp = prefix()
        while not self._peek_token_is(token.SEMICOLON) and precedence < self._peek_precedence():
            infix = self.infix_parse_fns[self.peek_token.type]
            if not infix:
                return left_exp
            self._next_token()
            left_exp = infix(left_exp)

        return left_exp

    def _parse_identifier(self):
        return ast.Identifier(self.cur_token, self.cur_token.literal)

    def _parse_integer_literal(self):
        lit = ast.IntegerLiteral(self.cur_token)
        lit.value = int(self.cur_token.literal)
        return lit

    def _parse_prefix_expression(self):
        expression = ast.PrefixExpression(self.cur_token)
        expression.operator = self.cur_token.literal
        self._next_token()
        expression.right = self._parse_expression(PREFIX)

        return expression

    def _parse_infix_expression(self, left):
        exp = ast.InfixExpression(self.cur_token)
        exp.operator = self.cur_token.literal
        exp.left = left

        prec = self._cur_precedence()
        self._next_token()
        exp.right = self._parse_expression(prec)

        return exp

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

    def _peek_precedence(self):
        prec = self.precedences[self.peek_token.type]
        if prec:
            return prec
        return LOWEST

    def _cur_precedence(self):
        prec = self.precedences[self.cur_token.type]
        if prec:
            return prec
        return LOWEST

    def parse_program(self):
        program = ast.Program()
        while self.cur_token.type != token.EOF:
            stmt = self._parse_statement()
            if stmt:
                program.statements.append(stmt)
            self._next_token()

        return program
