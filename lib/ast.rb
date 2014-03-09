class Ast
end

module TokenAst
  attr_accessor :token

  def initialize(token)
    @token = token
  end
end

###########
# Program #
###########

class Program < Ast
  attr_accessor :declaration_list

  def initialize(declaration_list)
    @declaration_list = declaration_list
  end
end

################
# Declarations #
################

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

class VariableDeclaration < Declaration
end

class SimpleDeclaration < VariableDeclaration
end

class PointerDeclaration < VariableDeclaration
end

class ArrayDeclaration < VariableDeclaration
  attr_accessor :size

  def initialize(type_specifier, id, size)
    super(type_specifier, id)
    @size = size
  end
end

class FunctionDeclaration < Declaration
  attr_accessor :params, :body

  def initialize(type_specifier, id, params, body)
    super(type_specifier, id)
    @params = params
    @body = body
  end
end

##########
# Params #
##########

class Params < Ast
end

class VoidParams < Params
  include TokenAst
end

class ParamList < Params
  attr_accessor :param_list, :param

  def initialize(param_list, param)
    @param_list = param_list
    @param = param
  end
end

class Param < Ast
  attr_accessor :type_specifier, :id

  def initialize(type_specifier, id)
    @type_specifier = type_specifier
    @id = id
  end
end

class SimpleParam < Param
end

class PointerParam < Param
end

class ArrayParam < Param
end

#####################
# CompoundStatement #
#####################

class CompoundStatement < Ast
end

############################
# general terminal classes #
############################

class TypeSpecifier < Ast
  include TokenAst
end

class Id < Ast
  include TokenAst
end

class Num < Ast
  include TokenAst
end
