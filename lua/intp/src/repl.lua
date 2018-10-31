-- repl.lua
local lexer = require("lexer")
local token = require("token")

local Repl = {}

Repl.PROMPT = ">> "

Repl.start = function()
   io.write(Repl.PROMPT)
   while (true) do
      line = io.read()
      if line then
         l = lexer.new(line)
         while (true) do
            tok = l.nextToken()
            if tok.type == token.EOF then
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
