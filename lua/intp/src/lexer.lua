-- lexer.lua
local Token = require('token')

local Lexer = {}

Lexer.new = function(input)
   local l = {}
   l.input = input
   l.position = 1
   l.readPosition = 1
   l.ch = ''

   local read_char = function()
      if l.readPosition > string.len(l.input) then
         l.ch = ''
      else
         l.ch = string.sub(l.input, l.readPosition, l.readPosition)
      end
      l.position = l.readPosition
      l.readPosition = l.readPosition + 1
   end

   local new_token = function(tokenType, literal)
      local tok = {}
      tok.type = tokenType
      tok.literal = literal
      return tok
   end

   local is_letter = function(ch)
      return (string.match(ch, '[%l%u_]') ~= nil)
   end

   local is_digit = function(ch)
      return (string.match(ch, '%d') ~= nil)
   end

   local peek_char = function()
      if l.readPosition >= string.len(l.input) then
         return nil
      else
         return string.sub(l.input, l.readPosition, l.readPosition)
      end
   end

   local read_identifier = function()
      local position = l.position
      while is_letter(l.ch) do
         read_char()
      end
      return string.sub(l.input, position, l.position - 1)
   end

   local read_number = function()
      local position = l.position
      while is_digit(l.ch) do
         read_char()
      end
      return string.sub(l.input, position, l.position - 1)
   end

   local skip_whitespace = function()
      while string.match(l.ch, '[ \t\n\r]') do
         read_char()
      end
   end

   l.next_token = function()
      skip_whitespace()
      local tok = new_token(Token.EOF, '')
      if l.ch == '=' then
         if peek_char() == '=' then
            read_char()
            tok = new_token(Token.EQ, '==')
         else
            tok = new_token(Token.ASSIGN, l.ch)
         end
      elseif l.ch == '!' then
         if peek_char() == '=' then
            read_char()
            tok = new_token(Token.NOT_EQ, '!=')
         else
            tok = new_token(Token.BANG, l.ch)
         end
      elseif l.ch == ';' then tok = new_token(Token.SEMICOLON, l.ch)
      elseif l.ch == '(' then tok = new_token(Token.LPAREN, l.ch)
      elseif l.ch == ')' then tok = new_token(Token.RPAREN, l.ch)
      elseif l.ch == ',' then tok = new_token(Token.COMMA, l.ch)
      elseif l.ch == '+' then tok = new_token(Token.PLUS, l.ch)
      elseif l.ch == '-' then tok = new_token(Token.MINUS, l.ch)
      elseif l.ch == '/' then tok = new_token(Token.SLASH, l.ch)
      elseif l.ch == '*' then tok = new_token(Token.ASTERISK, l.ch)
      elseif l.ch == '<' then tok = new_token(Token.LT, l.ch)
      elseif l.ch == '>' then tok = new_token(Token.GT, l.ch)
      elseif l.ch == '{' then tok = new_token(Token.LBRACE, l.ch)
      elseif l.ch == '}' then tok = new_token(Token.RBRACE, l.ch)
      elseif l.ch == ''  then tok = new_token(Token.EOF, l.ch)
      else
         if is_letter(l.ch) then
            local literal = read_identifier()
            return new_token(Token.lookup_ident(literal), literal)
         elseif is_digit(l.ch) then
            return new_token(Token.INT, read_number())
         else
            tok = new_token(Token.ILLEGAL, l.ch)
         end
      end
      read_char()
      return tok
   end

   read_char()

   return l
end

return Lexer
