require_relative 'object'

module Intp
  class Builtins
    class << self
      @@builtins = {
        'len' => Intp::Builtin.new(
          proc { |args|
            if args.length != 1
              Intp::Evaluator.new_error("wrong number of arguments. got=#{args.length}, want=1")
            else
              case args[0]
              when Intp::Array
                Intp::Integer.new(args[0].elements.length)
              when Intp::String
                Intp::Integer.new(args[0].value.length)
              else
                Intp::Evaluator.new_error("argument to `len` not supported, got #{args[0].type}")
              end
            end
          }
        ),
        'first' => Intp::Builtin.new(
          proc { |args|
            if args.length != 1
              Intp::Evaluator.new_error("wrong number of arguments. got=#{args.length}, want=1")
            elsif args[0].type != Intp::ARRAY_OBJ
              Intp::Evaluator.new_error("argument to `first` must be ARRAY, got #{args[0].typ}")
            else
              arr = args[0]
              if arr.elements.length > 0
                arr.elements[0]
              else
                Intp::NULL
              end
            end
          }
        ),
        'last' => Intp::Builtin.new(
          proc { |args|
            if args.length != 1
              Intp::Evaluator.new_error("wrong number of arguments. got=#{args.length}, want=1")
            elsif args[0].type != Intp::ARRAY_OBJ
              Intp::Evaluator.new_error("argument to `last` must be ARRAY, got #{args[0].type}")
            else
              arr = args[0]
              length = arr.elements.length
              if length > 0
                arr.elements[length-1]
              else
                Intp::NULL
              end
            end
          }
        ),
        'rest' => Intp::Builtin.new(
          proc { |args|
            if args.length != 1
              Intp::Evaluator.new_error("wrong number of arguments. got=#{args.length}, want=1")
            elsif args[0].type != Intp::ARRAY_OBJ
              Intp::Evaluator.new_error("argument to `rest` must be ARRAY, got #{args[0].type}")
            else
              arr = args[0]
              length = arr.elements.length
              if length > 0
                Intp::Array.new(arr.elements[1, length-1])
              else
                Intp::NULL
              end
            end
          }
        ),
        'push' => Intp::Builtin.new(
          proc { |args|
            if args.length != 2
              Intp::Evaluator.new_error("wrong number of arguments. got=#{args.length}, want=2")
            elsif args[0].type != Intp::ARRAY_OBJ
              Intp::Evaluator.new_error("argument to `push` must be ARRAY, got #{args[0].type}")
            else
              arr = args[0]
              new_elements = arr.elements.dup
              Intp::Array.new(new_elements.push args[1])
            end
          }
        ),
      }

      def fetch(function_name)
        @@builtins[function_name]
      end
    end
  end
end
