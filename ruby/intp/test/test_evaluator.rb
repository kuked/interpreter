require_relative 'helper'

class EvaluatorTest < Minitest::Test
  def do_eval(input)
    l = Intp::Lexer.new(input)
    p = Intp::Parser.new(l)
    program = p.parse_program
    Intp::Evaluator.eval(program, Intp::Environment.new)
  end

  def test_eval_integer_expression
    tests = [
      ['5', 5],
      ['10', 10],
      ['-5', -5],
      ['-10', -10],
      ['5 + 5 + 5 + 5 - 10', 10],
      ['2 * 2 * 2 * 2 * 2', 32],
      ['-50 + 100 + -50', 0],
      ['5 * 2 + 10', 20],
      ['5 + 2 * 10', 25],
      ['20 + 2 * -10', 0],
      ['50 / 2 * 2 + 10', 60],
      ['2 * (5 + 10)', 30],
      ['3 * 3 * 3 + 10', 37],
      ['3 * (3 * 3) + 10', 37],
      ['(5 + 10 * 2 + 15 / 3) * 2 -10', 50]
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_integer_object(evaluated, test[1])
    end
  end

  def test_eval_boolean_expression
    tests = [
      ['true', true],
      ['false', false],
      ['1 < 2', true],
      ['1 > 2', false],
      ['1 < 1', false],
      ['1 > 1', false],
      ['1 == 1', true],
      ['1 != 1', false],
      ['1 == 2', false],
      ['1 != 2', true],
      ['true == true', true],
      ['false == false', true],
      ['true == false', false],
      ['true != false', true],
      ['false != true', true],
      ['(1 < 2) == true', true],
      ['(1 < 2) == false', false],
      ['(1 > 2) == true', false],
      ['(1 > 2) == false', true]
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_boolean_object(evaluated, test[1])
    end
  end

  def test_bang_operator
    tests = [
      ['!true', false],
      ['!false', true],
      ['!5', false],
      ['!!true', true],
      ['!!false', false],
      ['!!5', true]
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_boolean_object(evaluated, test[1])
    end
  end

  def test_if_else_expressions
    tests = [
      ['if (true) { 10 }', 10],
      ['if (false) { 10 }', nil],
      ['if (1) { 10 }', 10],
      ['if (1 < 2) { 10 }', 10],
      ['if (1 > 2) { 10 }', nil],
      ['if (1 > 2) { 10 } else { 20 }', 20],
      ['if (1 < 2) { 10 } else { 20 }', 10]
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
    input = <<INPUT
    if (10 > 1) {
       if (10 > 1) {
          return 10;
       }
       return 1;
    }
INPUT
    tests = [
      ['return 10;', 10],
      ['return 10; 9;', 10],
      ['return 2 * 5; 9;', 10],
      ['9; return 2 * 5; 9;', 10],
      [input, 10]
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_integer_object(evaluated, test[1])
    end
  end

  def test_error_handling
    input = <<INPUT
    if (10 > 1) {
       if (10 > 1) {
          return true + false;
       }
       return 1;
    }
INPUT
    tests = [
      ['5 + true;', 'type mismatch: INTEGER + BOOLEAN'],
      ['5 + true; 5;', 'type mismatch: INTEGER + BOOLEAN'],
      ['-true', 'unknown operator: -BOOLEAN'],
      ['true + false;', 'unknown operator: BOOLEAN + BOOLEAN'],
      ['5; true + false; 5', 'unknown operator: BOOLEAN + BOOLEAN'],
      ['if (10 > 1) { true + false; }', 'unknown operator: BOOLEAN + BOOLEAN'],
      [input, 'unknown operator: BOOLEAN + BOOLEAN'],
      ['foobar', 'identifier not found: foobar'],
      ['"Hello" - "World"', 'unknown operator: STRING - STRING'],
      ['{"name": "Monkey"}[fn(x) { x }];', 'unusable as hash key: FUNCTION']
    ]
    tests.each do |test|
      evaluated = do_eval(test[0])
      assert_instance_of Intp::Error, evaluated
      assert_equal test[1], evaluated.message
    end
  end

  def test_let_statements
    tests = [
      ['let a = 5; a;', 5],
      ['let a = 5 * 5; a;', 25],
      ['let a = 5; let b = a; b;', 5],
      ['let a = 5; let b = a; let c = a + b + 5; c;', 15]
    ]
    tests.each do |test|
      evaluated = do_eval(test[0])
      _test_integer_object(evaluated, test[1])
    end
  end

  def test_function_object
    input = 'fn(x) { x + 2; };'
    evaluated = do_eval(input)
    assert_instance_of Intp::Function, evaluated

    assert_equal 1, evaluated.parameters.length
    assert_equal 'x', evaluated.parameters[0].to_s
    expected_body = '(x + 2)'
    assert_equal expected_body, evaluated.body.to_s
  end

  def test_function_application
    tests = [
      ['let identity = fn(x) { x; }; identity(5);', 5],
      ['let identity = fn(x) { return x; }; identity(5);', 5],
      ['let double = fn(x) { x * 2; }; double(5);', 10],
      ['let add = fn(x, y) { x + y; }; add(5, 5);', 10],
      ['let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));', 20],
      ['fn(x) { x; }(5)', 5]
    ]
    tests.each do |test|
      _test_integer_object(do_eval(test[0]), test[1])
    end
  end

  def test_closures
    input = <<INPUT
    let newAdder = fn(x) {
        fn(y) { x + y };
    };
    let addTwo = newAdder(2);
    addTwo(2);
INPUT
    _test_integer_object(do_eval(input), 4)
  end

  def test_string_literal
    input = '"Hello World!"'
    evaluated = do_eval(input)
    assert_instance_of(Intp::String, evaluated)
    assert_equal 'Hello World!', evaluated.value
  end

  def test_string_concatenation
    input = '"Hello" + " " + "World!"'
    evaluated = do_eval(input)
    assert_instance_of(Intp::String, evaluated)
    assert_equal 'Hello World!', evaluated.value, "String has wrong value. got=#{evaluated.value}"
  end

  def test_builtin_functions
    tests = [
      ['len("")', 0],
      ['len("four")', 4],
      ['len("hello world")', 11],
      ['len(1)', 'argument to `len` not supported, got INTEGER']
    ]
    tests.each do |test|
      evaluated = do_eval(test[0])
      case test[1]
      when Integer
        _test_integer_object evaluated, test[1]
      when String
        unless evaluated.instance_of?(Intp::Error)
          STDERR.puts "object is not Error. got=#{evaluated.class}"
          next
        end
        assert_equal test[1], evaluated.message
      end
    end
  end

  def test_array_literals
    input = '[1, 2 * 2, 3 + 3]'
    evaluated = do_eval(input)

    result = evaluated
    assert_instance_of Intp::Array, result
    assert_equal 3, result.elements.length

    _test_integer_object result.elements[0], 1
    _test_integer_object result.elements[1], 4
    _test_integer_object result.elements[2], 6
  end

  def test_array_index_expression
    tests = [
      ['[1, 2, 3][0]', 1],
      ['[1, 2, 3][1]', 2],
      ['[1, 2, 3][2]', 3],
      ['let i = 0; [1][i];', 1],
      ['[1, 2, 3][1 + 1];', 3],
      ['let myArray = [1, 2, 3]; myArray[2];', 3],
      ['let myArray = [1, 2, 3]; myArray[0] + myArray[1] + myArray[2];', 6],
      ['let myArray = [1, 2, 3]; let i = myArray[0]; myArray[i]', 2],
      ['[1, 2, 3][3]', nil],
      ['[1, 2, 3][-1]', nil]
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      if test[1].nil?
        _test_null_object evaluated
      else
        _test_integer_object evaluated, test[1]
      end
    end
  end

  def test_hash_literals
    input = <<INPUT
    let two = "two";
    {
        "one": 10 - 9,
        "two": 1 + 1,
        "thr" + "ee": 6 / 2,
        4: 4,
        true: 5,
        false: 6
    }
INPUT
    evaluated = do_eval(input)
    assert_instance_of Intp::Hash, evaluated

    expected = {
      Intp::String.new('one').hash_key   => 1,
      Intp::String.new('two').hash_key   => 2,
      Intp::String.new('three').hash_key => 3,
      Intp::Integer.new(4).hash_key      => 4,
      Intp::TRUE.hash_key                => 5,
      Intp::FALSE.hash_key               => 6
    }
    result = evaluated
    assert_equal expected.length, result.pairs.length

    expected.each do |k, v|
      pair = result.pairs[k]
      _test_integer_object pair.value, v
    end
  end

  def test_hash_index_expressions
    tests = [
      ['{"foo": 5}["foo"]', 5],
      ['{"foo": 5}["bar"]', nil],
      ['let key = "foo"; {"foo": 5}[key]', 5],
      ['{}["foo"]', nil],
      ['{5: 5}[5]', 5],
      ['{false: 5}[false]', 5]
    ]

    tests.each do |test|
      evaluated = do_eval(test[0])
      case test[1]
      when Integer
        _test_integer_object evaluated, test[1]
      else
        _test_null_object evaluated
      end
    end
  end
end
