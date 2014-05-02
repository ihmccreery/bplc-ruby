class Ast
  def children
    []
  end

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

  def line
    @id.line
  end
end

###########
# Program #
###########

class Program < Ast
  attr_reader :declarations
  attr_accessor :str_lit_exps

  # @param declarations [Array<Declaration>]
  def initialize(declarations)
    @declarations = expect_array(declarations, Declaration)
  end

  def children
    declarations
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

  def type_specifier
    @type_specifier.type
  end

  def type_specifier_line
    @type_specifier.line
  end
end

class VariableDeclaration < Declaration
  attr_accessor :offset
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

  attr_accessor :local_variable_allocation

  # @param type_specifier [Token]
  # @param id [Token]
  # @param params [Array<Param>]
  # @param body [CompoundStmt]
  def initialize(type_specifier, id, params, body)
    super(type_specifier, id)
    @params = expect_array(params, Param)
    @body = expect(body, CompoundStmt)
  end

  def children
    params + [body]
  end
end

##########
# Params #
##########

class Param < VariableDeclaration
  attr_accessor :offset
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

  def children
    variable_declarations + stmts
  end
end

class ExpStmt < Stmt
  attr_reader :exp

  # @param exp [Exp, nil]
  def initialize(exp)
    @exp = expect(exp, Exp, can_be_nil: true)
  end

  def children
    [exp].compact
  end
end

class ConditionalStmt < Stmt
  attr_reader :condition, :body

  # @param condition [Exp]
  # @param body [Stmt]
  def initialize(condition, body)
    @condition = expect(condition, Exp)
    @body = expect(body, Stmt)
  end

  def children
    [condition, body]
  end
end

class IfStmt < ConditionalStmt
  attr_reader :else_body

  attr_accessor :else_label, :follow_label

  # @param condition [Exp]
  # @param body [Stmt]
  # @param else_body [Stmt, nil]
  def initialize(condition, body, else_body)
    super(condition, body)
    @else_body = expect(else_body, Stmt, can_be_nil: true)
  end

  def children
    [condition, body, else_body].compact
  end
end

class WhileStmt < ConditionalStmt
end

class ReturnStmt < Stmt
  attr_reader :value

  # @param value [Exp, nil]
  def initialize(value)
    @value = expect(value, Exp, can_be_nil: true)
  end

  def children
    [value].compact
  end
end

class WriteStmt < Stmt
  attr_reader :value

  # @param value [Exp]
  def initialize(value)
    @value = expect(value, Exp)
  end

  def children
    [value]
  end
end

class WritelnStmt < Stmt
end

########
# Exps #
########

class Exp < Ast
  attr_accessor :type
end

module BinExp
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

  def children
    [lhs, rhs]
  end

  def line
    @lhs.line
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

  def children
    [lhs, rhs]
  end

  def line
    @lhs.line
  end
end

class RelExp < Exp
  attr_accessor :true_label, :follow_label
  include BinExp
end

class ArithmeticExp < Exp
end

class AddExp < ArithmeticExp
  include BinExp
end

class MulExp < ArithmeticExp
  include BinExp
end

class NegExp < ArithmeticExp
  attr_reader :exp

  # @param exp [Exp]
  def initialize(exp)
    @exp = expect(exp, Exp)
  end

  def children
    [exp]
  end

  def line
    @exp.line
  end
end

###########
# VarExps #
###########

class VarExp < Exp
  include Ided

  attr_accessor :declaration

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

  def children
    [index]
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

  def children
    [index]
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

  def children
    args
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

  def line
    @literal.line
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
  attr_accessor :label
end
