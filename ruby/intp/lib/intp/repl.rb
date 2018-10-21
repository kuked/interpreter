require 'pry'
module Intp
  class Repl
    PROMPT = '>> '

    MONKEY_FACE = <<'FACE'
            __,__
   .--.  .-"     "-.  .--.
  / .. \/  .-. .-.  \/ .. \
 | |  '|  /   Y   \  |'  | |
 | \   \  \ > | < /  /   / |
  \ '- ,\.-"""""""-./, -' /
   ''-' /_   ^ ^   _\ '-''
       |  \._   _./  |
       \   \ '~' /   /
        '._ '-=-' _.'
           '-----'
FACE

    def start
      env = Environment.new
      loop do
        print PROMPT
        line = gets
        break if line.nil?

        lexer = Lexer.new(line.chomp)
        parser = Parser.new(lexer)

        program = parser.parse_program
        unless parser.errors.empty?
          print_parse_errors parser.errors
          next
        end

        evaluated = Evaluator.eval(program, env)
        puts evaluated.inspect if evaluated
      end
    end

    def print_parse_errors(errors)
      puts MONKEY_FACE
      puts 'Woops! We ran into some monkey business here!'
      puts ' parse errors:'
      errors.each { |msg| puts "\t#{msg}" }
    end
  end
end
