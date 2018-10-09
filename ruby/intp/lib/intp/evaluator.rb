module Intp
  class Evaluator
    def self.eval(node)
      case node
      when Intp::Program
        eval_program(node)
      when Intp::ExpressionStatement
        self.eval(node.expression)
      when Intp::InfixExpression
        left = self.eval(node.left)
        return left if is_error(left)
        right = self.eval(node.right)
        return right if is_error(right)
        eval_infix_expression(node.operator, left, right)
      when Intp::PrefixExpression
        right = self.eval(node.right)
        is_error(right) ? right : eval_prefix_expression(node.operator, right)
      when Intp::IntegerLiteral
        Intp::Integer.new(node.value)
      when Intp::Boolean
        native_bool_to_boolean_object(node.value)
      when Intp::BlockStatement
        eval_block_statement(node)
      when Intp::IfExpression
        eval_if_expression(node)
      when Intp::ReturnStatement
        val = self.eval(node.return_value)
        is_error(val) ? val : Intp::ReturnValue.new(val)
      else
        nil
      end
    end

    private

    def self.eval_program(program)
      result = nil
      program.statements.each do |statement|
        result = self.eval(statement)
        case result
        when Intp::ReturnValue
          return result.value
        when Intp::Error
          return result
        end
      end
      result
    end

    def self.eval_statements(stmts)
      result = nil
      stmts.each do |s|
        result = self.eval(s)

        if result.instance_of?(Intp::ReturnValue)
          return result.value
        end
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
      when left.type != right.type
        new_error("type mismatch: #{left.type} #{operator} #{right.type}")
      else
        new_error("unknown operator: #{left.type} #{operator} #{right.type}")
      end
    end

    def self.eval_prefix_expression(operator, right)
      case operator
      when "!"
        eval_bang_operator_expression(right)
      when "-"
        eval_minus_prefix_operator_expression(right)
      else
        new_error("unknown operator: #{operator}#{right.type}")
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
        return new_error("unknown operator: -#{right.type}")
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
        new_error("unknown operator: #{left.type} #{operator} #{right.type}")
      end
    end

    def self.eval_if_expression(ie)
      condition = self.eval(ie.condition)
      return condition if is_error(condition)

      if is_truthy(condition)
        self.eval(ie.consequence)
      elsif ie.alternative != nil
        self.eval(ie.alternative)
      else
        Intp::NULL
      end
    end

    def self.eval_block_statement(block)
      result = nil
      block.statements.each do |statement|
        result = self.eval(statement)

        if result
          rt = result.type
          if rt == Intp::RETURN_VALUE_OBJ || rt == Intp::ERROR_OBJ
            return result
          end
        end
      end
      result
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

    def self.new_error(message)
      Intp::Error.new(message)
    end

    def self.is_error(obj)
      if obj
        return obj.type == Intp::ERROR_OBJ
      end
      false
    end
  end
end
