-- lexer.lua
local token = require("token")

local Lexer = {}

Lexer.new = function(input)
   local obj = {}
   obj.input = input
   obj.nextToken = function(self)
      local tok = {}
      tok.type = token.ASSIGN
      tok.literal = "="
      return tok
   end
   return obj
end

return Lexer
