class Labeler

  def initialize(program)
    @program = program
  end

  def label
    @program.str_lit_exps = []

    @string_index = 0
    @rel_index = 0
    @if_index = 0
    @while_index = 0

    r(@program)
    @program
  end

  private

  def r(ast)
    if ast.is_a? FunctionDeclaration
      ast.function_label = "_#{ast.id}"
      ast.return_label = ".return_#{ast.id}"
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
    elsif ast.is_a? WhileStmt
      ast.condition_label = ".while#{@while_index}condition"
      ast.follow_label = ".while#{@while_index}follow"
      @while_index += 1
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

  def i(ast, offset, parent_function)
    if ast.is_a? CompoundStmt
      ast.variable_declarations.each do |d|
        if d.is_a? ArrayDeclaration
          offset -= d.size * Constants::QUADWORD_SIZE
        else
          offset -= Constants::QUADWORD_SIZE
        end
        d.offset = offset
      end
      # reassign parent_function.local_variable_allocation if necessary
      if parent_function.local_variable_allocation < -offset
        parent_function.local_variable_allocation = -offset
      end
      ast.children.each do |c|
        i(c, offset, parent_function)
      end
    else
      ast.children.each do |c|
        i(c, offset, parent_function)
      end
    end
  end
end
