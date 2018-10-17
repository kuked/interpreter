require_relative 'helper'

class LexerTest < Minitest::Test
  def test_next_token
    input = <<INPUT
    let five = 5;
    let ten = 10;

    let add = fn(x, y) {
      x + y;
    };

    let result = add(five, ten);
    !-/*5;
    5 < 10 > 5;

    if (5 < 10) {
      return true;
    } else {
      return false;
    }

    10 == 10;
    10 != 9;
    "foobar"
    "foo bar"
    [1, 2];
    {"foo": "bar"}
INPUT

    tests = [
      [Intp::Token::LET, 'let'],
      [Intp::Token::IDENT, 'five'],
      [Intp::Token::ASSIGN, '='],
      [Intp::Token::INT, '5'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::LET, 'let'],
      [Intp::Token::IDENT, 'ten'],
      [Intp::Token::ASSIGN, '='],
      [Intp::Token::INT, '10'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::LET, 'let'],
      [Intp::Token::IDENT, 'add'],
      [Intp::Token::ASSIGN, '='],
      [Intp::Token::FUNCTION, 'fn'],
      [Intp::Token::LPAREN, '('],
      [Intp::Token::IDENT, 'x'],
      [Intp::Token::COMMA, ','],
      [Intp::Token::IDENT, 'y'],
      [Intp::Token::RPAREN, ')'],
      [Intp::Token::LBRACE, '{'],
      [Intp::Token::IDENT, 'x'],
      [Intp::Token::PLUS, '+'],
      [Intp::Token::IDENT, 'y'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::RBRACE, '}'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::LET, 'let'],
      [Intp::Token::IDENT, 'result'],
      [Intp::Token::ASSIGN, '='],
      [Intp::Token::IDENT, 'add'],
      [Intp::Token::LPAREN, '('],
      [Intp::Token::IDENT, 'five'],
      [Intp::Token::COMMA, ','],
      [Intp::Token::IDENT, 'ten'],
      [Intp::Token::RPAREN, ')'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::BANG, '!'],
      [Intp::Token::MINUS, '-'],
      [Intp::Token::SLASH, '/'],
      [Intp::Token::ASTERISK, '*'],
      [Intp::Token::INT, '5'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::INT, '5'],
      [Intp::Token::LT, '<'],
      [Intp::Token::INT, '10'],
      [Intp::Token::GT, '>'],
      [Intp::Token::INT, '5'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::IF, 'if'],
      [Intp::Token::LPAREN, '('],
      [Intp::Token::INT, '5'],
      [Intp::Token::LT, '<'],
      [Intp::Token::INT, '10'],
      [Intp::Token::RPAREN, ')'],
      [Intp::Token::LBRACE, '{'],
      [Intp::Token::RETURN, 'return'],
      [Intp::Token::TRUE, 'true'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::RBRACE, '}'],
      [Intp::Token::ELSE, 'else'],
      [Intp::Token::LBRACE, '{'],
      [Intp::Token::RETURN, 'return'],
      [Intp::Token::FALSE, 'false'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::RBRACE, '}'],
      [Intp::Token::INT, '10'],
      [Intp::Token::EQ, '=='],
      [Intp::Token::INT, '10'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::INT, '10'],
      [Intp::Token::NOT_EQ, '!='],
      [Intp::Token::INT, '9'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::STRING, 'foobar'],
      [Intp::Token::STRING, 'foo bar'],
      [Intp::Token::LBRACKET, '['],
      [Intp::Token::INT, '1'],
      [Intp::Token::COMMA, ','],
      [Intp::Token::INT, '2'],
      [Intp::Token::RBRACKET, ']'],
      [Intp::Token::SEMICOLON, ';'],
      [Intp::Token::LBRACE, '{'],
      [Intp::Token::STRING, 'foo'],
      [Intp::Token::COLON, ':'],
      [Intp::Token::STRING, 'bar'],
      [Intp::Token::RBRACE, '}'],
      [Intp::Token::EOF, '']
    ]

    l = Intp::Lexer.new(input)

    tests.each do |test|
      token = l.next_token
      assert_equal test[0], token.type
      assert_equal test[1], token.literal
    end
  end
end
