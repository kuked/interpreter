testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift testdir unless $LOAD_PATH.include?(testdir)

libdir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

require 'minitest/autorun'
require 'intp'
require 'pry'

def _test_integer_object(evaluated, expected)
  assert_equal expected, evaluated.value
end

def _test_boolean_object(evaluated, expected)
  assert_equal expected, evaluated.value
end

def _test_null_object(evaluated)
  assert_equal evaluated, Intp::NULL
end

def _test_identifier(exp, value)
  assert_instance_of Intp::Identifier, exp
  ident = exp
  assert_equal ident.value, value
  assert_equal ident.token_literal, value
end

def _test_literal_expression(exp, expected)
  case expected
  when Integer
    _test_integer_object exp, expected
  when String
    _test_identifier exp, expected
  when TrueClass || FalseClass
    _test_boolean_object exp, expected
  end
end

def _test_let_statement(stmt, name)
  assert_equal 'let', stmt.token_literal
  assert_instance_of Intp::LetStatement, stmt
  let_stmt = stmt
  assert_equal name, let_stmt.name.value
  assert_equal name, let_stmt.name.token_literal
end

def _test_infix_expression(exp, left, operator, right)
  assert_instance_of Intp::InfixExpression, exp

  op_exp = exp
  _test_literal_expression op_exp.left, left
  assert_equal operator, op_exp.operator
  _test_literal_expression op_exp.right, right
end

def _test_integer_literal(lit, value)
  assert_instance_of Intp::IntegerLiteral, lit
  integ = lit
  assert_equal value, integ.value
  assert_equal "#{value}", integ.token_literal
end
