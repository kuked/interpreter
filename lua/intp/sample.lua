local Token = {}
local hash = { fn = "Hello", let = "World" }

Token.lookupIdent = function(key)
   return hash[key]
end

print(Token.lookupIdent("fn"))
