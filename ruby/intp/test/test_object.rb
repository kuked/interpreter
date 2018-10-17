require_relative 'helper'

class ObjectTest < Minitest::Test
  def test_string_hash_key
    hello1 = Intp::String.new('Hello World')
    hello2 = Intp::String.new('Hello World')
    diff1 = Intp::String.new('My name is johnny')
    diff2 = Intp::String.new('My name is johnny')

    assert_equal hello1.hash_key, hello2.hash_key
    assert_equal diff1.hash_key, diff2.hash_key
    refute_equal hello1.hash_key, diff1.hash_key
  end
end
