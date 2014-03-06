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
    # the string value of the token
    attr_reader :value

    # the type of token, as a symbol
    attr_reader :type

    # the line from which the Token was generated
    attr_reader :line_number

    def initialize(value, type, line_number)
      @value = value
      @type = type
      @line_number = line_number
    end

    # checks for equality based on the attributes of the Token
    def ==(t)
      (t.class == self.class) && (t.state == self.state)
    end
    alias_method :eql?, :==

    protected

    # list of attributes used for checking equality
    def state
      [@value, @type, @line_number]
    end
  end
end
