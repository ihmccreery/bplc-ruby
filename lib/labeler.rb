class Labeler
  PARAMS_FRAME_OFFSET = 16.freeze
  QUADWORD_SIZE = 8.freeze

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
    if ast.is_a? FunctionDeclaration
      i(ast.body, 0)
      ast.params.each_with_index do |p, i|
        p.offset = PARAMS_FRAME_OFFSET + (QUADWORD_SIZE * i)
      end
    elsif ast.is_a? StrLitExp
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

  def i(ast, starting_index)
    if ast.is_a? CompoundStmt
      ast.variable_declarations.each_with_index do |d, i|
        d.offset = -1 * (starting_index + i + 1) * QUADWORD_SIZE
      end
      ast.children.each do |c|
        i(c, starting_index + ast.variable_declarations.size)
      end
    else
      ast.children.each do |c|
        i(c, starting_index)
      end
    end
  end
end
