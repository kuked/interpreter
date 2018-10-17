require_relative 'helper'

class AstTest < Minitest::Test
  def test_string
    let_stmt = Intp::LetStatement.new
    let_stmt.token = Intp::Token.new(Intp::Token::LET, 'let')
    let_stmt.name = Intp::Identifier.new(
      Intp::Token.new(Intp::Token::IDENT, 'myVar'),
      'myVar'
    )
    let_stmt.value = Intp::Identifier.new(
      Intp::Token.new(Intp::Token::IDENT, 'anotherVar'),
      'anotherVar'
    )
    program = Intp::Program.new([let_stmt])

    assert_equal program.to_s, 'let myVar = anotherVar;'
  end
end
