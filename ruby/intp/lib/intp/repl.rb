module Intp
  class Repl
    PROMPT = '>> '

    def start
      env = Environment.new
      loop do
        print PROMPT
        line = gets
        break if line.nil?

        lexer = Lexer.new(line.chomp)
        parser = Parser.new(lexer)
        unless parsers.errors.empty?
          puts parser.errors.length
          parser.errors.each { |e| puts e }
          next
        end

        program = parser.parse_program

        evaluated = Evaluator.eval(program, env)
        puts evaluated.inspect if evaluated
      end
    end
  end
end
