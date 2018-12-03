import unittest
from intp import ast
from intp import lexer
from intp import parser


class TestLetStatements(unittest.TestCase):
    def test_let_statements(self):
        input = """
        let x = 5;
        let y = 10;
        let foobar = 838383;
        """

        l = lexer.Lexer(input)
        p = parser.Parser(l)

        program = p.parse_program()
        self.check_parse_errors(p)
        self.assertIsNotNone(program)
        self.assertEqual(len(program.statements), 3)

        tests = [
            "x",
            "y",
            "foobar",
        ]
        for i, expected in enumerate(tests):
            stmt = program.statements[i]
            self.assertEqual(stmt.token_literal(), "let")
            self.assertIsInstance(stmt, ast.LetStatement)
            let_stmt = stmt
            self.assertEqual(let_stmt.name.value, expected)
            self.assertEqual(let_stmt.name.token_literal(), expected)

    def test_return_statement(self):
        input = """
        return 5;
        return 10;
        return 993322;
        """

        l = lexer.Lexer(input)
        p = parser.Parser(l)

        program = p.parse_program()
        self.check_parse_errors(p)
        self.assertEqual(len(program.statements), 3)

        for stmt in program.statements:
            self.assertIsInstance(stmt, ast.ReturnStatement)
            self.assertEqual(stmt.token_literal(), "return")

    def test_identifier_expression(self):
        input = "foobar;"

        l = lexer.Lexer(input)
        p = parser.Parser(l)

        program = p.parse_program()
        self.check_parse_errors(p)

        self.assertEqual(len(program.statements), 1)
        stmt = program.statements[0]
        self.assertIsInstance(stmt, ast.ExpressionStatement)

        ident = stmt.expression
        self.assertEqual(ident.value, "foobar")
        self.assertEqual(ident.token_literal(), "foobar")

    def test_integer_literal_expression(self):
        input = "5;"

        l = lexer.Lexer(input)
        p = parser.Parser(l)

        program = p.parse_program()
        self.check_parse_errors(p)

        self.assertEqual(len(program.statements), 1)
        stmt = program.statements[0]
        self.assertIsInstance(stmt, ast.ExpressionStatement)

        literal = stmt.expression
        self.assertIsInstance(literal, ast.IntegerLiteral)
        self.assertEqual(literal.value, 5)
        self.assertEqual(literal.token_literal(), "5")

    def check_parse_errors(self, parser):
        errors = parser.errors
        if len(errors) == 0:
            return
        print("parser has %d errors" % len(errors))
        for msg in errors:
            print("parser error: %s" % msg)
        self.fail()
