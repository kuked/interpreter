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
!-/*5;
5 < 10 > 5;

if (5 < 10) {
    return true;
} else {
    return false;
}

10 == 10;
10 != 9;
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
      _record.new(token.BANG, "!"),
      _record.new(token.MINUS, "-"),
      _record.new(token.SLASH, "/"),
      _record.new(token.ASTERISK, "*"),
      _record.new(token.INT, "5"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.INT, "5"),
      _record.new(token.LT, "<"),
      _record.new(token.INT, "10"),
      _record.new(token.GT, ">"),
      _record.new(token.INT, "5"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.IF, "if"),
      _record.new(token.LPAREN, "("),
      _record.new(token.INT, "5"),
      _record.new(token.LT, "<"),
      _record.new(token.INT, "10"),
      _record.new(token.RPAREN, ")"),
      _record.new(token.LBRACE, "{"),
      _record.new(token.RETURN, "return"),
      _record.new(token.TRUE, "true"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.RBRACE, "}"),
      _record.new(token.ELSE, "else"),
      _record.new(token.LBRACE, "{"),
      _record.new(token.RETURN, "return"),
      _record.new(token.FALSE, "false"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.RBRACE, "}"),
      _record.new(token.INT, "10"),
      _record.new(token.EQ, "=="),
      _record.new(token.INT, "10"),
      _record.new(token.SEMICOLON, ";"),
      _record.new(token.INT, "10"),
      _record.new(token.NOT_EQ, "!="),
      _record.new(token.INT, "9"),
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
