module Intp
  class Evaluator
    def self.eval(node)
      case
      when node.instance_of?(Intp::Program)
        return eval_statements(node.statements)
      when node.instance_of?(Intp::ExpressionStatement)
        return self.eval(node.expression)
      when node.instance_of?(Intp::IntegerLiteral)
        int = Intp::Integer.new
        int.value = node.value
        return int
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

    def self.native_bool_to_boolean_object(input)
      return input ? Intp::TRUE : Intp::FALSE
    end
  end
end
