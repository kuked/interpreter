require File.expand_path('../helper', __FILE__)

class EvaluatorTest < Minitest::Test
  def do_eval(input)
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    Intp::Evaluator.eval(program, Intp::Environment.new)
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

  def test_error_handling
    input = <<"EOS"
    if (10 > 1) {
       if (10 > 1) {
          return true + false;
       }
       return 1;
    }
EOS
    tests = [
      ["5 + true;", "type mismatch: INTEGER + BOOLEAN"],
      ["5 + true; 5;", "type mismatch: INTEGER + BOOLEAN"],
      ["-true", "unknown operator: -BOOLEAN"],
      ["true + false;", "unknown operator: BOOLEAN + BOOLEAN"],
      ["5; true + false; 5", "unknown operator: BOOLEAN + BOOLEAN"],
      ["if (10 > 1) { true + false; }", "unknown operator: BOOLEAN + BOOLEAN"],
      [input, "unknown operator: BOOLEAN + BOOLEAN"],
      ["foobar", "identifier not found: foobar"],
    ]
    tests.each do |test|
      evaluated = do_eval(test[0])
      unless evaluated.instance_of?(Intp::Error)
        print "XXX"
        next
      end

      assert_equal test[1], evaluated.message
    end
  end

  def test_let_statements
    tests = [
      ["let a = 5; a;", 5],
      ["let a = 5 * 5; a;", 25],
      ["let a = 5; let b = a; b;", 5],
      ["let a = 5; let b = a; let c = a + b + 5; c;", 15],
    ]
    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_integer_object(evaluated, test[1])
    end
  end

  def test_function_object
    input = "fn(x) { x + 2; };"
    evaluated = do_eval(input)
    assert_instance_of(Intp::Function, evaluated)

    # XXX
    assert_equal 1, evaluated.parameters.length
    assert_equal "x", evaluated.parameters[0].to_s
    assert_equal "(x + 2)", evaluated.body.to_s
  end

  def test_function_application
    tests = [
      ["let identity = fn(x) { x; }; identity(5);", 5],
      ["let identity = fn(x) { return x; }; identity(5);", 5],
      ["let double = fn(x) { x * 2; }; double(5);", 10],
      ["let add = fn(x, y) { x + y; }; add(5, 5);", 10],
      ["let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));", 20],
      ["fn(x) { x; }(5)", 5],
    ]
    tests.each do |test|
      _test_integer_object(do_eval(test[0]), test[1])
    end
  end

  def test_closures
    input = <<"EOS"
    let newAdder = fn(x) {
        fn(y) { x + y };
    };
    let addTwo = newAdder(2);
    addTwo(2);
EOS
    _test_integer_object(do_eval(input), 4)
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
