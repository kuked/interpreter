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
