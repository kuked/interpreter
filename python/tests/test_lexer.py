import unittest
from intp import token


class TestNextToken(unittest.TestCase):
    def test_next_token(self):
        input = "=+(){},;"

        tests = [
            (token.ASSIGN, "="),
            (token.PLUS, "+"),
            (token.LPAREN, "("),
            (token.RPAREN, ")"),
            (token.LBRACE, "{"),
            (token.RBRACE, "}"),
            (token.COMMA, ","),
            (token.SEMICOLON, ";"),
            (token.EOF, ""),
        ]

        l = lexer.Lexer(input)

        for expected_type, expected_literal in tests:
            tok = l.next_token()
            self.assertEqual(tok.type, expected_type)
            self.assertEqual(tok.literal, expected_literal)
