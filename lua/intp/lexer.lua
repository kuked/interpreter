-- lexer.lua
local token = require("token")

local Lexer = {}

Lexer.new = function(input)
   local l = {}
   l.input = input
   l.position = 1
   l.readPosition = 1
   l.ch = ""

   local readChar = function()
      if l.readPosition > string.len(l.input) then
         l.ch = ""
      else
         l.ch = string.sub(l.input, l.readPosition, l.readPosition)
      end
      l.position = l.readPosition
      l.readPosition = l.readPosition + 1
   end

   local newToken = function(tokenType, literal)
      local tok = {}
      tok.type = tokenType
      tok.literal = literal
      return tok
   end

   local isLetter = function(ch)
      return (string.match(ch, "[%l%u_]") ~= nil)
   end

   local isDigit = function(ch)
      return (string.match(ch, "%d") ~= nil)
   end

   local peekChar = function()
      if l.readPosition >= string.len(l.input) then
         return nil
      else
         return string.sub(l.input, l.readPosition, l.readPosition)
      end
   end

   local readIdentifier = function()
      local position = l.position
      while isLetter(l.ch) do
         readChar()
      end
      return string.sub(l.input, position, l.position - 1)
   end

   local readNumber = function()
      local position = l.position
      while isDigit(l.ch) do
         readChar()
      end
      return string.sub(l.input, position, l.position - 1)
   end

   local skipWhitespace = function()
      while string.match(l.ch, "[ \t\n\r]") do
         readChar()
      end
   end

   l.nextToken = function()
      skipWhitespace()
      local tok = newToken(token.EOF, "")
      if l.ch == "=" then
         if peekChar() == "=" then
            readChar()
            tok = newToken(token.EQ, "==")
         else
            tok = newToken(token.ASSIGN, l.ch)
         end
      elseif l.ch == "!" then
         if peekChar() == "=" then
            readChar()
            tok = newToken(token.NOT_EQ, "!=")
         else
            tok = newToken(token.BANG, l.ch)
         end
      elseif l.ch == ";" then tok = newToken(token.SEMICOLON, l.ch)
      elseif l.ch == "(" then tok = newToken(token.LPAREN, l.ch)
      elseif l.ch == ")" then tok = newToken(token.RPAREN, l.ch)
      elseif l.ch == "," then tok = newToken(token.COMMA, l.ch)
      elseif l.ch == "+" then tok = newToken(token.PLUS, l.ch)
      elseif l.ch == "-" then tok = newToken(token.MINUS, l.ch)
      elseif l.ch == "/" then tok = newToken(token.SLASH, l.ch)
      elseif l.ch == "*" then tok = newToken(token.ASTERISK, l.ch)
      elseif l.ch == "<" then tok = newToken(token.LT, l.ch)
      elseif l.ch == ">" then tok = newToken(token.GT, l.ch)
      elseif l.ch == "{" then tok = newToken(token.LBRACE, l.ch)
      elseif l.ch == "}" then tok = newToken(token.RBRACE, l.ch)
      elseif l.ch == ""  then tok = newToken(token.EOF, l.ch)
      else
         if isLetter(l.ch) then
            local literal = readIdentifier()
            return newToken(token.lookupIdent(literal), literal)
         elseif isDigit(l.ch) then
            return newToken(token.INT, readNumber())
         else
            tok = newToken(token.ILLEGAL, l.ch)
         end
      end
      readChar()
      return tok
   end

   readChar()

   return l
end

return Lexer
