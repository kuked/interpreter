require File.expand_path('../helper', __FILE__)

class EvaluatorTest < Minitest::Test
  def do_eval(input)
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    Intp::Evaluator.eval(program)
  end

  def check_integer_object(evaluated, expected)
    assert_equal expected, evaluated.value
  end
  
  def test_eval_integer_expression
    tests = [
      ["5", 5],
      ["10", 10],
      ["-5", -5],
      ["-10", -10],
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      check_integer_object(evaluated, test[1])
    end
  end

  def test_eval_boolean_expression
    tests = [
      ["true", true],
      ["false", false],
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

  def _test_boolean_object(evaluated, expected)
    assert_equal expected, evaluated.value
  end
end
