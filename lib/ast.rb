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

class ExpressionStatement < Statement
  attr_reader :expression

  def initialize(expression)
    @expression = expression
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

###############
# Expressions #
###############

class Expression < Ast
end

class SimpleExpression < Expression
  attr_reader :e

  def initialize(e)
    @e = e
  end
end

class AssignmentExpression < Expression
  attr_reader :lhs, :rhs

  def initialize(lhs, rhs)
    @lhs = lhs
    @rhs = rhs
  end
end

class Var < Ast
  attr_reader :id

  def initialize(id)
    @id = id
  end
end

class SimpleVar < Var
end

class PointerVar < Var
end

class ArrayVar < Var
  attr_reader :index

  def initialize(id, index)
    super(id)
    @index = index
  end
end

class ComparisonExpression < Expression
  attr_reader :rel_op, :lhs, :rhs

  def initialize(rel_op, lhs, rhs)
    @rel_op = rel_op
    @lhs = lhs
    @rhs = rhs
  end
end

##############
# arithmetic #
##############

class E < Ast
  attr_reader :add_op, :e, :t

  def initialize(add_op, e, t)
    @add_op = add_op
    @e = e
    @t = t
  end
end

class T < Ast
  attr_reader :mul_op, :t, :f

  def initialize(mul_op, t, f)
    @mul_op = mul_op
    @t = t
    @f = f
  end
end

class MinusF < Ast
  attr_reader :f

  def initialize(f)
    @f = f
  end
end

class F < Ast
  attr_reader :factor

  def initialize(factor)
    @factor = factor
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
  attr_reader :expression

  def initialize(expression)
    @expression = expression
  end
end

class FunCallFactor < Factor
  attr_reader :id, :args

  def initialize(id, args)
    @id = id
    @args = args
  end
end

class ReadFactor < Factor
  attr_reader :read

  def initialize(read)
    @read = read
  end
end

class SimpleFactor < Factor
  attr_reader :id

  def initialize(id)
    @id = id
  end
end

class ArrayFactor < Factor
  attr_reader :id, :index

  def initialize(id, index)
    @id = id
    @index = index
  end
end

class NumFactor < Factor
  attr_reader :num

  def initialize(num)
    @num = num
  end
end

class StrFactor < Factor
  attr_reader :str

  def initialize(str)
    @str = str
  end
end

#####################
# general terminals #
#####################

class TypeSpecifier < Ast
  include TokenAst
end

class RelOp < Ast
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

  def value
    @token.value.to_i
  end
end

class Str < Ast
  include TokenAst
end

class Read < Ast
  include TokenAst
end
