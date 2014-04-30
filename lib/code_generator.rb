class CodeGenerator
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
    emit_label("_#{ast.id}")
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
    if ast.is_a? WriteStmt
      r_write_stmt(ast)
    elsif ast.is_a? WritelnStmt
      r_writeln_stmt(ast)
    end
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
    if ast.is_a? AddExp
      r_add_exp(ast)
    elsif ast.is_a? MulExp
      r_mul_exp(ast)
    elsif ast.is_a? NegExp
      r_neg_exp(ast)
    elsif ast.is_a? NumLitExp
      emit("movq", "$#{ast.value}, %rax", "# load #{ast.value} into rax")
    elsif ast.is_a? StrLitExp
      emit("leaq", "#{ast.label}(%rip), %rax", "# load \"#{ast.value}\" into rax")
    end
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
    # TODO is there a better way to do this?
    emit("movq", "%rax, %rdx", "# move rax into rdx")
    emit("movq", "$0, %rax", "# move 0 into rax")
    emit("subq", "%rdx, %rax", "# subtract rdx from rax")
  end

  ###################
  # support methods #
  ###################

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
