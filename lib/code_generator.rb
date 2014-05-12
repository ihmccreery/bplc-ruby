class CodeGenerator

  CONDITIONAL_JUMPS = {lt: "jl",
                       leq: "jle",
                       eq: "je",
                       neq: "jne",
                       geq: "jge",
                       gt: "jg"}

  def initialize(program, output)
    @program = program
    @output = output
  end

  def generate
    r_program(@program)
  end

  private

  def r(ast)
    if ast.is_a? Stmt
      r_stmt(ast)
    elsif ast.is_a? Exp
      r_exp(ast)
    end
  end

  ###########
  # Program #
  ###########

  def r_program(ast)
    generate_header
    # TODO globals
    ast.declarations.each do |d|
      if d.is_a? FunctionDeclaration
        r_function_declaration(d)
      end
    end
    generate_string_section(ast)
  end

  # header and string_section

  def generate_header
    emit(".section","__TEXT,__text,regular,pure_instructions")
    emit(".globl","_main")
    emit(".align","4,0x90")
  end

  def generate_string_section(ast)
    emit_empty_line
    emit(".section","__TEXT,__cstring,cstring_literals")
    generate_io_strings
    ast.str_lit_exps.each do |e|
      emit_label(e.label)
      emit(".asciz","\"#{e.value}\"")
    end
  end

  def generate_io_strings
    emit_label(".WriteIntString")
    emit(".asciz",'"%lld "')
    emit_label(".WriteStringString")
    emit(".asciz",'"%s "')
    emit_label(".WritelnString")
    emit(".asciz",'"\n"')
    emit_label(".ReadString")
    emit(".asciz",'"%d"')
  end

  ########################
  # FunctionDeclarations #
  ########################

  def r_function_declaration(ast)
    emit_empty_line
    emit_label(ast.function_label)
    emit("pushq", "%rbp", "# push old fp onto stack")
    emit("pushq", "%rbx", "# push old rbx onto stack")
    emit("movq", "%rsp, %rbp", "# setup new fp")
    emit("subq", "$#{ast.local_variable_allocation}, %rsp", "# allocate local variables")
    # body
    ast.body.stmts.each do |s|
      r(s)
    end
    emit_label(ast.return_label)
    # should we deallocate local variables by moving fp to sp?
    emit("addq", "$#{ast.local_variable_allocation}, %rsp", "# deallocate local variables")
    emit("popq", "%rbx", "# restore old rbx from stack")
    emit("popq", "%rbp", "# restore old fp from stack")
    emit("ret")
  end

  #########
  # Stmts #
  #########

  def r_stmt(ast)
    if ast.is_a? CompoundStmt
      r_compound_stmt(ast)
    elsif ast.is_a? ExpStmt
      r_exp_stmt(ast)
    elsif ast.is_a? IfStmt
      r_if_stmt(ast)
    elsif ast.is_a? WhileStmt
      r_while_stmt(ast)
    elsif ast.is_a? ReturnStmt
      r_return_stmt(ast)
    elsif ast.is_a? WriteStmt
      r_write_stmt(ast)
    elsif ast.is_a? WritelnStmt
      r_writeln_stmt(ast)
    end
  end

  def r_compound_stmt(ast)
    ast.stmts.each do |s|
      r(s)
    end
  end

  def r_exp_stmt(ast)
    r(ast.exp)
  end

  def r_if_stmt(ast)
    r(ast.condition)
    emit("cmpq", "$0, %rax", "# check to see if rax is 0 (False)")
    if(ast.else_body.nil?)
      emit("jz", ast.follow_label, "# jump to #{ast.follow_label}")
      r(ast.body)
      emit_label(ast.follow_label)
    else
      emit("jz", ast.else_label, "# jump to #{ast.else_label}")
      r(ast.body)
      emit("jmp", ast.follow_label, "# jump to #{ast.follow_label} after completing body")
      emit_label(ast.else_label)
      r(ast.else_body)
      emit_label(ast.follow_label)
    end
  end

  def r_while_stmt(ast)
    emit_label(ast.condition_label)
    r(ast.condition)
    emit("cmpq", "$0, %rax", "# check to see if rax is 0 (False)")
    emit("jz", ast.follow_label, "# jump to #{ast.follow_label}")
    r(ast.body)
    emit("jmp", ast.condition_label, "# jump to #{ast.condition_label} after completing body")
    emit_label(ast.follow_label)
  end

  def r_return_stmt(ast)
    unless ast.value.nil?
      r(ast.value)
    end
    emit("jmp",
         ast.parent_function_declaration.return_label,
         "# jump to return")
  end

  def r_write_stmt(ast)
    r(ast.value)
    emit("movq", "%rax, %rsi", "# load rax into rsi")
    if ast.value.type == :int
      emit("leaq", ".WriteIntString(%rip), %rdi", "# load int formatting string into rdi")
    else
      emit("leaq", ".WriteStringString(%rip), %rdi", "# load string formatting string into rdi")
    end
    with_aligned_stack { emit("callq", "_printf", "# call printf") }
  end

  def r_writeln_stmt(ast)
    emit("leaq", ".WritelnString(%rip), %rdi", "# load formatting string into rdi")
    with_aligned_stack { emit("callq", "_printf", "# call printf") }
  end

  ########
  # Exps #
  ########

  def r_exp(ast)
    if ast.is_a? AssignmentExp
      r_assignment_exp(ast)
    elsif ast.is_a? RelExp
      r_rel_exp(ast)
    elsif ast.is_a? AddExp
      r_add_exp(ast)
    elsif ast.is_a? MulExp
      r_mul_exp(ast)
    elsif ast.is_a? NegExp
      r_neg_exp(ast)
    elsif ast.is_a? VarExp
      r_var_exp(ast)
    elsif ast.is_a? ReadLitExp
      r_read_lit_exp(ast)
    elsif ast.is_a? NumLitExp
      r_num_lit_exp(ast)
    elsif ast.is_a? StrLitExp
      r_str_lit_exp(ast)
    end
  end

  def r_assignment_exp(ast)
    r(ast.rhs)
    emit("pushq", "%rax", "# push rax (rhs) onto stack")
    get_l_value(ast.lhs)
    emit("popq", "(%rax)", "# assign rhs to lhs")
    emit("movq", "(%rax), %rax", "# leave rhs in rax")
  end

  def r_rel_exp(ast)
    r(ast.rhs)
    emit("pushq", "%rax", "# push rax (rhs) onto stack")
    r(ast.lhs)
    emit("cmpq", "(%rsp), %rax", "# compare top of stack to rax")
    emit(CONDITIONAL_JUMPS[ast.op], ast.true_label, "# jump to #{ast.true_label} to resolve True")
    emit("clrq", "%rax", "# move 0 (False) into rax")
    emit("jmp", ast.follow_label, "# jump to #{ast.follow_label} after resolving False")
    emit_label(ast.true_label)
    emit("movq", "$1, %rax", "# move 1 (True) into rax")
    emit_label(ast.follow_label)
    pop
  end

  def r_add_exp(ast)
    r(ast.rhs)
    emit("pushq", "%rax", "# push rax (rhs) onto stack")
    r(ast.lhs)
    if ast.op == :plus
      emit("addq", "(%rsp), %rax", "# add top of stack to rax")
    else
      emit("subq", "(%rsp), %rax", "# subtract top of stack to rax")
    end
    pop
  end

  def r_mul_exp(ast)
    r(ast.rhs)
    emit("pushq", "%rax", "# push rax (rhs) onto stack")
    r(ast.lhs)
    if ast.op == :asterisk
      emit("imulq", "(%rsp)", "# multiply top of stack into rax")
    else # ast.op == :slash or :percent
      emit("cqto", "", "# sign extend rax")
      emit("idivq", "(%rsp)", "# divide top of stack into rax")
      if ast.op == :percent
        emit("movq", "%rdx, %rax", "# move modulo into rax")
      end
    end
    pop
  end

  def r_neg_exp(ast)
    r(ast.exp)
    emit("movq", "%rax, %rbx", "# move rax into rbx")
    emit("movq", "$0, %rax", "# move 0 into rax")
    emit("subq", "%rbx, %rax", "# subtract rbx from rax")
  end

  ###########
  # VarExps #
  ###########

  # TODO refactor
  def r_var_exp(ast)
    if ast.is_a? SimpleVarExp
      r_simple_var_exp(ast)
    elsif ast.is_a? PointerVarExp
      # TODO
    elsif ast.is_a? ArrayVarExp
      r_array_var_exp(ast)
    elsif ast.is_a? AddrVarExp
      # TODO
    elsif ast.is_a? AddrArrayVarExp
      # TODO
    else # ast.is_a? FunCallExp
      r_fun_call_exp(ast)
    end
  end

  def r_simple_var_exp(ast)
    if [:array_int, :array_string].include? ast.type
      get_array_base(ast)
    else
      get_l_value(ast)
      get_r_value
    end
  end

  def r_array_var_exp(ast)
    get_l_value(ast)
    get_r_value
  end

  def r_fun_call_exp(ast)
    with_aligned_stack do
      # add an empty quadword if there is an odd number of arguments to keep
      # 16-byte alignment for a function call
      if ast.args.size.odd?
        emit("pushq", "$0", "# push empty quadword onto stack to maintain alignment with #{ast.args.size} arguments")
      end

      ast.args.reverse_each do |a|
        r(a)
        emit("pushq", "%rax", "# push arg onto stack")
      end
      emit("callq", ast.declaration.function_label, "# call #{ast.id}")

      # pop off size + (size % 2): in case there is an odd number of arguments, we
      # need to pop off the extra empty quadword to keep 16-byte alignment
      pop_size = Constants::QUADWORD_SIZE*(ast.args.size + (ast.args.size % 2))
      emit("addq", "$#{pop_size}, %rsp", "# pop #{ast.args.size} args off the stack")
    end
  end

  ###########
  # LitExps #
  ###########

  def r_read_lit_exp(ast)
    with_aligned_stack do
      emit("subq", "$16, %rsp", "# allocate two quadwords for scanf, (to keep alignment)")
      emit("leaq", "(%rsp), %rsi", "# put scanf storage location into rsi")
      emit("leaq", ".ReadString(%rip), %rdi", "# load int formatting string into rdi")

      emit("callq", "_scanf", "# call scanf")

      emit("popq", "%rax", "# pop storage location into rax")
      emit("addq", "$8, %rsp", "# deallocate the extra space we pushed onto the stack")
    end
  end

  def r_num_lit_exp(ast)
    emit("movq", "$#{ast.value}, %rax", "# load #{ast.value} into rax")
  end

  def r_str_lit_exp(ast)
    emit("leaq", "#{ast.label}(%rip), %rax", "# load \"#{ast.value}\" into rax")
  end

  ###################
  # support methods #
  ###################

  # note that this method never gets called on arrays, because they have no
  # l-values
  def get_l_value(ast)
    if ast.is_a? ArrayVarExp
      get_index_offset(ast)
      emit("movq", "%rax, %rbx", "# move index offset into rbx")
      get_array_base(ast)
      emit("addq", "%rbx, %rax", "# add index offset to #{ast.id} address")
    else
      emit("leaq", "#{ast.declaration.offset}(%rbp), %rax", "# load #{ast.id} address into rax")
    end
  end

  def get_r_value
    emit("movq", "(%rax), %rax", "# convert l-value to r-value")
  end

  def get_index_offset(ast)
    r(ast.index)
    emit("imulq", "$#{Constants::QUADWORD_SIZE}, %rax", "# compute index offset from index")
  end

  def get_array_base(ast)
    # If an array is declared as a parameter rather than a local variable, we
    # add an additional layer of indirection, and must take that into account.
    # We do so by checking whether the declaration is a parameter, and if it is,
    # then we must dereference the value a second time.
    emit("leaq", "#{ast.declaration.offset}(%rbp), %rax", "# load #{ast.id} address into rax")
    if ast.declaration.is_a? ArrayParam
      emit("movq", "(%rax), %rax", "# dereference #{ast.id} (param) into rax")
    end
  end

  def with_aligned_stack
    emit("movq", "%rsp, %rbx", "# store rsp in rbx")
    emit("pushq", "$0", "# push an empty byte on the stack to allocate space for the old stack pointer")
    emit("andq", "$-16, %rsp", "# align the stack to 16 bytes")
    # the stack is now definitely aligned
    emit("movq", "%rbx, (%rsp)", "# move rbx (the old stack pointer,) into allocated space on the stack")

    yield

    emit("popq", "%rsp", "# pop old stack pointer as it was before the stack alignment")
  end

  def pop
    emit("addq", "$8, %rsp", "# pop the stack")
  end

  def emit(instruction, arguments="", comment="")
    write("\t#{instruction}\t#{arguments} #{comment}")
  end

  def emit_label(label)
    write("#{label}:")
  end

  def emit_empty_line
    write
  end

  def write(text="")
    @output.write("#{text}\n")
  end
end
