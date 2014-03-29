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
  # @return [TypeSpecifier]
  attr_reader :type_specifier
  # @return [Id]
  attr_reader :id

  # @param type_specifier [TypeSpecifier]
  # @param id [Id]
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

#########
# Stmts #
#########

class Stmt < Ast
end

class CompoundStmt < Stmt
  attr_reader :local_declarations, :stmts

  def initialize(local_declarations, stmts)
    @local_declarations = local_declarations
    @stmts = stmts
  end
end

class ExpStmt < Stmt
  attr_reader :exp

  def initialize(exp)
    @exp = exp
  end
end

class IfStmt < Stmt
  attr_reader :condition, :body, :else_body

  def initialize(condition, body, else_body)
    @condition = condition
    @body = body
    @else_body = else_body
  end
end

class WhileStmt < Stmt
  attr_reader :condition, :body

  def initialize(condition, body)
    @condition = condition
    @body = body
  end
end

class ReturnStmt < Stmt
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class WriteStmt < Stmt
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class WritelnStmt < Stmt
end

########
# Exps #
########

class Exp < Ast
end

class AddExp < Exp
  attr_reader :op, :lhs, :rhs

  def initialize(op, lhs, rhs)
    @op = op
    @lhs = lhs
    @rhs = rhs
  end

  def op
    @op.type
  end
end

class MulExp < Exp
  attr_reader :op, :lhs, :rhs

  def initialize(op, lhs, rhs)
    @op = op
    @lhs = lhs
    @rhs = rhs
  end

  def op
    @op.type
  end
end

class NegExp < Exp
  attr_reader :exp

  def initialize(exp)
    @exp = exp
  end
end

class VarExp < Exp
  # @return [Id]
  attr_reader :id

  # @param id [Id]
  def initialize(id)
    @id = id
  end

  def symbol
    @id.value
  end
end

class SimpleVarExp < VarExp
end

class PointerVarExp < VarExp
end

class AddrVarExp < VarExp
end

class ArrayVarExp < VarExp
  def initialize(id, index)
    super(id)
    @index = index
  end

  def index
    @index.value
  end
end

class AddrArrayVarExp < VarExp
  def initialize(id, index)
    super(id)
    @index = index
  end

  def index
    @index.value
  end
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
