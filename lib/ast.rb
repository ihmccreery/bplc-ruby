class Ast
end

class Program < Ast
  attr_accessor :declaration_list

  def initialize(declaration_list)
    @declaration_list = declaration_list
  end
end

class DeclarationList < Ast
end
