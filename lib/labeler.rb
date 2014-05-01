class Labeler
  def initialize(program)
    @program = program
  end

  def label
    @program.str_lit_exps = []

    @string_index = 0
    @rel_index = 0
    @if_index = 0

    r(@program)
    @program
  end

  private

  def r(ast)
    if ast.is_a? StrLitExp
      ast.label = ".str#{@string_index}"
      @program.str_lit_exps << ast
      @string_index += 1
    elsif ast.is_a? RelExp
      ast.true_label = ".rel#{@rel_index}true"
      ast.follow_label = ".rel#{@rel_index}follow"
      @rel_index += 1
    elsif ast.is_a? IfStmt
      ast.else_label = ".if#{@if_index}else"
      ast.follow_label = ".if#{@if_index}follow"
      @if_index += 1
    end
    ast.children.each do |c|
      r(c)
    end
  end
end
