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
  attr_accessor :declarations

  def initialize(declarations)
    @declarations = declarations
  end
end

################
# Declarations #
################

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

##############
# Statements #
##############

class CompoundStatement < Ast
  attr_accessor :local_declarations, :statements

  def initialize(local_declarations, statements)
    @local_declarations = local_declarations
    @statements = statements
  end
end

class Statement < Ast
end

class ExpressionStatement < Statement
  attr_accessor :expression

  def initialize(expression)
    @expression = expression
  end
end

###############
# Expressions #
###############

class Expression < Ast
end

class SimpleExpression < Expression
  attr_accessor :e

  def initialize(e)
    @e = e
  end
end

##############
# arithmetic #
##############

class E < Ast
  attr_accessor :add_op, :e, :t

  def initialize(add_op, e, t)
    @add_op = add_op
    @e = e
    @t = t
  end
end

class T < Ast
  attr_accessor :mul_op, :t, :f

  def initialize(mul_op, t, f)
    @mul_op = mul_op
    @t = t
    @f = f
  end
end

class F < Ast
  attr_accessor :factor

  def initialize(factor)
    @factor = factor
  end
end

class MinusF < Ast
  attr_accessor :f

  def initialize(f)
    @f = f
  end
end

class AddressF < F
end

class PointerF < F
end

class SimpleF < F
end

###########
# Factors #
###########

class Factor < Ast
end

class ExpressionFactor < Factor
  attr_accessor :expression

  def initialize(expression)
    @expression = expression
  end
end

class SimpleFactor < Factor
  attr_accessor :id

  def initialize(id)
    @id = id
  end
end

############################
# general terminal classes #
############################

class TypeSpecifier < Ast
  include TokenAst
end

class AddOp < Ast
  include TokenAst
end

class MulOp < Ast
  include TokenAst
end

class Id < Ast
  include TokenAst
end

class Num < Ast
  include TokenAst
end
