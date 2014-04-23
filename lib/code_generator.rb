class CodeGenerator
  def initialize(program)
    @program = program
  end

  def generate(output)
    output.write('hello!')
  end
end
