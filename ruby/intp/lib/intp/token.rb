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
    COLON     = ':'
    SEMICOLON = ';'

    LT = '<'
    GT = '>'

    EQ     = '=='
    NOT_EQ = '!='

    LPAREN = '('
    RPAREN = ')'
    LBRACE = '{'
    RBRACE = '}'

    LBRACKET = '['
    RBRACKET = ']'

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
      @@keywords.default = IDENT

      def lookup_ident(ident)
        @@keywords[ident]
      end
    end
  end
end
