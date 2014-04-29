class Labeler
  def initialize(program)
    @program = program
  end

  def label
    label_strings
    @program
  end

  private

  def label_strings
    @program.strs = []
    @string_index = 0
    r(@program)
  end

  def r(ast)
    if ast.is_a? StrLitExp
      ast.label = ".str#{@string_index}"
      @program.strs << ast
      @string_index += 1
    else
      ast.children.each do |c|
        r(c)
      end
    end
  end
end
