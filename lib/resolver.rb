require 'symbol_table'

class Resolver
  def initialize(program)
    @program = program
  end

  def resolve
    symbol_table = SymbolTable.new(nil)
    @program.declarations.each do |d|
      symbol_table.add_symbol(d.id, d)
      r(d, symbol_table)
    end
  end

  private

  def r(ast, symbol_table)
    if ast.is_a? CompoundStmt
      symbol_table = r_compound_stmt(ast, symbol_table)
    elsif ast.is_a? VarExp
      r_var_exp(ast, symbol_table)
    end

    ast.children.each do |child|
      r(child, symbol_table)
    end
  end

  def r_compound_stmt(ast, symbol_table)
    symbol_table = SymbolTable.new(symbol_table)
    ast.variable_declarations.each do |d|
      symbol_table.add_symbol(d.id, d)
    end
    ast.stmts.each do |s|
      r(s, symbol_table)
    end
    return symbol_table
  end

  def r_var_exp(ast, symbol_table)
    declaration = symbol_table.get_symbol(ast.id)
    if declaration
      ast.declaration = declaration
    else
      raise SyntaxError, "undeclared variable #{ast.id}"
    end
  end
end
