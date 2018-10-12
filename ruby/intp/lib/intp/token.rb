module Intp
  class Token
    ILLEGAL = 'ILLEGAL'
    EOF     = 'EOF'

    IDENT  = 'IDENT'
    INT    = 'INT'
    STRING = 'STRING'

    ASSIGN    = '='
    PLUS      = '+'
    MINUS     = '-'
    BANG      = '!'
    ASTERISK  = '*'
    SLASH     = '/'
    COMMA     = ','
    SEMICOLON = ';'

    LT = '<'
    GT = '>'

    EQ     = '=='
    NOT_EQ = '!='

    LPAREN = '('
    RPAREN = ')'
    LBRACE = '{'
    RBRACE = '}'

    FUNCTION = 'FUNCTION'
    LET      = 'LET'
    TRUE     = 'TRUE'
    FALSE    = 'FALSE'
    IF       = 'IF'
    ELSE     = 'ELSE'
    RETURN   = 'RETURN'

    attr_accessor :type, :literal

    def initialize(type, literal)
      @type = type
      @literal = literal
    end

    class << self
      @@keywords = {
        'fn'     => FUNCTION,
        'let'    => LET,
        'true'   => TRUE,
        'false'  => FALSE,
        'if'     => IF,
        'else'   => ELSE,
        'return' => RETURN,
      }

      def lookup_ident(ident)
        @@keywords[ident] || IDENT
      end
    end
  end
end
