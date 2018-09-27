module Intp
  INTEGER_OBJ = "INTEGER"
  BOOLEAN_OBJ = "BOOLEAN"
  NULL_OBJ    = "NULL"
  
  class Integer
    attr_accessor :value
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
end
