class CodeGenerator
  def initialize(program, output)
    @program = program
    @output = output
  end

  def generate
    generate_header
    @program.declarations.each do |d|
      if d.is_a? FunctionDeclaration
        r_function_declaration(d)
      end
    end
    generate_io_string_section
  end

  def r_function_declaration(ast)
    emit_empty_line
    emit_label("_#{ast.id}")
    emit("pushq", "%rbp", "# push old fp onto stack")
    emit("movq", "%rsp, %rbp", "# setup new fp")
    # TODO allocate local variables
    # body
    ast.body.stmts.each do |stmt|
      r_stmt(stmt)
    end
    # TODO deallocate local variables
    # should we deallocate local variables by moving fp to sp?
    emit("popq", "%rbp", "# restore old fp from stack")
    emit("ret")
  end

  def r_stmt(ast)
    if ast.is_a? WriteStmt
      r_expression(ast.value)
      emit("movq", "%rax, %rsi", "# load rax into rsi")
      emit("leaq", ".WriteIntString(%rip), %rdi", "# load formatting string into rdi")
      emit("callq", "_printf", "# call printf")
    elsif ast.is_a? WritelnStmt
      emit("leaq", ".WritelnString(%rip), %rdi", "# load formatting string into rdi")
      emit("callq", "_printf", "# call printf")
    end
  end

  def r_expression(ast)
    if ast.is_a? NumLitExp
      emit("movq", "$#{ast.value}, %rax", "# load #{ast.value} into rax")
    end
  end

  # header and io_string_section

  def generate_header
    emit(".section","__TEXT,__text,regular,pure_instructions")
    emit(".globl","_main")
    emit(".align","4,0x90")
  end

  def generate_io_string_section
    emit_empty_line
    emit(".section","__TEXT,__cstring,cstring_literals")
    emit_label(".WriteIntString")
    emit(".asciz",'"%d "')
    emit_label(".WriteStringString")
    emit(".asciz",'"%s "')
    emit_label(".WritelnString")
    emit(".asciz",'"\n"')
  end

  # utility functions

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
