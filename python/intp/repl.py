from . import lexer
from . import token

PROMPT = ">> "


def start():
    while True:
        print(PROMPT, end="")

        line = input()
        l = lexer.Lexer(line)

        while True:
            tok = l.next_token()
            if tok.type == token.EOF:
                break
            print(tok.type)
