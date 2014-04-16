require 'symbol_table'

class Resolver
  def initialize(program)
    @program = program
  end

  def resolve
    symbol_table = SymbolTable.new(nil)
    @program.declarations.each do |d|
      add_symbol(symbol_table, d)
      r(d, symbol_table)
    end
    return @program
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
      r_ast(ast, symbol_table)
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
      add_symbol(symbol_table, p)
    end
    ast.body.variable_declarations.each do |d|
      add_symbol(symbol_table, d)
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
      add_symbol(symbol_table, d)
    end
    ast.stmts.each do |s|
      r(s, symbol_table)
    end
  end

  # @param ast [VarExp]
  # @param symbol_table [SymbolTable]
  def r_var_exp(ast, symbol_table)
    unless ast.declaration = symbol_table.get_symbol(ast.id)
      raise BplDeclarationError.new(ast.line), "undeclared variable #{ast.id}"
    end
    ast.children.each do |c|
      r(c, symbol_table)
    end
  end

  # call r on each child of ast
  #
  # @param ast [Ast]
  # @param symbol_table [SymbolTable]
  def r_ast(ast, symbol_table)
    ast.children.each do |c|
      r(c, symbol_table)
    end
  end

  def add_symbol(symbol_table, d)
    unless symbol_table.add_symbol(d.id, d)
      raise BplDeclarationError.new(d.line), "#{d.id} has already been declared"
    end
  end
end
