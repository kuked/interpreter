
module Intp
  class Repl
    PROMPT = '>> '

    def start
      loop do
        print PROMPT
        line = gets
        break if line.nil?
        
        lexer = Lexer.new(line.chomp)
        parser = Parser.new(lexer)
        if parser.errors.length != 0
          puts parser.errors.length
          parser.errors.each { |e| puts e }
          next
        end

        program = parser.parse_program
        puts program
      end
    end
  end
end
