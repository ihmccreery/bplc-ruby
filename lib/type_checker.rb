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
    if ast.is_a? LitExp
      r_lit_exp(ast)
    end
    ast.children.each do |c|
      r(c)
    end
  end

  def r_lit_exp(ast)
    if ast.is_a? StrLitExp
      ast.type = :str
    else
      ast.type = :int
    end
  end
end
