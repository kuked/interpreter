-- repl.lua
local Lexer = require('lexer')
local Token = require('token')

local Repl = {}

Repl.PROMPT = '>> '

Repl.start = function()
   io.write(Repl.PROMPT)
   while (true) do
      line = io.read()
      if line then
         l = Lexer.new(line)
         while (true) do
            tok = l.next_token()
            if tok.type == Token.EOF then
               break
            end
            print(tok.literal)
         end
      else
         return
      end
      io.write(Repl.PROMPT)
   end
end

return Repl
