module Parse
  class VariableDeclaration
    attr_accessor :type_specifier, :id, :semicolon
    def initialize(type_specifier, id, semicolon)
      @type_specifier = type_specifier
      @id = id
      @semicolon = semicolon
    end
  end
end
