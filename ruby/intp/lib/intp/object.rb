require 'digest/md5'

module Intp
  INTEGER_OBJ      = 'INTEGER'
  BOOLEAN_OBJ      = 'BOOLEAN'
  NULL_OBJ         = 'NULL'
  RETURN_VALUE_OBJ = 'RETURN_VALUE'
  ERROR_OBJ        = 'ERROR'
  FUNCTION_OBJ     = 'FUNCTION'
  STRING_OBJ       = 'STRING'
  BUILTIN_OBJ      = 'BUILTIN'
  ARRAY_OBJ        = 'ARRAY'
  HASH_OBJ         = 'HASH'

  class Integer
    attr_accessor :value
    def initialize(value)
      @value = value
    end

    def inspect
      "#{value}"
    end

    def type
      INTEGER_OBJ
    end

    def hash_key
      HashKey.new(type, @value).value
    end
  end

  class BooleanObject
    attr_accessor :value
    def initialize(value)
      @value = value
    end

    def inspect
      "#{value}"
    end

    def type
      BOOLEAN_OBJ
    end

    def hash_key
      HashKey.new(type, @value ? 1 : 0).value
    end
  end
  TRUE  = BooleanObject.new(true)
  FALSE = BooleanObject.new(false)

  class NullObject
    def inspect
      "null"
    end

    def type
      NULL_OBJ
    end
  end
  NULL = NullObject.new

  class ReturnValue
    attr_accessor :value
    def initialize(value)
      @value = value
    end

    def inspect
      @value.inspect
    end

    def type
      RETURN_VALUE_OBJ
    end
  end

  class Error
    attr_accessor :message
    def initialize(message)
      @message = message
    end

    def inspect
      "ERROR: #{@message}"
    end

    def type
      ERROR_OBJ
    end
  end

  class Environment
    attr_accessor :store, :outer
    def initialize(outer=nil)
      @store = {}
      @outer = outer
    end

    def get(name)
      obj = @store[name]
      if !obj && @outer
        return @outer.get(name)
      end
      obj
    end

    def set(name, val)
      @store[name] = val
      val
    end

    def self.new_enclosed_environment(outer)
      env = Environment.new(outer)
      env
    end
  end

  class Function
    attr_accessor :parameters, :body, :env
    def initialize(parameters, body, env)
      @parameters = parameters
      @body = body
      @env = env
    end

    def inspect
      params = @parameters.map(&:to_s)
      out = ''
      out << 'fn'
      out << '('
      out << params.join(', ')
      out << ") {\n"
      out << @body.to_s
      out << "\n}"
    end

    def type
      FUNCTION_OBJ
    end
  end

  class String
    attr_accessor :value
    def initialize(value)
      @value = value
    end

    def type
      STRING_OBJ
    end

    def inspect
      @value
    end

    def hash_key
      HashKey.new(type, Digest::MD5.digest(@value)).value
    end
  end

  class Builtin
    attr_accessor :fn
    def initialize(fn)
      @fn = fn
    end

    def type
      BUILTIN_OBJ
    end

    def inspect
      "builtin function"
    end
  end

  class Array
    attr_accessor :elements
    def initialize(elements)
      @elements = elements
    end

    def type
      ARRAY_OBJ
    end

    def inspect
      out = ''
      out << '['
      out << @elements.map(&:inspect).join(', ')
      out << ']'
    end
  end

  class HashKey
    attr_accessor :type, :value
    def initialize(type, value)
      @type = type
      @value = value
    end

    def ==(other)
      @value == other.value
    end
  end

  class HashPair
    attr_accessor :key, :value
    def initialize(key, value)
      @key = key
      @value = value
    end
  end

  class Hash
    attr_accessor :pairs
    def initialize(pairs)
      @pairs = pairs
    end

    def type
      HASH_OBJ
    end

    def inspect
      kv = []
      @pairs.values.each { |p| kv.push("#{p.key.inspect}: #{p.value.inspect}") }
      out = ''
      out << '{'
      out << kv.join(', ')
      out << '}'
    end
  end
end
