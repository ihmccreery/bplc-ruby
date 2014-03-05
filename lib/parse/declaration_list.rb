module Parse
  class DeclarationList
    attr_accessor :declaration_list, :variable_declaration
    def initialize(declaration_list, variable_declaration)
      @declaration_list = declaration_list
      @variable_declaration = variable_declaration
    end
  end
end
