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

  class Boolean
    attr_accessor :value
    def inspect
      "#{value}"
    end

    def type
      BOOLEAN_OBJ
    end
  end

  class Null
    def inspect
      "null"
    end

    def type
      NULL_OBJ
    end
  end
end
