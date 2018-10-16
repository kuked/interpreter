module Intp
  class Parser
    LOWEST      = 0
    EQUALS      = 1
    LESSGREATER = 2
    SUM         = 3
    PRODUCT     = 4
    PREFIX      = 5
    CALL        = 6
    INDEX       = 7

    @@prefix_parse_fns = {}
    @@infix_parse_fns = {}
    
    attr_accessor :lexer, :cur_token, :peek_token, :errors
    def initialize(lexer)
      @lexer = lexer
      2.times do
        next_token
      end
      @errors = []
  
      register_prefix(Intp::Token::IDENT, :parse_identifier)
      register_prefix(Intp::Token::INT, :parse_integer_literal)
      register_prefix(Intp::Token::BANG, :parse_prefix_expression)
      register_prefix(Intp::Token::MINUS, :parse_prefix_expression)
      register_prefix(Intp::Token::TRUE, :parse_boolean)
      register_prefix(Intp::Token::FALSE, :parse_boolean)
      register_prefix(Intp::Token::LPAREN, :parse_grouped_expression)
      register_prefix(Intp::Token::IF, :parse_if_expression)
      register_prefix(Intp::Token::FUNCTION, :parse_function_literal)
      register_prefix(Intp::Token::STRING, :parse_string_literal)
      register_prefix(Intp::Token::LBRACKET, :parse_array_literal)
      register_prefix(Intp::Token::LBRACE, :parse_hash_literal)
      register_infix(Intp::Token::PLUS, :parse_infix_expression)
      register_infix(Intp::Token::MINUS, :parse_infix_expression)
      register_infix(Intp::Token::SLASH, :parse_infix_expression)
      register_infix(Intp::Token::ASTERISK, :parse_infix_expression)
      register_infix(Intp::Token::EQ, :parse_infix_expression)
      register_infix(Intp::Token::NOT_EQ, :parse_infix_expression)
      register_infix(Intp::Token::LT, :parse_infix_expression)
      register_infix(Intp::Token::GT, :parse_infix_expression)
      register_infix(Intp::Token::LPAREN, :parse_call_expression)
      register_infix(Intp::Token::LBRACKET, :parse_index_expression)
      
      @@precedences ||= {
        Intp::Token::EQ => EQUALS,
        Intp::Token::NOT_EQ => EQUALS,
        Intp::Token::LT => LESSGREATER,
        Intp::Token::GT => LESSGREATER,
        Intp::Token::PLUS => SUM,
        Intp::Token::MINUS => SUM,
        Intp::Token::SLASH => PRODUCT,
        Intp::Token::ASTERISK => PRODUCT,
        Intp::Token::LPAREN => CALL,
        Intp::Token::LBRACKET => INDEX,
      }
    end

    def next_token
      @cur_token = peek_token
      @peek_token = lexer.next_token
    end

    def parse_program
      program = Intp::Program.new([])
      loop do
        break if @cur_token.type == Intp::Token::EOF
        stmt = parse_statement
        if stmt != nil
          program.statements << stmt
        end
        next_token
      end
      program
    end

    private

    def parse_statement
      case @cur_token.type
      when Intp::Token::LET
        return parse_let_statement
      when Intp::Token::RETURN
        return parse_return_statement
      else
        return parse_expression_statement
      end
    end

    def parse_let_statement
      stmt = Intp::LetStatement.new(token: @cur_token)
      unless expect_peek(Intp::Token::IDENT)
        return nil
      end
      stmt.name = Intp::Identifier.new(@cur_token, @cur_token.literal)

      unless expect_peek(Intp::Token::ASSIGN)
        return nil
      end

      next_token

      stmt.value = parse_expression(LOWEST)
      if peek_token_is(Intp::Token::SEMICOLON)
        next_token
      end
      stmt
    end

    def parse_return_statement
      stmt = Intp::ReturnStatement.new
      stmt.token = @cur_token
      next_token

      stmt.return_value = parse_expression(LOWEST)
      if peek_token_is(Intp::Token::SEMICOLON)
        next_token
      end
      
      stmt
    end

    def parse_expression_statement
      stmt = Intp::ExpressionStatement.new
      stmt.token = @cur_token
      stmt.expression = parse_expression(LOWEST)
      next_token if peek_token_is(Intp::Token::SEMICOLON)
      stmt
    end

    def parse_expression(precedence)
      prefix = @@prefix_parse_fns[@cur_token.type]
      return nil unless prefix
      left_exp = prefix.call
      while !peek_token_is(Intp::Token::SEMICOLON) && precedence < peek_precedence
        infix = @@infix_parse_fns[@peek_token.type]
        return left_exp unless infix
        next_token
        left_exp = infix.call(left_exp)
      end
      
      left_exp
    end

    def parse_identifier
      identifier = Intp::Identifier.new(@cur_token, @cur_token.literal)
      identifier
    end

    def parse_integer_literal
      literal = Intp::IntegerLiteral.new
      literal.token = @cur_token
      literal.value = @cur_token.literal.to_i
      literal
    end

    def parse_prefix_expression
      expression = Intp::PrefixExpression.new
      expression.token = @cur_token
      expression.operator = @cur_token.literal
      next_token
      expression.right = parse_expression(PREFIX)
      expression
    end

    def parse_infix_expression(left)
      expression = Intp::InfixExpression.new
      expression.token = @cur_token
      expression.operator = @cur_token.literal
      expression.left = left

      precedence = cur_precedence
      next_token
      expression.right = parse_expression(precedence)
      expression
    end

    def parse_boolean
      boolean = Intp::Boolean.new
      boolean.token = @cur_token
      boolean.value = cur_token_is(Intp::Token::TRUE)
      boolean
    end

    def parse_grouped_expression
      next_token
      exp = parse_expression(LOWEST)
      unless expect_peek(Intp::Token::RPAREN)
        return nil
      end
      exp
    end

    def parse_if_expression
      expression = Intp::IfExpression.new
      expression.token = @cur_token
      return nil unless expect_peek(Intp::Token::LPAREN)
      next_token
      expression.condition = parse_expression(LOWEST)
      return nil unless expect_peek(Intp::Token::RPAREN)
      return nil unless expect_peek(Intp::Token::LBRACE)
      expression.consequence = parse_block_statement

      if peek_token_is(Intp::Token::ELSE)
        next_token

        return nil unless expect_peek(Intp::Token::LBRACE)
        expression.alternative = parse_block_statement
      end
      
      expression
    end

    def parse_block_statement
      block = Intp::BlockStatement.new
      block.token = @cur_token
      block.statements = []
      next_token
      while !cur_token_is(Intp::Token::RBRACE) && !cur_token_is(Intp::Token::EOF)
        stmt = parse_statement
        if stmt
          block.statements << stmt
        end
        next_token
      end
      block
    end

    def parse_function_literal
      lit = Intp::FunctionLiteral.new
      lit.token = @cur_token
      return nil unless expect_peek(Intp::Token::LPAREN)
      lit.parameters = parse_function_parameters
      return nil unless expect_peek(Intp::Token::LBRACE)
      lit.body = parse_block_statement
      lit
    end

    def parse_string_literal
      Intp::StringLiteral.new(@cur_token, @cur_token.literal)
    end

    def parse_array_literal
      token = @cur_token
      elements = parse_expression_list(Intp::Token::RBRACKET)
      Intp::ArrayLiteral.new(token, elements)
    end

    def parse_function_parameters
      identifiers = []
      if peek_token_is(Intp::Token::RPAREN)
        next_token
        return identifiers
      end
      next_token
      ident = Intp::Identifier.new(@cur_token, @cur_token.literal)
      identifiers << ident

      while peek_token_is(Intp::Token::COMMA)
        next_token
        next_token
        ident = Intp::Identifier.new(@cur_token, @cur_token.literal)
        identifiers << ident      
      end
      return nil unless expect_peek(Intp::Token::RPAREN)
      identifiers
    end

    def parse_call_expression(function)
      exp = Intp::CallExpression.new
      exp.token = @cur_token
      exp.function = function
      exp.arguments = parse_expression_list(Intp::Token::RPAREN)
      exp
    end

    def parse_call_arguments
      if peek_token_is(Intp::Token::RPAREN)
        next_token
        return []
      end
      next_token
      args = []
      args << parse_expression(LOWEST)
      while peek_token_is(Intp::Token::COMMA)
        next_token
        next_token
        args << parse_expression(LOWEST)
      end
      return nil unless expect_peek(Intp::Token::RPAREN)
      args
    end

    def parse_expression_list(token)
      list = []
      if peek_token_is(token)
        next_token
        return list
      end

      next_token
      list << parse_expression(LOWEST)
      while peek_token_is(Intp::Token::COMMA)
        next_token
        next_token
        list << parse_expression(LOWEST)
      end
      return nil unless expect_peek(token)
      list
    end

    def parse_index_expression(left)
      exp = Intp::IndexExpression.new
      exp.token = @cur_token
      exp.left = left

      next_token
      exp.index = parse_expression(LOWEST)
      return nil unless expect_peek(Intp::Token::RBRACKET)

      exp
    end

    def parse_hash_literal
      hash = Intp::HashLiteral.new(@cur_token, {})
      until peek_token_is(Intp::Token::RBRACE)
        next_token
        key = parse_expression(LOWEST)
        return nil unless expect_peek(Intp::Token::COLON)

        next_token
        value = parse_expression(LOWEST)

        hash.pairs[key] = value
        return nil if (!peek_token_is(Intp::Token::RBRACE) && !expect_peek(Intp::Token::COMMA))
      end

      return nil unless expect_peek(Intp::Token::RBRACE)

      hash
    end

    def cur_token_is(type)
      @cur_token.type == type
    end

    def peek_token_is(type)
      @peek_token.type == type
    end

    def expect_peek(type)
      if peek_token_is(type)
        next_token
        true
      else
        peek_error(type)
        false
      end
    end

    def peek_error(type)
      @errors.append(
        "expected next token to be #{type}, got #{@peek_token.type} instead" 
      )
    end

    def register_prefix(type, fn)
      @@prefix_parse_fns[type] = method(fn)
    end

    def register_infix(type, fn)
      @@infix_parse_fns[type] = method(fn)
    end

    def peek_precedence
      @@precedences[@peek_token.type] || LOWEST
    end

    def cur_precedence
      @@precedences[@cur_token.type] || LOWEST
    end
  end
end
