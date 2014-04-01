class Ast
  private

  def expect(a, klass, can_be_nil=false)
    if can_be_nil && a.nil?
      return a
    else
      raise TypeError, "expected #{klass}, got #{a.class}" unless a.is_a? klass
      return a
    end
  end

  def expect_array(arr, klass)
    raise TypeError, "expected Array of #{klass}, got #{arr.class}" unless arr.is_a? Array
    arr.each do |a|
      expect(a, klass)
    end
    return arr
  end
end

module Ided
  def id
    @id.value
  end
end

###########
# Program #
###########

class Program < Ast
  attr_reader :declarations

  # @param declarations [Array<Declaration>]
  def initialize(declarations)
    @declarations = expect_array(declarations, Declaration)
  end
end

################
# Declarations #
################

class Declaration < Ast
  include Ided

  # @param type_specifier [Token]
  # @param id [Token]
  def initialize(type_specifier, id)
    @type_specifier = expect(type_specifier, Token)
    @id = expect(id, Token)
  end

  def type
    @type_specifier.type
  end
end

class VariableDeclaration < Declaration
end

class SimpleDeclaration < VariableDeclaration
end

class PointerDeclaration < VariableDeclaration
end

class ArrayDeclaration < VariableDeclaration
  # @param type_specifier [Token]
  # @param id [Token]
  # @param size [Token]
  def initialize(type_specifier, id, size)
    super(type_specifier, id)
    @size = expect(size, Token)
  end

  def size
    @size.value.to_i
  end
end

class FunctionDeclaration < Declaration
  attr_reader :params, :body

  # @param type_specifier [Token]
  # @param id [Token]
  # @param params [Array<Param>]
  # @param body [CompoundStmt]
  def initialize(type_specifier, id, params, body)
    super(type_specifier, id)
    @params = expect_array(params, Param)
    @body = expect(body, CompoundStmt)
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
  attr_reader :variable_declarations, :stmts

  # @param variable_declarations [Array<LocalDeclaration>]
  # @param stmts [Array<Stmt>]
  def initialize(variable_declarations, stmts)
    @variable_declarations = expect_array(variable_declarations, VariableDeclaration)
    @stmts = expect_array(stmts, Stmt)
  end
end

class ExpStmt < Stmt
  attr_reader :exp

  # @param exp [Exp, nil]
  def initialize(exp)
    @exp = expect(exp, Exp, can_be_nil: true)
  end
end

class IfStmt < Stmt
  attr_reader :condition, :body, :else_body

  # @param condition [Exp]
  # @param body [Stmt]
  # @param else_body [Stmt, nil]
  def initialize(condition, body, else_body)
    @condition = expect(condition, Exp)
    @body = expect(body, Stmt)
    @else_body = expect(else_body, Stmt, can_be_nil: true)
  end
end

class WhileStmt < Stmt
  attr_reader :condition, :body

  # @param condition [Exp]
  # @param body [Stmt]
  def initialize(condition, body)
    @condition = expect(condition, Exp)
    @body = expect(body, Stmt)
  end
end

class ReturnStmt < Stmt
  attr_reader :value

  # @param value [Exp, nil]
  def initialize(value)
    @value = expect(value, Exp, can_be_nil: true)
  end
end

class WriteStmt < Stmt
  attr_reader :value

  # @param value [Exp]
  def initialize(value)
    @value = expect(value, Exp)
  end
end

class WritelnStmt < Stmt
end

########
# Exps #
########

class Exp < Ast
end

class BinExp < Exp
  attr_reader :lhs, :rhs

  # @param op [Token]
  # @param lhs [Exp]
  # @param rhs [Exp]
  def initialize(op, lhs, rhs)
    @op = expect(op, Token)
    @lhs = expect(lhs, Exp)
    @rhs = expect(rhs, Exp)
  end

  def op
    @op.type
  end
end

class AssignmentExp < Exp
  attr_reader :lhs, :rhs

  # @param lhs [AssignableVarExp]
  # @param rhs [Exp]
  def initialize(lhs, rhs)
    @lhs = expect(lhs, AssignableVarExp)
    @rhs = expect(rhs, Exp)
  end
end

class RelExp < BinExp
end

class AddExp < BinExp
end

class MulExp < BinExp
end

class NegExp < Exp
  attr_reader :exp

  # @param exp [Exp]
  def initialize(exp)
    @exp = expect(exp, Exp)
  end
end

###########
# VarExps #
###########

class VarExp < Exp
  include Ided

  # @param id [Token]
  def initialize(id)
    @id = expect(id, Token)
  end
end

class AssignableVarExp < VarExp
end

class SimpleVarExp < AssignableVarExp
end

class PointerVarExp < AssignableVarExp
end

class ArrayVarExp < AssignableVarExp
  attr_reader :index

  # @param id [Token]
  # @param index [Exp]
  def initialize(id, index)
    super(id)
    @index = expect(index, Exp)
  end
end

class AddrVarExp < VarExp
end

class AddrArrayVarExp < VarExp
  attr_reader :index

  # @param id [Token]
  # @param index [Exp]
  def initialize(id, index)
    super(id)
    @index = expect(index, Exp)
  end
end

class FunCallExp < VarExp
  attr_reader :args

  # @param id [Token]
  # @param index [Array<Exp>]
  def initialize(id, args)
    super(id)
    @args = expect_array(args, Exp)
  end
end

###########
# LitExps #
###########

class LitExp < Exp
  # @param literal [Token]
  def initialize(literal)
    @literal = expect(literal, Token)
  end

  def value
    @literal.value
  end
end

class ReadLitExp < LitExp
end

class NumLitExp < LitExp
  def value
    @literal.value.to_i
  end
end

class StrLitExp < LitExp
end
