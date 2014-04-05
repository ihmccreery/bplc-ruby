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
      ast.type
    end
    ast.children.each do |c|
      r(c)
    end
  end
end
