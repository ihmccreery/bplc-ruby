require 'symbol_table'

class Resolver
  def initialize(program)
    @program = program
  end

  def resolve
    symbol_table = SymbolTable.new(nil)
    @program.declarations.each do |d|
      if d.is_a? FunctionDeclaration
        symbol_table.add_fsymbol(d.id, d)
      else
        symbol_table.add_symbol(d.id, d)
      end
      r(d, symbol_table)
    end
  end

  private

  # dispatch to r_klass or r_generic
  #
  # @param ast [Ast]
  # @param st [SymbolTable]
  def r(ast, symbol_table)
    if ast.is_a? FunctionDeclaration
      r_function_declaration(ast, symbol_table)
    elsif ast.is_a? CompoundStmt
      r_compound_stmt(ast, symbol_table)
    elsif ast.is_a? VarExp
      r_var_exp(ast, symbol_table)
    else
      r_children(ast, symbol_table)
    end
  end

  # add parameters and body's variable declarations to a new symbol table and visit
  # body's stmts
  #
  # @param ast [FunctionDeclaration]
  # @param symbol_table [SymbolTable]
  def r_function_declaration(ast, symbol_table)
    symbol_table = SymbolTable.new(symbol_table)
    ast.params.each do |p|
      symbol_table.add_symbol(p.id, p)
    end
    ast.body.variable_declarations.each do |d|
      symbol_table.add_symbol(d.id, d)
    end
    ast.body.stmts.each do |s|
      r(s, symbol_table)
    end
  end

  # add variable declarations to a new symbol table and visit
  # body's stmts
  #
  # @param ast [CompoundStmt]
  # @param symbol_table [SymbolTable] The parent scope's symbol table
  def r_compound_stmt(ast, symbol_table)
    symbol_table = SymbolTable.new(symbol_table)
    ast.variable_declarations.each do |d|
      symbol_table.add_symbol(d.id, d)
    end
    ast.stmts.each do |s|
      r(s, symbol_table)
    end
  end

  # @param ast [VarExp]
  # @param symbol_table [SymbolTable]
  def r_var_exp(ast, symbol_table)
    resolve_var_exp(ast, symbol_table)
    r_children(ast, symbol_table)
  end

  # @param ast [VarExp]
  # @param symbol_table [SymbolTable]
  def resolve_var_exp(ast, symbol_table)
    if ast.is_a? FunCallExp
      ast.declaration = symbol_table.get_fsymbol(ast.id)
    else
      ast.declaration = symbol_table.get_symbol(ast.id)
    end
  end

  # call r on each child of ast
  #
  # @param ast [Ast]
  # @param symbol_table [SymbolTable]
  def r_children(ast, symbol_table)
    ast.children.each do |c|
      r(c, symbol_table)
    end
  end
end
