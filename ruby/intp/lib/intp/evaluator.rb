module Intp
  class Evaluator
    def self.eval(node, env)
      case node
      when Intp::Program
        eval_program(node, env)
      when Intp::ExpressionStatement
        self.eval(node.expression, env)
      when Intp::InfixExpression
        left = self.eval(node.left, env)
        return left if is_error(left)
        right = self.eval(node.right, env)
        return right if is_error(right)
        eval_infix_expression(node.operator, left, right)
      when Intp::PrefixExpression
        right = self.eval(node.right, env)
        is_error(right) ? right : eval_prefix_expression(node.operator, right)
      when Intp::IntegerLiteral
        Intp::Integer.new(node.value)
      when Intp::Boolean
        native_bool_to_boolean_object(node.value)
      when Intp::BlockStatement
        eval_block_statement(node, env)
      when Intp::IfExpression
        eval_if_expression(node, env)
      when Intp::ReturnStatement
        val = self.eval(node.return_value, env)
        is_error(val) ? val : Intp::ReturnValue.new(val)
      when Intp::LetStatement
        val = self.eval(node.value, env)
        return val if is_error(val)
        env.set(node.name.value, val)
      when Intp::Identifier
        eval_identifier(node, env)
      when Intp::FunctionLiteral
        params = node.parameters
        body = node.body
        Intp::Function.new(params, body, env)
      when Intp::CallExpression
        function = self.eval(node.function, env)
        return function if is_error(function)
        args = eval_expression(node.arguments, env)
        if args.length == 1 && is_error(args[0])
          return args[0]
        end
        apply_function(function, args)
      when Intp::StringLiteral
        Intp::String.new(node.value)
      when Intp::ArrayLiteral
        elements = eval_expression(node.elements, env)
        return elements[0] if (elements.length == 1 && is_error(elements[0]))
        Intp::Array.new(elements)
      when Intp::IndexExpression
        left = self.eval(node.left, env)
        return left if is_error(left)
        index = self.eval(node.index, env)
        return index if is_error(index)

        eval_index_expression(left, index)
      when Intp::HashLiteral
        eval_hash_literal(node, env)
      else
        nil
      end
    end

    private

    def self.eval_program(program, env)
      result = nil
      program.statements.each do |statement|
        result = self.eval(statement, env)
        case result
        when Intp::ReturnValue
          return result.value
        when Intp::Error
          return result
        end
      end
      result
    end

    def self.eval_statements(stmts, env)
      result = nil
      stmts.each do |s|
        result = self.eval(s, env)

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
      when left.type == Intp::STRING_OBJ && right.type == Intp::STRING_OBJ
        eval_string_infix_expression(operator, left, right)
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

    def self.eval_if_expression(ie, env)
      condition = self.eval(ie.condition, env)
      return condition if is_error(condition)

      if is_truthy(condition)
        self.eval(ie.consequence, env)
      elsif ie.alternative != nil
        self.eval(ie.alternative, env)
      else
        Intp::NULL
      end
    end

    def self.eval_block_statement(block, env)
      result = nil
      block.statements.each do |statement|
        result = self.eval(statement, env)

        if result
          rt = result.type
          if rt == Intp::RETURN_VALUE_OBJ || rt == Intp::ERROR_OBJ
            return result
          end
        end
      end
      result
    end

    def self.eval_identifier(node, env)
      val = env.get(node.value)
      return val if val

      builtin = Intp::Builtins.fetch(node.value)
      builtin ? builtin : new_error("identifier not found: #{node.value}")
    end

    def self.eval_expression(exps, env)
      result = []
      exps.each do |exp|
        evaluated = self.eval(exp, env)
        if is_error(evaluated)
          return evaluated
        end
        result << evaluated
      end
      result
    end

    def self.eval_string_infix_expression(operator, left, right)
      if operator != "+"
        return new_error("unknown operator: #{left.type} #{operator} #{right.type}")
      end
      Intp::String.new(left.value + right.value)
    end

    def self.eval_index_expression(left, index)
      case
      when left.type == Intp::ARRAY_OBJ && index.type == Intp::INTEGER_OBJ
        eval_array_index_expression(left, index)
      when left.type == Intp::HASH_OBJ
        eval_hash_literal_expression(left, index)
      else
        new_error("index operator not supported: #{left.type}")
      end
    end

    def self.eval_array_index_expression(array, index)
      idx = index.value
      max = array.elements.length - 1
      return Intp::NULL if (idx < 0 || idx > max)

      array.elements[idx]
    end

    def self.eval_hash_literal(node, env)
      pairs = {}
      node.pairs.each do |k, v|
        key = self.eval(k, env)
        return key if is_error(key)

        value = self.eval(v, env)
        return value if is_error(value)

        hashed = key.hash_key
        pairs[hashed] = Intp::HashPair.new(key, value)
      end

      Intp::Hash.new(pairs)
    end

    def self.eval_hash_literal_expression(hash, index)
      hash_object = hash
      unless index.respond_to?(:hash_key)
        return new_error("unusable as hash key: #{index.type}")
      end
      pair = hash_object.pairs[index.hash_key]
      return Intp::NULL unless pair

      pair.value
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

    def self.apply_function(fn, args)
      case fn
      when Intp::Function
        extended_env = extend_function_env(fn, args)
        evaluated = self.eval(fn.body, extended_env)
        unwrap_return_value evaluated
      when Intp::Builtin
        fn.fn.call(args)
      else
        new_error("not a function: #{fn.type}")
      end
    end

    def self.extend_function_env(fn, args)
      env = Intp::Environment.new_enclosed_environment(fn.env)
      fn.parameters.each_with_index do |param, i|
        env.set(param.value, args[i])
      end
      env
    end

    def self.unwrap_return_value(obj)
      return obj.value if obj.instance_of?(Intp::ReturnValue)
      obj
    end
  end
end
