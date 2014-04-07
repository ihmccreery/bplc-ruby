class TypeChecker
  def initialize(program)
    @program = program
  end

  def type_check
    r(@program)
    @program
  end

  private

  def r(ast)
    if ast.is_a? VarExp
      r_var_exp(ast)
    elsif ast.is_a? LitExp
      r_lit_exp(ast)
    end
    ast.children.each do |c|
      r(c)
    end
  end

  # @param ast [VarExp]
  def r_var_exp(ast)
    if ast.declaration.is_a? SimpleDeclaration
      r_var_exp_simple_declaration(ast)
    elsif ast.declaration.is_a? PointerDeclaration
      r_var_exp_pointer_declaration(ast)
    elsif ast.declaration.is_a? ArrayDeclaration
      r_var_exp_array_declaration(ast)
    else # ast.declaration.is_a? FunctionDeclaration
      r_var_exp_function_declaration(ast)
    end
  end

  def r_var_exp_simple_declaration(ast)
    type_specifier = ast.declaration.type_specifier
    if ast.is_a? SimpleVarExp
      ast.type = type_specifier
    elsif ast.is_a? PointerVarExp
      raise SyntaxError, "cannot dereference #{type_specifier}"
    elsif ast.is_a? ArrayVarExp
      raise SyntaxError, "cannot index #{type_specifier}"
    elsif ast.is_a? AddrVarExp
      ast.type = ("pointer_" + ast.declaration.type_specifier.to_s).to_sym
    elsif ast.is_a? AddrArrayVarExp
      raise SyntaxError, "cannot index #{type_specifier}"
    end
  end

  def r_var_exp_pointer_declaration(ast)
    type_specifier = ast.declaration.type_specifier
    if ast.is_a? SimpleVarExp
      ast.type = ("pointer_" + ast.declaration.type_specifier.to_s).to_sym
    elsif ast.is_a? PointerVarExp
      ast.type = type_specifier
    elsif ast.is_a? ArrayVarExp
      raise SyntaxError, "cannot index pointer_#{type_specifier}"
    elsif ast.is_a? AddrVarExp
      raise SyntaxError, "cannot reference pointer_#{type_specifier}"
    elsif ast.is_a? AddrArrayVarExp
      raise SyntaxError, "cannot index pointer_#{type_specifier}"
    end
  end

  def r_var_exp_array_declaration(ast)
    type_specifier = ast.declaration.type_specifier
    if ast.is_a? SimpleVarExp
      ast.type = ("array_" + ast.declaration.type_specifier.to_s).to_sym
    elsif ast.is_a? PointerVarExp
      raise SyntaxError, "cannot dereference array_#{type_specifier}"
    elsif ast.is_a? ArrayVarExp
      ast.type = type_specifier
    elsif ast.is_a? AddrVarExp
      raise SyntaxError, "cannot reference array_#{type_specifier}"
    elsif ast.is_a? AddrArrayVarExp
      ast.type = ("pointer_" + ast.declaration.type_specifier.to_s).to_sym
    end
  end

  # @param ast [LitExp]
  def r_lit_exp(ast)
    if ast.is_a? StrLitExp
      ast.type = :string
    else
      ast.type = :int
    end
  end
end
