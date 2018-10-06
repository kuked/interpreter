module Intp
  class Evaluator
    def self.eval(node)
      case
      when node.instance_of?(Intp::Program)
        eval_statements(node.statements)
      when node.instance_of?(Intp::ExpressionStatement)
        self.eval(node.expression)
      when node.instance_of?(Intp::InfixExpression)
        left = self.eval(node.left)
        right = self.eval(node.right)
        eval_infix_expression(node.operator, left, right)
      when node.instance_of?(Intp::PrefixExpression)
        right = self.eval(node.right)
        eval_prefix_expression(node.operator, right)
      when node.instance_of?(Intp::IntegerLiteral)
        Intp::Integer.new(node.value)
      when node.instance_of?(Intp::Boolean)
        native_bool_to_boolean_object(node.value)
      when node.instance_of?(Intp::BlockStatement)
        eval_statements(node.statements)
      when node.instance_of?(Intp::IfExpression)
        eval_if_expression(node)
      else
        nil
      end
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
        eval_integer_infix_expression(operator, left, right)
      when operator == "=="
        native_bool_to_boolean_object(left == right)
      when operator == "!="
        native_bool_to_boolean_object(left != right)
      else
        Intp::NIL
      end
    end

    def self.eval_prefix_expression(operator, right)
      case operator
      when "!"
        eval_bang_operator_expression(right)
      when "-"
        eval_minus_prefix_operator_expression(right)
      else
        Intp::NILL
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
      when "<"
        native_bool_to_boolean_object(left.value < right.value)
      when ">"
        native_bool_to_boolean_object(left.value > right.value)
      when "=="
        native_bool_to_boolean_object(left.value == right.value)
      when "!="
        native_bool_to_boolean_object(left.value != right.value)
      else
        Intp::NULL
      end
    end

    def self.eval_if_expression(ie)
      condition = self.eval(ie.condition)
      if is_truthy(condition)
        self.eval(ie.consequence)
      elsif ie.alternative != nil
        self.eval(ie.alternative)
      else
        Intp::NULL
      end
    end

    def self.native_bool_to_boolean_object(input)
      input ? Intp::TRUE : Intp::FALSE
    end

    def self.is_truthy(obj)
      case obj
      when Intp::NULL
        false
      when Intp::TRUE
        true
      when Intp::FALSE
        false
      else
        true
      end
    end
  end
end
