module Intp
  class Evaluator
    def self.eval(node)
      case
      when node.instance_of?(Intp::Program)
        return eval_statements(node.statements)
      when node.instance_of?(Intp::ExpressionStatement)
        return self.eval(node.expression)
      when node.instance_of?(Intp::InfixExpression)
        left = self.eval(node.left)
        right = self.eval(node.right)
        return eval_infix_expression(node.operator, left, right)
      when node.instance_of?(Intp::PrefixExpression)
        right = self.eval(node.right)
        return eval_prefix_expression(node.operator, right)
      when node.instance_of?(Intp::IntegerLiteral)
        return Intp::Integer.new(node.value)
      when node.instance_of?(Intp::Boolean)
        return native_bool_to_boolean_object(node.value)
      end
      nil
    end

    def self.eval_statements(stmts)
      result = nil
      stmts.each do |s|
        result = self.eval(s)
      end
      result
    end

    def self.eval_infix_expression(operator, left, right)
      case
      when left.type == Intp::INTEGER_OBJ && right.type == Intp::INTEGER_OBJ
        return eval_integer_infix_expression(operator, left, right)
      else
        return Intp::NIL
      end
    end

    def self.eval_prefix_expression(operator, right)
      case operator
      when "!"
        return eval_bang_operator_expression(right)
      when "-"
        return eval_minus_prefix_operator_expression(right)
      else
        return Intp::NILL
      end
    end

    def self.eval_bang_operator_expression(right)
      case right
      when Intp::TRUE
        Intp::FALSE
      when Intp::FALSE
        Intp::TRUE
      when Intp::NULL
        Intp::TRUE
      else
        Intp::FALSE
      end
    end

    def self.eval_minus_prefix_operator_expression(right)
      if right.type != Intp::INTEGER_OBJ
        return Intp::NULL
      end
      Intp::Integer.new(-(right.value))
    end

    def self.eval_integer_infix_expression(operator, left, right)
      case operator
      when "+"
        Intp::Integer.new(left.value + right.value)
      when "-"
        Intp::Integer.new(left.value - right.value)
      when "*"
        Intp::Integer.new(left.value * right.value)
      when "/"
        Intp::Integer.new(left.value / right.value)
      else
        Intp::NULL
      end
    end

    def self.native_bool_to_boolean_object(input)
      return input ? Intp::TRUE : Intp::FALSE
    end
  end
end
