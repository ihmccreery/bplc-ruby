module Ast
  class DeclarationList
    attr_accessor :declaration_list, :variable_declaration
    def initialize(declaration_list, variable_declaration)
      @declaration_list = declaration_list
      @variable_declaration = variable_declaration
    end
  end

  class VariableDeclaration
    attr_accessor :type_specifier, :id, :semicolon
    def initialize(type_specifier, id, semicolon)
      @type_specifier = type_specifier
      @id = id
      @semicolon = semicolon
    end
  end

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
