require File.expand_path('../helper', __FILE__)

class ParserTest < Minitest::Test
  def test_let_statements
    input = <<'EOS'
    let x = 5;
    let y = 10;
    let foobar = 838383;
EOS
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)

    program = p.parse_program
    check_parse_errors(p)
    assert program != nil

    tests = [
      ['x'],
      ['y'],
      ['foobar'],
    ]
    tests.each_with_index do |test, i|
      stmt = program.statements[i] 
      assert_equal stmt.token_literal, 'let'
      let_stmt = stmt
      assert_equal let_stmt.name.value, test[0]
      assert_equal let_stmt.name.token_literal, test[0]
    end
  end

  def test_return_statements
    input = <<'EOS'
    return 5;
    return 10;
    return 993322;
EOS
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)

    program = p.parse_program
    check_parse_errors(p)
    assert_equal 3, program.statements.length

    program.statements.each do |stmt|
      return_stmt = stmt
      assert_equal return_stmt.token_literal, "return"
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

    ident = stmt.expression
    assert_equal ident.value, 'foobar'
    assert_equal ident.token_literal, 'foobar'
  end

  def test_integer_literal_expression
    input = '5;'
    
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)
    assert_equal 1, program.statements.length

    stmt = program.statements[0]

    literal = stmt.expression
    assert_equal literal.value, 5
    assert_equal literal.token_literal, '5'
  end

  def test_parsing_prefix_expressions
    tests = [
      ['!5;', '!', 5],
      ['-15;', '-', 15],
    ]

    tests.each do |test|
      l = Intp::Lexer.new(test[0])
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal 1, program.statements.length
      stmt = program.statements[0]

      expression = stmt.expression
      assert_equal expression.operator, test[1]
      # TODO
      assert_equal expression.right.value, test[2]
      assert_equal expression.right.token_literal, test[2].to_s
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
    ]

    tests.each do |test|
      l = Intp::Lexer.new(test[0])
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal 1, program.statements.length
      stmt = program.statements[0]

      expression = stmt.expression
      assert_equal expression.left.value, test[1]
      assert_equal expression.operator, test[2]
      assert_equal expression.right.value, test[3]
    end
  end

  def test_operator_precedence_parsing
    tests = [
      ["-a * b", "((-a) * b)"],
      ["!-a", "(!(-a))"],
      ["a + b + c", "((a + b) + c)"],      
      ["a + b - c", "((a + b) - c)"],
      ["a * b * c", "((a * b) * c)"],
      ["a * b / c", "((a * b) / c)"],
      ["a + b / c", "(a + (b / c))"],
      ["a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"],
      ["3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"],
      ["5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"],
      ["5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"],
      ["3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"],
      ["1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"],
      ["(5 + 5) * 2", "((5 + 5) * 2)"],
      ["2 / (5 + 5)", "(2 / (5 + 5))"],
      ["-(5 + 5)", "(-(5 + 5))"],
      ["!(true == true)", "(!(true == true))"],
      ["a + add(b * c) + d", "((a + add((b * c))) + d)"],
      ["add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"],
      ["add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))"],
      ["a * [1, 2, 3, 4][b * c] * d", "((a * ([1, 2, 3, 4][(b * c)])) * d)"],
      ["add(a * b[2], b[1], 2 * [1, 2][1])", "add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))"],
    ]

    tests.each do |test|
      l = Intp::Lexer.new(test[0])
      p = Intp::Parser.new(l)
      program = p.parse_program
      check_parse_errors(p)

      assert_equal test[1], program.to_s
    end
  end

  def test_boolean_expression
    input = 'false'
    
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)
    assert_equal 1, program.statements.length

    stmt = program.statements[0]

    literal = stmt.expression
    assert_equal literal.value, false
    assert_equal literal.token_literal, 'false'

    input = 'true'
    
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)
    assert_equal 1, program.statements.length

    stmt = program.statements[0]

    literal = stmt.expression
    assert_equal literal.value, true
    assert_equal literal.token_literal, 'true'    
  end

  def test_if_expression
    input = 'if (x < y) { x }'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)
    assert_equal 1, program.statements.length
    
    stmt = program.statements[0]
    exp = stmt.expression
    assert_equal 1, exp.consequence.statements.length
    # TODO
  end

  def test_function_literal_parsing
    input = 'fn(x, y) { x + y; }'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    assert_equal 1, program.statements.length
    stmt = program.statements[0]
    function = stmt.expression
    
    assert_equal 2, function.parameters.length
    assert_equal 'x', function.parameters[0].token_literal
    assert_equal 'y', function.parameters[1].token_literal
    
    assert_equal 1, function.body.statements.length
    body_statement = function.body.statements[0]

    assert_equal body_statement.expression.left.value, 'x'
    assert_equal body_statement.expression.operator, '+'
    assert_equal body_statement.expression. right.value, 'y'
  end

  def test_string_literal
    input = '"hello world!"'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    stmt = program.statements[0]
    literal = stmt.expression
    assert_equal "hello world!", literal.value
  end

  def test_array_literal
    input = '[1, 2 * 2, 3 + 3]'
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    check_parse_errors(p)

    stmt = program.statements[0]
    assert_instance_of Intp::ArrayLiteral, stmt.expression

    array = stmt.expression
    assert_equal 3, array.elements.length

    assert_equal 1, array.elements[0].value
    # TODO
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
    assert_equal 'myArray', index_exp.left.value

    # TODO
    assert_equal 1, index_exp.index.left.value
    assert_equal '+', index_exp.index.operator
    assert_equal 1, index_exp.index.right.value
  end

  def check_parse_errors(parser)
    errors = parser.errors
    return if errors.length.zero?
    warn "parser has #{errors.length} errors"
    errors.each {|e| warn "parser error: #{e}" }
  end
end
