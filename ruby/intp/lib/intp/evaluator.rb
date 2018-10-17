module Intp
  class Evaluator
    def self.eval(node, env)
      case node
      when Intp::Program
        eval_program(node, env)
      when Intp::ExpressionStatement
        eval(node.expression, env)
      when Intp::InfixExpression
        left = eval(node.left, env)
        return left if error?(left)

        right = eval(node.right, env)
        return right if error?(right)

        eval_infix_expression(node.operator, left, right)
      when Intp::PrefixExpression
        right = eval(node.right, env)
        error?(right) ? right : eval_prefix_expression(node.operator, right)
      when Intp::IntegerLiteral
        Intp::Integer.new(node.value)
      when Intp::Boolean
        native_bool_to_boolean_object(node.value)
      when Intp::BlockStatement
        eval_block_statement(node, env)
      when Intp::IfExpression
        eval_if_expression(node, env)
      when Intp::ReturnStatement
        val = eval(node.return_value, env)
        error?(val) ? val : Intp::ReturnValue.new(val)
      when Intp::LetStatement
        val = eval(node.value, env)
        return val if error?(val)

        env.set(node.name.value, val)
      when Intp::Identifier
        eval_identifier(node, env)
      when Intp::FunctionLiteral
        params = node.parameters
        body = node.body
        Intp::Function.new(params, body, env)
      when Intp::CallExpression
        function = eval(node.function, env)
        return function if error?(function)

        args = eval_expression(node.arguments, env)
        return args[0] if args.length == 1 && error?(args[0])

        apply_function(function, args)
      when Intp::StringLiteral
        Intp::String.new(node.value)
      when Intp::ArrayLiteral
        elements = eval_expression(node.elements, env)
        return elements[0] if elements.length == 1 && error?(elements[0])

        Intp::Array.new(elements)
      when Intp::IndexExpression
        left = eval(node.left, env)
        return left if error?(left)

        index = eval(node.index, env)
        return index if error?(index)

        eval_index_expression(left, index)
      when Intp::HashLiteral
        eval_hash_literal(node, env)
      end
    end

    def self.new_error(message)
      Intp::Error.new(message)
    end

    class << self
      private

      def eval_program(program, env)
        result = nil
        program.statements.each do |statement|
          result = eval(statement, env)
          case result
          when Intp::ReturnValue
            return result.value
          when Intp::Error
            return result
          end
        end
        result
      end

      def eval_statements(stmts, env)
        result = nil
        stmts.each do |s|
          result = eval(s, env)
          return result.value if result.instance_of?(Intp::ReturnValue)
        end

        result
      end

      def eval_infix_expression(operator, left, right)
        if left.type == Intp::INTEGER_OBJ && right.type == Intp::INTEGER_OBJ
          eval_integer_infix_expression(operator, left, right)
        elsif operator == '=='
          native_bool_to_boolean_object(left == right)
        elsif operator == '!='
          native_bool_to_boolean_object(left != right)
        elsif left.type != right.type
          new_error("type mismatch: #{left.type} #{operator} #{right.type}")
        elsif left.type == Intp::STRING_OBJ && right.type == Intp::STRING_OBJ
          eval_string_infix_expression(operator, left, right)
        else
          new_error("unknown operator: #{left.type} #{operator} #{right.type}")
        end
      end

      def eval_prefix_expression(operator, right)
        case operator
        when '!'
          eval_bang_operator_expression(right)
        when '-'
          eval_minus_prefix_operator_expression(right)
        else
          new_error("unknown operator: #{operator}#{right.type}")
        end
      end

      def eval_bang_operator_expression(right)
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

      def eval_minus_prefix_operator_expression(right)
        if right.type != Intp::INTEGER_OBJ
          return new_error("unknown operator: -#{right.type}")
        end

        Intp::Integer.new(-right.value)
      end

      def eval_integer_infix_expression(operator, left, right)
        case operator
        when '+'
          Intp::Integer.new(left.value + right.value)
        when '-'
          Intp::Integer.new(left.value - right.value)
        when '*'
          Intp::Integer.new(left.value * right.value)
        when '/'
          Intp::Integer.new(left.value / right.value)
        when '<'
          native_bool_to_boolean_object(left.value < right.value)
        when '>'
          native_bool_to_boolean_object(left.value > right.value)
        when '=='
          native_bool_to_boolean_object(left.value == right.value)
        when '!='
          native_bool_to_boolean_object(left.value != right.value)
        else
          new_error("unknown operator: #{left.type} #{operator} #{right.type}")
        end
      end

      def eval_if_expression(exp, env)
        condition = eval(exp.condition, env)
        return condition if error?(condition)

        if truthy? condition
          eval(exp.consequence, env)
        elsif !exp.alternative.nil?
          eval(exp.alternative, env)
        else
          Intp::NULL
        end
      end

      def eval_block_statement(block, env)
        result = nil
        block.statements.each do |statement|
          result = eval(statement, env)

          if result
            rt = result.type
            return result if [Intp::RETURN_VALUE_OBJ, Intp::ERROR_OBJ].include? rt
          end
        end

        result
      end

      def eval_identifier(node, env)
        val = env.get(node.value)
        return val if val

        builtin = Intp::Builtins.fetch(node.value)
        builtin || new_error("identifier not found: #{node.value}")
      end

      def eval_expression(exps, env)
        result = []
        exps.each do |exp|
          evaluated = eval(exp, env)
          return evaluated if error? evaluated

          result << evaluated
        end

        result
      end

      def eval_string_infix_expression(operator, left, right)
        if operator != '+'
          message = "unknown operator: #{left.type} #{operator} #{right.type}"
          return new_error message
        end

        Intp::String.new(left.value + right.value)
      end

      def eval_index_expression(left, index)
        if left.type == Intp::ARRAY_OBJ && index.type == Intp::INTEGER_OBJ
          eval_array_index_expression(left, index)
        elsif left.type == Intp::HASH_OBJ
          eval_hash_literal_expression(left, index)
        else
          new_error("index operator not supported: #{left.type}")
        end
      end

      def eval_array_index_expression(array, index)
        idx = index.value
        max = array.elements.length - 1
        return Intp::NULL if idx.negative? || idx > max

        array.elements[idx]
      end

      def eval_hash_literal(node, env)
        pairs = {}
        node.pairs.each do |k, v|
          key = eval(k, env)
          return key if error?(key)

          value = eval(v, env)
          return value if error?(value)

          hashed = key.hash_key
          pairs[hashed] = Intp::HashPair.new(key, value)
        end

        Intp::Hash.new(pairs)
      end

      def eval_hash_literal_expression(hash, index)
        hash_object = hash
        unless index.respond_to?(:hash_key)
          return new_error("unusable as hash key: #{index.type}")
        end

        pair = hash_object.pairs[index.hash_key]
        return Intp::NULL unless pair

        pair.value
      end

      def native_bool_to_boolean_object(input)
        input ? Intp::TRUE : Intp::FALSE
      end

      def truthy?(obj)
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

      def error?(obj)
        return obj.type == Intp::ERROR_OBJ if obj

        false
      end

      def apply_function(fnc, args)
        case fnc
        when Intp::Function
          extended_env = extend_function_env(fnc, args)
          evaluated = eval(fnc.body, extended_env)
          unwrap_return_value evaluated
        when Intp::Builtin
          fnc.fn.call(args)
        else
          new_error("not a function: #{fnc.type}")
        end
      end

      def extend_function_env(fnc, args)
        env = Intp::Environment.new_enclosed_environment(fnc.env)
        fnc.parameters.each_with_index do |param, i|
          env.set(param.value, args[i])
        end

        env
      end

      def unwrap_return_value(obj)
        return obj.value if obj.instance_of?(Intp::ReturnValue)

        obj
      end
    end
  end
end
