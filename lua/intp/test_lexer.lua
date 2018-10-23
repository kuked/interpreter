-- test_lexer.lua
local luaunit = require('luaunit')
local lexer = require('lexer')
local token = require('token')

local _record = {}
_record.new = function(type, literal)
   local obj = {}
   obj.type = type
   obj.literal = literal
   return obj
end

function testNextToken()
   local input = "=+(){},;"
   
   local tests = {
      _record.new(token.ASSIGN, "="),
      _record.new(token.PLUS, '+'),
      _record.new(token.LPAREN, '('),
      _record.new(token.RPAREN, ')'),
      _record.new(token.LBRACE, '{'),
      _record.new(token.RBRACE, '}'),
      _record.new(token.COMMA, ','),
      _record.new(token.SEMICOLON, ';'),
      _record.new(token.EOF, '')
   }
   
   local l = lexer.new(input)
   for _, t in pairs(tests) do
      local tok = l.nextToken()
      luaunit.assertEquals(tok.type, t.type)
      luaunit.assertEquals(tok.literal, t.literal)
   end
end

os.exit(luaunit.LuaUnit.run())
