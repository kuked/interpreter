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

   l.nextToken = function()
      local tok = newToken(token.EOF, "")
      if     l.ch == "=" then tok = newToken(token.ASSIGN, l.ch)
      elseif l.ch == ";" then tok = newToken(token.SEMICOLON, l.ch)
      elseif l.ch == "(" then tok = newToken(token.LPAREN, l.ch)
      elseif l.ch == ")" then tok = newToken(token.RPAREN, l.ch)
      elseif l.ch == "," then tok = newToken(token.COMMA, l.ch)
      elseif l.ch == "+" then tok = newToken(token.PLUS, l.ch)
      elseif l.ch == "{" then tok = newToken(token.LBRACE, l.ch)
      elseif l.ch == "}" then tok = newToken(token.RBRACE, l.ch)
      else
         tok = newToken(token.EOF, "")
      end
      readChar()
      return tok
   end

   readChar()

   return l
end

return Lexer
