import unittest
from intp import ast
from intp import token


class TestString(unittest.TestCase):
    def test_string(self):
        program = ast.Program()

        statement = ast.LetStatement(token.Token(token.LET, "let"))
        statement.name = ast.Identifier(token.Token(token.IDENT, "myVar"), "myVar")
        statement.value = ast.Identifier(token.Token(token.IDENT, "anotherVar"), "anothervar")
        program.statements = [statement]

        self.assertEqual(program.string(), "let myVar = anothervar;")
