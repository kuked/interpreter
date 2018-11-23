import os
from intp import repl

if __name__ == "__main__":
    user = os.getlogin()
    print(f"Hello {user}! This is the Monkey programming language!")
    print("Feel free to type in commands")
    repl.start()
