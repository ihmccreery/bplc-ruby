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
    if ast.is_a? FunctionDeclaration
      r_function_declaration(ast)
    end
    ast.children.each do |c|
      r(c)
    end
    if ast.is_a? ConditionalStmt
      r_conditional_stmt(ast)
    elsif ast.is_a? WriteStmt
      r_write_stmt(ast)
    elsif ast.is_a? AssignmentExp
      r_assignment_exp(ast)
    elsif ast.is_a? RelExp
      r_rel_exp(ast)
    elsif ast.is_a? ArithmeticExp
      r_arithmetic_exp(ast)
    elsif ast.is_a? VarExp
      r_var_exp(ast)
    elsif ast.is_a? LitExp
      r_lit_exp(ast)
    end
  end

  # @param ast [FunctionDeclaration]
  def r_function_declaration(ast)
    if ast.id == "main"
      raise BplTypeError, "main function must return void" unless ast.type_specifier == :void
      raise BplTypeError, "main function must have void params" unless ast.params.empty?
    end
  end

  # @param ast [ConditionalStmt]
  def r_conditional_stmt(ast)
    raise BplTypeError, "condition must be int" unless ast.condition.type == :int
  end

  # @param ast [WriteStmt]
  def r_write_stmt(ast)
    raise BplTypeError, "can only write int or string" unless [:int, :string].include? ast.value.type
  end

  # @param ast [AssignmentExp]
  def r_assignment_exp(ast)
    raise BplTypeError, "invalid assignment: cannot assign to #{ast.lhs.type}" if [:array_int, :array_string].include? ast.lhs.type
    raise BplTypeError, "invalid assignment: cannot assign #{ast.rhs.type} to #{ast.lhs.type}" unless ast.lhs.type == ast.rhs.type
    ast.type = ast.rhs.type
  end

  # @param ast [RelExp]
  def r_rel_exp(ast)
    raise BplTypeError, "invalid lhs: cannot #{ast.op} #{ast.lhs.type}" unless ast.lhs.type == :int
    raise BplTypeError, "invalid rhs: cannot #{ast.op} #{ast.rhs.type}" unless ast.rhs.type == :int
    ast.type = :int
  end

  # @param ast [ArithmeticExp]
  def r_arithmetic_exp(ast)
    if ast.is_a? NegExp
      raise BplTypeError, "invalid exp: cannot minus #{ast.exp.type}" unless ast.exp.type == :int
    else
      raise BplTypeError, "invalid lhs: cannot #{ast.op} #{ast.lhs.type}" unless ast.lhs.type == :int
      raise BplTypeError, "invalid rhs: cannot #{ast.op} #{ast.rhs.type}" unless ast.rhs.type == :int
    end
    ast.type = :int
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
      raise BplTypeError, "cannot dereference #{type_specifier}"
    elsif ast.is_a? ArrayVarExp
      raise BplTypeError, "cannot index #{type_specifier}"
    elsif ast.is_a? AddrVarExp
      ast.type = ("pointer_" + ast.declaration.type_specifier.to_s).to_sym
    elsif ast.is_a? AddrArrayVarExp
      raise BplTypeError, "cannot index #{type_specifier}"
    end
  end

  def r_var_exp_pointer_declaration(ast)
    type_specifier = ast.declaration.type_specifier
    if ast.is_a? SimpleVarExp
      ast.type = ("pointer_" + ast.declaration.type_specifier.to_s).to_sym
    elsif ast.is_a? PointerVarExp
      ast.type = type_specifier
    elsif ast.is_a? ArrayVarExp
      raise BplTypeError, "cannot index pointer_#{type_specifier}"
    elsif ast.is_a? AddrVarExp
      raise BplTypeError, "cannot reference pointer_#{type_specifier}"
    elsif ast.is_a? AddrArrayVarExp
      raise BplTypeError, "cannot index pointer_#{type_specifier}"
    end
  end

  def r_var_exp_array_declaration(ast)
    type_specifier = ast.declaration.type_specifier
    if ast.is_a? SimpleVarExp
      ast.type = ("array_" + ast.declaration.type_specifier.to_s).to_sym
    elsif ast.is_a? PointerVarExp
      raise BplTypeError, "cannot dereference array_#{type_specifier}"
    elsif ast.is_a? ArrayVarExp
      ast.type = type_specifier
    elsif ast.is_a? AddrVarExp
      raise BplTypeError, "cannot reference array_#{type_specifier}"
    elsif ast.is_a? AddrArrayVarExp
      ast.type = ("pointer_" + ast.declaration.type_specifier.to_s).to_sym
    end
  end

  def r_var_exp_function_declaration(ast)
    raise BplTypeError, "wrong number of arguments in call to #{ast.id}" unless ast.args.size == ast.declaration.params.size
    ast.args.each_with_index do |arg, i|
      param_type = get_param_type(ast.declaration.params[i])
      raise BplTypeError, "bad argument type in call to #{ast.id}: expected #{param_type}, got #{arg.type}" unless arg.type == param_type
    end
    ast.type = ast.declaration.type_specifier
  end

  def get_param_type(param)
    if param.is_a? PointerParam
      ("pointer_" + param.type_specifier.to_s).to_sym
    elsif param.is_a? ArrayParam
      ("array_" + param.type_specifier.to_s).to_sym
    else # param.is_a? SimpleParam
      param.type_specifier
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
