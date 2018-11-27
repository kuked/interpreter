import io


class Program:
    def __init__(self):
        self.statements = []

    def token_literal(self):
        if len(self.statements) > 0:
            return self.statements[0].token_literal()
        return ""

    def string(self):
        out = io.StringIO()
        for stmt in self.statements:
            out.write(stmt.string())
        return out.getvalue()


class LetStatement:
    def __init__(self, token):
        self.token = token
        self.name = None
        self.value = None

    def token_literal(self):
        return self.token.literal

    def string(self):
        out = io.StringIO()
        out.write(self.token_literal() + " ")
        out.write(self.name.string())
        out.write(" = ")
        if self.value:
            out.write(self.value.string())
        out.write(";")
        return out.getvalue()


class Identifier:
    def __init__(self, token, value):
        self.token = token
        self.value = value

    def token_literal(self):
        return self.token.literal

    def string(self):
        return self.value


class ReturnStatement:
    def __init__(self, token):
        self.token = token
        self.return_value = None

    def token_literal(self):
        return self.token.literal

    def string(self):
        out = io.StringIO()
        out.write(self.token_literal() + " ")
        if self.return_value:
            out.write(self.return_value.string())
        out.write(";")
        return self.getvalue()


class ExpressionStatement:
    def __init__(self, token):
        self.token = token
        self.expression = None

    def token_literal(self):
        return self.token.literal

    def string(self):
        if self.expression:
            return self.expression.string()
        return ""
