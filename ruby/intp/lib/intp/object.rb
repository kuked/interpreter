module Intp
  INTEGER_OBJ      = "INTEGER"
  BOOLEAN_OBJ      = "BOOLEAN"
  NULL_OBJ         = "NULL"
  RETURN_VALUE_OBJ = "RETURN_VALUE"
  ERROR_OBJ        = "ERROR"
  FUNCTION_OBJ     = "FUNCTION"
  STRING_OBJ       = "STRING"
  BUILTIN_OBJ      = "BUILTIN"
  ARRAY_OBJ        = "ARRAY"

  class Integer
    attr_accessor :value
    def initialize(value)
      self.value = value
    end

    def inspect
      "#{value}"
    end

    def type
      INTEGER_OBJ
    end
  end

  class BooleanObject
    attr_accessor :value
    def initialize(value)
      self.value = value
    end

    def inspect
      "#{value}"
    end

    def type
      BOOLEAN_OBJ
    end
  end

  TRUE = BooleanObject.new(true)
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
      self.value = value
    end

    def inspect
      self.value.inspect
    end

    def type
      RETURN_VALUE_OBJ
    end
  end

  class Error
    attr_accessor :message
    def initialize(message)
      self.message = message
    end

    def inspect
      "ERROR: #{self.message}"
    end

    def type
      ERROR_OBJ
    end
  end

  class Environment
    attr_accessor :store, :outer
    def initialize
      self.store = {}
    end

    def get(name)
      obj = store[name]
      if !obj && self.outer
        return self.outer.get(name)
      end
      obj
    end

    def set(name, val)
      store[name] = val
      val
    end

    def self.new_enclosed_environment(outer)
      env = Environment.new
      env.outer = outer
      env
    end
  end

  class Function
    attr_accessor :parameters, :body, :env
    def initialize(parameters, body, env)
      self.parameters = parameters
      self.body = body
      self.env = env
    end

    def inspect
      params = parameters.map(&:to_s)
      out = ''
      out << 'fn'
      out << '('
      out << params.join(', ')
      out << ") {\n"
      out << body.to_s
      out << "\n}"
    end

    def type
      FUNCTION_OBJ
    end
  end

  class String
    attr_accessor :value
    def initialize(value)
      self.value = value
    end

    def type
      STRING_OBJ
    end

    def inspect
      value
    end
  end

  class Builtin
    attr_accessor :fn
    def initialize(fn)
      self.fn = fn
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
      self.elements = elements
    end

    def type
      ARRAY_OBJ
    end

    def inspect
      out = ''
      out << '['
      out << elements.map(&:inspect).join(', ')
      out << ']'
    end
  end
end
