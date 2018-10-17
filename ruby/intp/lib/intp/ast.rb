module Intp
  Program = Struct.new(:statements) do
    def token_literal
      statements.length.positive? ? statements[0].token_literal : ''
    end

    def to_s
      out = ''
      statements.each { |stmt| out << stmt.to_s }
      out
    end
  end

  LetStatement = Struct.new(:token, :name, :value, keyword_init: true) do
    def token_literal
      token.literal
    end

    def to_s
      out = ''
      out << token_literal + ' '
      out << name.to_s + ' = '
      out << value.to_s if value
      out << ';'
    end
  end

  Identifier = Struct.new(:token, :value) do
    def token_literal
      token.literal
    end

    def to_s
      value
    end
  end

  class ReturnStatement
    attr_accessor :token, :return_value
    def token_literal
      @token.literal
    end

    def to_s
      out = ''
      out << token_literal + ' '
      out << @return_value.to_s if @return_value
      out << ';'
    end
  end

  class ExpressionStatement
    attr_accessor :token, :expression
    def token_literal
      @token.literal
    end

    def to_s
      @expression.to_s || ''
    end
  end

  class IntegerLiteral
    attr_accessor :token, :value
    def token_literal
      @token.literal
    end

    def to_s
      @token.literal
    end
  end

  class PrefixExpression
    attr_accessor :token, :operator, :right
    def token_literal
      @token.literal
    end

    def to_s
      out = ''
      out << '('
      out << @operator
      out << @right.to_s
      out << ')'
    end
  end

  class InfixExpression
    attr_accessor :token, :left, :operator, :right
    def token_literal
      @token.literal
    end

    def to_s
      out = ''
      out << '('
      out << @left.to_s
      out << ' ' + @operator + ' '
      out << @right.to_s
      out << ')'
    end
  end

  class Boolean
    attr_accessor :token, :value
    def token_literal
      @token.literal
    end

    def to_s
      @token.literal
    end
  end

  class IfExpression
    attr_accessor :token, :condition, :consequence, :alternative
    def token_literal
      @token.literal
    end

    def to_s
      out = ''
      out << 'if'
      out << @condition.to_s
      out << ' '
      out << @consequence.to_s

      if alternative
        out << 'else '
        out << @alternative.to_s
      end

      out
    end
  end

  class BlockStatement
    attr_accessor :token, :statements
    def token_literal
      @token.literal
    end

    def to_s
      out = ''
      @statements.each { |s| out << s.to_s }
      out
    end
  end

  class FunctionLiteral
    attr_accessor :token, :parameters, :body
    def token_literal
      @token.literal
    end

    def to_s
      out = ''
      out << token_literal
      out << '('
      out << @parameters.join(', ')
      out << ')'
      out << @body.to_s
    end
  end

  class CallExpression
    attr_accessor :token, :function, :arguments
    def token_literal
      @token.literal
    end

    def to_s
      out = ''
      out << @function.to_s
      out << '('
      out << @arguments.map(&:to_s).join(', ')
      out << ')'
    end
  end

  class StringLiteral
    attr_accessor :token, :value
    def initialize(token, value)
      @token = token
      @value = value
    end

    def token_literal
      @token.literal
    end

    def to_s
      @token.literal
    end
  end

  class ArrayLiteral
    attr_accessor :token, :elements
    def initialize(token, elements)
      @token = token
      @elements = elements
    end

    def token_literal
      @token.literal
    end

    def to_s
      out = ''
      out << '['
      out << @elements.map(&:to_s).join(', ')
      out << ']'
    end
  end

  class IndexExpression
    attr_accessor :token, :left, :index

    def token_literal
      token.literal
    end

    def to_s
      out = ''
      out << '('
      out << left.to_s
      out << '['
      out << index.to_s
      out << '])'
    end
  end

  class HashLiteral
    attr_accessor :token, :pairs
    def initialize(token, pairs)
      @token = token
      @pairs = pairs
    end

    def token_literal
      @token.literal
    end

    def to_s
      kv = []
      @pairs.each { |k, v| kv.push("#{k}:#{v}") }
      out = ''
      out << '{'
      out << kv.join(', ')
      out << '}'
    end
  end
end
