class Ast
end

class Program < Ast
  attr_accessor :declaration_list

  def initialize(declaration_list)
    @declaration_list = declaration_list
  end
end

class DeclarationList < Ast
  attr_accessor :declaration_list, :declaration

  def initialize(declaration_list, declaration)
    @declaration_list = declaration_list
    @declaration = declaration
  end
end

class Declaration < Ast
  attr_accessor :type_specifier, :id

  def initialize(type_specifier, id)
    @type_specifier = type_specifier
    @id = id
  end
end

class TypeSpecifier < Ast
end

class Id < Ast
end
