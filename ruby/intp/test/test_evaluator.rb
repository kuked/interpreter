require File.expand_path('../helper', __FILE__)

class EvaluatorTest < Minitest::Test
  def do_eval(input)
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    Intp::Evaluator.eval(program)
  end

  def test_eval_integer_expression
    tests = [
      ["5", 5],
      ["10", 10],
      ["-5", -5],
      ["-10", -10],
      ["5 + 5 + 5 + 5 - 10", 10],
      ["2 * 2 * 2 * 2 * 2", 32],
      ["-50 + 100 + -50", 0],
      ["5 * 2 + 10", 20],
      ["5 + 2 * 10", 25],
      ["20 + 2 * -10", 0],
      ["50 / 2 * 2 + 10", 60],
      ["2 * (5 + 10)", 30],
      ["3 * 3 * 3 + 10", 37],
      ["3 * (3 * 3) + 10", 37],
      ["(5 + 10 * 2 + 15 / 3) * 2 -10", 50],
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_integer_object(evaluated, test[1])
    end
  end

  def test_eval_boolean_expression
    tests = [
      ["true", true],
      ["false", false],
      ["1 < 2", true],
      ["1 > 2", false],
      ["1 < 1", false],
      ["1 > 1", false],
      ["1 == 1", true],
      ["1 != 1", false],
      ["1 == 2", false],
      ["1 != 2", true],
      ["true == true", true],
      ["false == false", true],
      ["true == false", false],
      ["true != false", true],
      ["false != true", true],
      ["(1 < 2) == true", true],
      ["(1 < 2) == false", false],
      ["(1 > 2) == true", false],
      ["(1 > 2) == false", true],
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_boolean_object(evaluated, test[1])
    end
  end

  def test_bang_operator
    tests = [
      ["!true", false],
      ["!false", true],
      ["!5", false],
      ["!!true", true],
      ["!!false", false],
      ["!!5", true],
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_boolean_object(evaluated, test[1])
    end
  end

  def test_if_else_expressions
    tests = [
      ["if (true) { 10 }", 10],
      ["if (false) { 10 }", nil],
      ["if (1) { 10 }", 10],
      ["if (1 < 2) { 10 }", 10],
      ["if (1 > 2) { 10 }", nil],
      ["if (1 > 2) { 10 } else { 20 }", 20],
      ["if (1 < 2) { 10 } else { 20 }", 10],
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      if test[1]
        _test_integer_object(evaluated, test[1])
      else
        _test_null_object(evaluated)
      end
    end
  end

  def test_return_statements
    return_statement = <<"EOS"
    if (10 > 1) {
       if (10 > 1) {
          return 10;
       }
       return 1;
    }
EOS
    tests = [
      ["return 10;", 10],
      ["return 10; 9;", 10],
      ["return 2 * 5; 9;", 10],
      ["9; return 2 * 5; 9;", 10],
      [return_statement, 10],
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_integer_object(evaluated, test[1])
    end
  end

  def _test_integer_object(evaluated, expected)
    assert_equal expected, evaluated.value
  end

  def _test_boolean_object(evaluated, expected)
    assert_equal expected, evaluated.value
  end

  def _test_null_object(evaluated)
    assert_equal evaluated, Intp::NULL
  end
end
