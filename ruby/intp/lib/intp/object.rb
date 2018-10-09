module Intp
  INTEGER_OBJ      = "INTEGER"
  BOOLEAN_OBJ      = "BOOLEAN"
  NULL_OBJ         = "NULL"
  RETURN_VALUE_OBJ = "RETURN_VALUE"
  ERROR_OBJ        = "ERROR"

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
    attr_accessor :store
    def initialize
      self.store = {}
    end

    def get(name)
      store[name]
    end

    def set(name, val)
      store[name] = val
      val
    end
  end
end
