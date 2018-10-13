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
              when Intp::String
                Intp::Integer.new(args[0].value.length)
              else
                Intp::Evaluator.new_error("argument to `len` not supported, got #{args[0].type}")
              end
            end
          },
        )
      }

      def fetch(function_name)
        @@builtins[function_name]
      end
    end
  end
end
