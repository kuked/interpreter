module Intp
  class Lexer
    attr_accessor :input, :position, :read_position, :ch
    def initialize(input)
      @input = input
      @position = 0
      @read_position = 0
      read_char
    end

    def next_token
      skip_whiltespace
      case @ch
      when '='
        if peek_char == '='
          ch = @ch
          read_char
          literal = ch + @ch
          tok = Token.new(Token::EQ, literal)
        else
          tok = Token.new(Token::ASSIGN, @ch)
        end
      when '+'
        tok = Token.new(Token::PLUS, @ch)
      when '-'
        tok = Token.new(Token::MINUS, @ch)
      when '!'
        if peek_char == '='
          ch = @ch
          read_char
          literal = ch + @ch
          tok = Token.new(Token::NOT_EQ, literal)
        else
          tok = Token.new(Token::BANG, @ch)
        end
      when '/'
        tok = Token.new(Token::SLASH, @ch)
      when '*'
        tok = Token.new(Token::ASTERISK, @ch)
      when '<'
        tok = Token.new(Token::LT, @ch)
      when '>'
        tok = Token.new(Token::GT, @ch)
      when ';'
        tok = Token.new(Token::SEMICOLON, @ch)
      when ','
        tok = Token.new(Token::COMMA, @ch)
      when '('
        tok = Token.new(Token::LPAREN, @ch)
      when ')'
        tok = Token.new(Token::RPAREN, @ch)
      when '{'
        tok = Token.new(Token::LBRACE, @ch)
      when '}'
        tok = Token.new(Token::RBRACE, @ch)
      when '['
        tok = Token.new(Token::LBRACKET, @ch)
      when ']'
        tok = Token.new(Token::RBRACKET, @ch)
      when '"'
        tok = Token.new(Token::STRING, read_string)
      when ':'
        tok = Token.new(Token::COLON, @ch)
      when nil
        tok = Token.new(Token::EOF, '')
      else
        if letter?
          literal = read_identifier
          tok = Token.new(Token.lookup_ident(literal), literal)
          return tok
        elsif digit?
          tok = Token.new(Token::INT, read_number)
          return tok
        else
          tok = Token.new(Token::ILLEGAL, @ch)
        end
      end

      read_char
      tok
    end

    private

    def read_char
      @ch = nil
      @ch = @input[@read_position] if @read_position < @input.length
      @position = @read_position
      @read_position += 1
    end

    def peek_char
      if @read_position >= @input.length
        nil
      else
        @input[@read_position]
      end
    end

    def read_identifier
      position = @position
      read_char while letter?
      @input[position, (@position - position)]
    end

    def read_number
      position = @position
      read_char while digit?
      @input[position, (@position - position)]
    end

    def read_string
      position = @position + 1
      loop do
        read_char
        break if @ch == '"' || @ch == ''
      end
      @input[position, (@position - position)]
    end

    def letter?
      @ch =~ /[[:alpha:]]/ || @ch == '_'
    end

    def digit?
      @ch =~ /[[:digit:]]/
    end

    def skip_whiltespace
      read_char while @ch =~ /[ \t\n\r]/
    end
  end
end
