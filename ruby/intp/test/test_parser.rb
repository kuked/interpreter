require_relative 'helper'

class ParserTest < Minitest::Test
  def test_let_statements
    tests = [
      ['let x = 5;', 'x', 5],
      ['let y = true;', 'y', true],
      ['let foobar = y;', 'foobar', 'y']
    ]

    tests.each do |test|
      l = Intp::Lexer.new(test[0])
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal program.statements.length, 1
      stmt = program.statements[0]
      _test_let_statement stmt, test[1]
    end
  end

  def test_return_statements
    tests = [
      ['return 5;', 5],
      ['return foobar;', 'foobar']
    ]

    tests.each do |test|
      l = Intp::Lexer.new(test[0])
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal program.statements.length, 1
      stmt = program.statements[0]
      assert_instance_of Intp::ReturnStatement, stmt

      _test_literal_expression stmt.return_value, test[1]
    end
  end

  def test_identifier_expression
    input = 'foobar;'

    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)
    assert_equal 1, program.statements.length

    stmt = program.statements[0]
    assert_instance_of Intp::ExpressionStatement, stmt
    _test_literal_expression stmt.expression, 'foobar'
  end

  def test_integer_literal_expression
    input = '5;'

    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)
    assert_equal 1, program.statements.length

    stmt = program.statements[0]
    assert_instance_of Intp::ExpressionStatement, stmt

    _test_literal_expression stmt.expression, 5
  end

  def test_parsing_prefix_expressions
    tests = [
      ['!5;', '!', 5],
      ['-15;', '-', 15],
      ['!true', '!', true],
      ['!false', '!', false]
    ]

    tests.each do |test|
      l = Intp::Lexer.new(test[0])
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal 1, program.statements.length
      stmt = program.statements[0]
      assert_instance_of Intp::ExpressionStatement, stmt

      assert_instance_of Intp::PrefixExpression, stmt.expression

      exp = stmt.expression
      assert_equal exp.operator, test[1]

      _test_literal_expression exp.right, test[2]
    end
  end

  def test_parsing_infix_expressions
    infix_test = Struct.new(
      :input, :left_value, :operator, :right_value
    )
    tests = [
      infix_test.new('5 + 5',  5, '+', 5),
      infix_test.new('5 - 5',  5, '-', 5),
      infix_test.new('5 * 5',  5, '*', 5),
      infix_test.new('5 / 5',  5, '/', 5),
      infix_test.new('5 > 5',  5, '>', 5),
      infix_test.new('5 < 5',  5, '<', 5),
      infix_test.new('5 == 5', 5, '==', 5),
      infix_test.new('5 != 5', 5, '!=', 5),
      infix_test.new('true == true', true, '==', true),
      infix_test.new('true != false', true, '!=', false),
      infix_test.new('false == false', false, '==', false)
    ]

    tests.each do |test|
      l = Intp::Lexer.new(test.input)
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal 1, program.statements.length
      stmt = program.statements[0]
      assert_instance_of Intp::ExpressionStatement, stmt

      _test_infix_expression stmt.expression, test.left_value, test.operator, test.right_value
    end
  end

  def test_operator_precedence_parsing
    tests = [
      ['-a * b', '((-a) * b)'],
      ['!-a', '(!(-a))'],
      ['a + b + c', '((a + b) + c)'],
      ['a + b - c', '((a + b) - c)'],
      ['a * b * c', '((a * b) * c)'],
      ['a * b / c', '((a * b) / c)'],
      ['a + b / c', '(a + (b / c))'],
      ['a + b * c + d / e - f', '(((a + (b * c)) + (d / e)) - f)'],
      ['3 + 4; -5 * 5', '(3 + 4)((-5) * 5)'],
      ['5 > 4 == 3 < 4', '((5 > 4) == (3 < 4))'],
      ['5 < 4 != 3 > 4', '((5 < 4) != (3 > 4))'],
      ['3 + 4 * 5 == 3 * 1 + 4 * 5', '((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))'],
      ['1 + (2 + 3) + 4', '((1 + (2 + 3)) + 4)'],
      ['(5 + 5) * 2', '((5 + 5) * 2)'],
      ['2 / (5 + 5)', '(2 / (5 + 5))'],
      ['-(5 + 5)', '(-(5 + 5))'],
      ['!(true == true)', '(!(true == true))'],
      ['a + add(b * c) + d', '((a + add((b * c))) + d)'],
      ['add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))', 'add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))'],
      ['add(a + b + c * d / f + g)', 'add((((a + b) + ((c * d) / f)) + g))'],
      ['a * [1, 2, 3, 4][b * c] * d', '((a * ([1, 2, 3, 4][(b * c)])) * d)'],
      ['add(a * b[2], b[1], 2 * [1, 2][1])', 'add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))']
    ]

    tests.each do |test|
      l = Intp::Lexer.new(test[0])
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal test[1], program.to_s
    end
  end

  def test_boolean_literal_expression
    tests = [
      ['true', true],
      ['false', false]
    ]

    tests.each do |test|
      input, expected = test
      l = Intp::Lexer.new(input)
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal 1, program.statements.length
      stmt = program.statements[0]
      assert_instance_of Intp::ExpressionStatement, stmt
      _test_literal_expression stmt.expression, expected
    end
  end

  def test_if_expression
    input = 'if (x < y) { x } else { y }'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)
    assert_equal 1, program.statements.length

    stmt = program.statements[0]
    assert_instance_of Intp::ExpressionStatement, stmt

    exp = stmt.expression
    _test_infix_expression exp.condition, 'x', '<', 'y'
    assert_equal exp.consequence.statements.length, 1

    consequence = exp.consequence.statements[0]
    assert_instance_of Intp::ExpressionStatement, consequence
    _test_identifier consequence.expression, 'x'

    assert_equal exp.alternative.statements.length, 1

    alternative = exp.alternative.statements[0]
    assert_instance_of Intp::ExpressionStatement, alternative
    _test_identifier alternative.expression, 'y'
  end

  def test_function_literal_parsing
    input = 'fn(x, y) { x + y; }'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    assert_equal 1, program.statements.length
    stmt = program.statements[0]
    assert_instance_of Intp::ExpressionStatement, stmt

    function = stmt.expression
    assert_instance_of Intp::FunctionLiteral, function

    assert_equal 2, function.parameters.length
    _test_literal_expression function.parameters[0], 'x'
    _test_literal_expression function.parameters[1], 'y'

    assert_equal 1, function.body.statements.length
    body_stmt = function.body.statements[0]
    assert_instance_of Intp::ExpressionStatement, body_stmt

    _test_infix_expression body_stmt.expression, 'x', '+', 'y'
  end

  def test_string_literal_expression
    input = '"hello world!"'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    stmt = program.statements[0]
    literal = stmt.expression
    assert_instance_of Intp::StringLiteral, literal
    assert_equal 'hello world!', literal.value
  end

  def test_parsing_array_literals
    input = '[1, 2 * 2, 3 + 3]'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    stmt = program.statements[0]
    assert_instance_of Intp::ArrayLiteral, stmt.expression

    array = stmt.expression
    assert_equal 3, array.elements.length

    _test_integer_literal array.elements[0], 1
    _test_infix_expression array.elements[1], 2, '*', 2
    _test_infix_expression array.elements[2], 3, '+', 3
  end

  def test_parsing_index_expression
    input = 'myArray[1 + 1]'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    stmt = program.statements[0]
    assert_instance_of Intp::IndexExpression, stmt.expression

    index_exp = stmt.expression
    _test_identifier index_exp.left, 'myArray'
    _test_infix_expression index_exp.index, 1, '+', 1
  end

  def test_parsing_hash_literal_string_keys
    input = '{"one": 1, "two": 2, "three": 3}'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    stmt = program.statements[0]
    assert_instance_of Intp::HashLiteral, stmt.expression

    hash = stmt.expression
    assert_equal 3, hash.pairs.length

    expected = { 'one' => 1, 'two' => 2, 'three' => 3 }
    hash.pairs.each do |k, v|
      assert_instance_of Intp::StringLiteral, k
      _test_integer_literal v, expected[k.to_s]
    end
  end

  def test_parsing_empty_hash_literal
    input = '{}'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    stmt = program.statements[0]
    assert_instance_of Intp::HashLiteral, stmt.expression

    hash = stmt.expression
    assert_equal 0, hash.pairs.length
  end

  def test_parsing_hash_literal_with_expressions
    input = '{"one": 0 + 1, "two": 10 - 8, "three": 15 / 5}'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    stmt = program.statements[0]
    assert_instance_of Intp::HashLiteral, stmt.expression

    hash = stmt.expression
    assert_equal 3, hash.pairs.length

    tests = {
      'one'   => proc { |arg| _test_infix_expression(arg, 0,  '+', 1) },
      'two'   => proc { |arg| _test_infix_expression(arg, 10, '-', 8) },
      'three' => proc { |arg| _test_infix_expression(arg, 15, '/', 5) }
    }

    hash.pairs.each do |pair|
      literal, value = pair
      assert_instance_of Intp::StringLiteral, literal
      test_func = tests[literal.to_s]
      test_func.call(value)
    end
  end

  def check_parse_errors(parser)
    errors = parser.errors
    return if errors.length.zero?

    warn "parser has #{errors.length} errors"
    errors.each { |e| warn "parser error: #{e}" }
  end
end
