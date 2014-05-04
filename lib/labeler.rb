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
    if ast.is_a? FunctionDeclaration
      index_local_variables(ast)
      ast.params.each_with_index do |p, i|
        p.offset = Constants::PARAMS_FRAME_OFFSET + (Constants::QUADWORD_SIZE * i)
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

  def index_local_variables(ast)
    ast.local_variable_allocation = 0
    i(ast.body, 0, ast)
  end

  def i(ast, starting_offset, parent_function)
    if ast.is_a? CompoundStmt
      ast.variable_declarations.each_with_index do |d, i|
        d.offset = starting_offset - (i + 1) * Constants::QUADWORD_SIZE
      end
      new_offset = starting_offset - ast.variable_declarations.size * Constants::QUADWORD_SIZE
      # reassign parent_function.local_variable_allocation if necessary
      if parent_function.local_variable_allocation > new_offset
        # allocate offset + offset % -16: in case there is an odd number of local
        # variables, we need to allocate an extra empty quadword to keep 16-byte
        # alignment
        parent_function.local_variable_allocation = new_offset + new_offset % -16
      end
      ast.children.each do |c|
        i(c, new_offset, parent_function)
      end
    else
      ast.children.each do |c|
        i(c, starting_offset, parent_function)
      end
    end
  end
end
