class Ast
end

class TokenAst < Ast
  attr_accessor :token

  def initialize(token)
    @token = token
  end
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

class SimpleDeclaration < Declaration
end

class PointerDeclaration < Declaration
end

class ArrayDeclaration < Declaration
  attr_accessor :size

  def initialize(type_specifier, id, size)
    super(type_specifier, id)
    @size = size
  end
end

class TypeSpecifier < TokenAst
end

class Id < TokenAst
end

class Num < TokenAst
end
