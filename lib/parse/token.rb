module Parse
  class Token
    attr_accessor :token

    def initialize(token)
      @token = token
    end
  end

  class TypeSpecifier < Token
  end

  class Id < Token
  end

  class Semicolon < Token
  end
end
