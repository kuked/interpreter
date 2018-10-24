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
   local input = [[
let five = 5;
let ten = 10;

let add = fn(x, y) {
  x + y;
};
let result = add(five, ten);
]]
   
   local tests = {
      _record.new(token.LET, "let"),
      _record.new(token.IDENT, "five"),
      _record.new(token.ASSIGN, "="),
      _record.new(token.INT, "5"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.LET, "let"),
      _record.new(token.IDENT, "ten"),
      _record.new(token.ASSIGN, "="),
      _record.new(token.INT, "10"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.LET, "let"),
      _record.new(token.IDENT, "add"),
      _record.new(token.ASSIGN, "="),
      _record.new(token.FUNCTION, "fn"),
      _record.new(token.LPAREN, "("),
      _record.new(token.IDENT, "x"),
      _record.new(token.COMMA, ","),
      _record.new(token.IDENT, "y"),
      _record.new(token.RPAREN, ")"),
      _record.new(token.LBRACE, "{"),
      _record.new(token.IDENT, "x"),
      _record.new(token.PLUS, "+"),
      _record.new(token.IDENT, "y"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.RBRACE, "}"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.LET, "let"),
      _record.new(token.IDENT, "result"),
      _record.new(token.ASSIGN, "="),
      _record.new(token.IDENT, "add"),
      _record.new(token.LPAREN, "("),
      _record.new(token.IDENT, "five"),
      _record.new(token.COMMA, ","),
      _record.new(token.IDENT, "ten"),
      _record.new(token.RPAREN, ")"),
      _record.new(token.SEMICOLON, ";"),
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
