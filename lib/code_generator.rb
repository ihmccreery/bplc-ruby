class CodeGenerator
  QUADWORD_SIZE = 8.freeze

  def initialize(program, output)
    @program = program
    @output = output
  end

  def generate
    r(@program)
  end

  private

  def r(ast)
    if ast.is_a? Program
      r_program(ast)
    elsif ast.is_a? Declaration
      r_declaration(ast)
    elsif ast.is_a? Stmt
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
      r(d)
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
    emit(".asciz",'"%d "')
    emit_label(".WriteStringString")
    emit(".asciz",'"%s "')
    emit_label(".WritelnString")
    emit(".asciz",'"\n"')
  end

  ################
  # Declarations #
  ################

  def r_declaration(ast)
    if ast.is_a? FunctionDeclaration
      r_function_declaration(ast)
    end
  end

  def r_function_declaration(ast)
    emit_empty_line
    emit_label(format_function_id(ast.id))
    emit("pushq", "%rbp", "# push old fp onto stack")
    emit("movq", "%rsp, %rbp", "# setup new fp")
    # TODO allocate local variables
    # body
    ast.body.stmts.each do |s|
      r(s)
    end
    # TODO deallocate local variables
    # should we deallocate local variables by moving fp to sp?
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

  def r_return_stmt(ast)
    unless ast.value.nil?
      r(ast.value)
    end
    # TODO deallocate local variables
    # should we deallocate local variables by moving fp to sp?
    emit("popq", "%rbp", "# restore old fp from stack")
    emit("ret")
  end

  def r_write_stmt(ast)
    r(ast.value)
    emit("movq", "%rax, %rsi", "# load rax into rsi")
    if ast.value.type == :int
      emit("leaq", ".WriteIntString(%rip), %rdi", "# load int formatting string into rdi")
    else
      emit("leaq", ".WriteStringString(%rip), %rdi", "# load string formatting string into rdi")
    end
    emit("callq", "_printf", "# call printf")
  end

  def r_writeln_stmt(ast)
    emit("leaq", ".WritelnString(%rip), %rdi", "# load formatting string into rdi")
    emit("callq", "_printf", "# call printf")
  end

  ########
  # Exps #
  ########

  def r_exp(ast)
    if ast.is_a? RelExp
      r_rel_exp(ast)
    elsif ast.is_a? AddExp
      r_add_exp(ast)
    elsif ast.is_a? MulExp
      r_mul_exp(ast)
    elsif ast.is_a? NegExp
      r_neg_exp(ast)
    elsif ast.is_a? SimpleVarExp
      r_simple_var_exp(ast)
    elsif ast.is_a? FunCallExp
      r_fun_call_exp(ast)
    elsif ast.is_a? NumLitExp
      emit("movq", "$#{ast.value}, %rax", "# load #{ast.value} into rax")
    elsif ast.is_a? StrLitExp
      emit("leaq", "#{ast.label}(%rip), %rax", "# load \"#{ast.value}\" into rax")
    end
  end

  def r_rel_exp(ast)
    r(ast.rhs)
    emit("pushq", "%rax", "# push rax onto stack")
    r(ast.lhs)
    emit("cmpq", "(%rsp), %rax", "# compare top of stack to rax")

    if ast.op == :lt
      emit("jl", ast.true_label, "# jump to #{ast.true_label} to resolve True")
    elsif ast.op == :leq
      emit("jle", ast.true_label, "# jump to #{ast.true_label} to resolve True")
    elsif ast.op == :eq
      emit("je", ast.true_label, "# jump to #{ast.true_label} to resolve True")
    elsif ast.op == :neq
      emit("jne", ast.true_label, "# jump to #{ast.true_label} to resolve True")
    elsif ast.op == :geq
      emit("jge", ast.true_label, "# jump to #{ast.true_label} to resolve True")
    else # ast.op == :gt
      emit("jg", ast.true_label, "# jump to #{ast.true_label} to resolve True")
    end

    emit("clrq", "%rax", "# move 0 (False) into rax")
    emit("jmp", ast.follow_label, "# jump to #{ast.follow_label} after resolving False")
    emit_label(ast.true_label)
    emit("movq", "$1, %rax", "# move 1 (True) into rax")
    emit_label(ast.follow_label)
    pop
  end

  def r_add_exp(ast)
    r(ast.rhs)
    emit("pushq", "%rax", "# push rax onto stack")
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
    emit("pushq", "%rax", "# push rax onto stack")
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
    emit("movq", "%rax, %rdx", "# move rax into rdx")
    emit("movq", "$0, %rax", "# move 0 into rax")
    emit("subq", "%rdx, %rax", "# subtract rdx from rax")
  end

  def r_simple_var_exp(ast)
    if ast.declaration.is_a? Param
      emit("movq", "#{ast.declaration.offset}(%rbp), %rax", "# move #{ast.id} into rax")
    end
  end

  def r_fun_call_exp(ast)
    # add an empty quadword if there is an odd number of arguments to maintain
    # 16-byte alignment for a function call
    if ast.args.size.odd?
      emit("pushq", "$0", "# push empty quadword onto stack to maintain alignment with #{ast.args.size} arguments")
    end
    ast.args.reverse_each do |a|
      r(a)
      emit("pushq", "%rax", "# push arg onto stack")
    end
    emit("callq", format_function_id(ast.id), "# call #{ast.id}")
    # pop off size + size % 2: in case there is an odd number of arguments, we
    # need to pop off the extra empty quadword
    emit("addq", "$#{QUADWORD_SIZE*(ast.args.size + ast.args.size % 2)}, %rsp", "# pop #{ast.args.size} args off the stack")
  end

  ###################
  # support methods #
  ###################

  def pop
    emit("addq", "$8, %rsp", "# pop the stack")
  end

  def format_function_id(id)
    "_#{id}"
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
