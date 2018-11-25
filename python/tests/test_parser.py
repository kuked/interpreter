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

    def check_parse_errors(self, parser):
        errors = parser.errors
        if len(errors) == 0:
            return
        print("parser has %d errors" % len(errors))
        for msg in errors:
            print("parser error: %s" % msg)
        self.fail()
