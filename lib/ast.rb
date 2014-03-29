class Ast
end

module TokenAst
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def type
    @token.type
  end

  def value
    @token.value
  end
end

###########
# Program #
###########

class Program < Ast
  attr_reader :declarations

  def initialize(declarations)
    @declarations = declarations
  end
end

################
# Declarations #
################

class Declaration < Ast
  attr_reader :type_specifier, :id

  def initialize(type_specifier, id)
    @type_specifier = type_specifier
    @id = id
  end

  def type
    @type_specifier.type
  end

  def symbol
    @id.value
  end
end

class VariableDeclaration < Declaration
end

class SimpleDeclaration < VariableDeclaration
end

class PointerDeclaration < VariableDeclaration
end

class ArrayDeclaration < VariableDeclaration
  def initialize(type_specifier, id, size)
    super(type_specifier, id)
    @size = size
  end

  def size
    @size.value
  end
end

class FunctionDeclaration < Declaration
  attr_reader :params, :body

  def initialize(type_specifier, id, params, body)
    super(type_specifier, id)
    @params = params
    @body = body
  end
end

##########
# Params #
##########

class Param < VariableDeclaration
end

class SimpleParam < Param
end

class PointerParam < Param
end

class ArrayParam < Param
end

##############
# Statements #
##############

class Statement < Ast
end

class CompoundStatement < Statement
  attr_reader :local_declarations, :statements

  def initialize(local_declarations, statements)
    @local_declarations = local_declarations
    @statements = statements
  end
end

class ExpStatement < Statement
  attr_reader :exp

  def initialize(exp)
    @exp = exp
  end
end

class IfStatement < Statement
  attr_reader :condition, :body, :else_body

  def initialize(condition, body, else_body)
    @condition = condition
    @body = body
    @else_body = else_body
  end
end

class WhileStatement < Statement
  attr_reader :condition, :body

  def initialize(condition, body)
    @condition = condition
    @body = body
  end
end

class ReturnStatement < Statement
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class WriteStatement < Statement
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class WritelnStatement < Statement
end

########
# Exps #
########

class Exp < Ast
  include TokenAst
end

#####################
# general terminals #
#####################

class TypeSpecifier < Ast
  include TokenAst
end

class Id < Ast
  include TokenAst
end

class Num < Ast
  include TokenAst

  def value
    @token.value.to_i
  end
end
