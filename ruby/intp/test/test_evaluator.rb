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
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      check_integer_object(evaluated, test[1])
    end
  end
end
