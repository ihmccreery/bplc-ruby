bplc-ruby
====

A compiler for the BPL language written in Ruby for the OCCS Compilers course.

Usage
---

    $ ./bin/bplc example.bplc

Directory system
---

### Code

All compiler code is in `lib/`.  Generally-used components like tokens and the abstract syntax tree are in top-level
files, (in `lib/token.rb` and `lib/ast.rb`, respectively).

Other components that can have multiple implementations, such as scanners and parsers, have a more complex structure.
At the top level, there are plug-and-play components like `parser.rb`:

    require 'parsers/recursive_descent_parser'

    class Parser < Parsers::RecursiveDescentParser
    end

This way, if I build different implementations, I can pull out one, plug in another, and it will all run smoothly.

### Specs

Tests (specs) are in `spec/`.  Right now, there are general specs for scanners and parsers; if/when I implement other
scanners, (like a regex-based scanner,) parsers, (like a bottom-up parser,) or other componenets, I'll have to split
tests for each implementation.

Bplc
---

Compiling is broken into 4 steps:

1. The **scanner** reads the `.bplc` file and converts it into tokens, such as `(`, `int`, or `"hello"`.
- The **parser** converts the scanner's stream of tokens into an **abstract syntax tree** (AST).  The structure of the
  AST is detailed below.
- The **resolver** walks the AST and resolves every variable reference by adding a `declaration` attribute to each
  `VarExp` node.
- The **type checker** walks the AST and assigns each `Exp` node a type, either by checking what kind of literal it is
  or by checking what types its children are, and complains if there is an invalid type.
- The **indexer** preprocesses the AST, assigning indices to arguments, local variables, and strings.
- The **code generator** walks the AST and generates AT&T assembly code.

Structure of the AST
---

As of right now, the AST has the following structure:

- An AST's root is a `Program`, which has `declarations`.
- A `FunctionDeclaration` has `params` and a `body`.
- A `CompoundStmt` has `variable_declarations` and `stmts`
- A `Stmt` can be one of the following, which themselves contain `Exp`s and/or `Stmt`s:
  - a `CompoundStmt`,
  - an `ExpStmt`,
  - an `IfStmt`,
  - a `WhileStmt`,
  - a `ReturnStmt`,
  - a `WriteStmt`, or
  - a `WritelnStmt`.
- An `AssignmentExp`, has an `lhs`, (an `AssignableVarExp`,) an `rhs`, (an `Exp`).
- A `RelExp`, an `AddExp`, or a `MulExp` has an `op`, an `lhs`, and an `rhs`.
- A `NegExp` has an `exp`.
- A `VarExp` has an `id`, and possibly an `index` or `args`, and a `LitExp` has a `literal`.

Runtime Environment
---

For the most part, we're using the same runtime environment as Bob suggests, but we are modifying it slightly.  Here are
the modifications.

### Stack alignment on function calls

OS X requires [(3.2.2: The Stack Frame, page 14)](http://people.freebsd.org/~obrien/amd64-elf-abi.pdf) that a function
call provide a 16-byte-aligned stack at the time of call.  This is for [performance
reasons](http://stackoverflow.com/questions/612443/why-does-the-mac-abi-require-16-byte-stack-alignment-for-x86-32).

We must also de-align the stack before pushing arguments on:

- store `%rsp` in `%rdx`;
- align the stack to 16 bytes;
- push `%rdx`, (the old stack pointer,) onto the stack, (the stack is now definitely *not* aligned).

So, whenever we call a function, we push an extra 8 bytes onto the stack if we've got an even number of arguments, so
that the stack is then aligned.  See below for the full algorithm.

### %rbp ownership

Instead of requiring the caller to push the frame pointer onto the stack before the call, the callee saves the old frame
pointer, sets up its own, and restores the old frame pointer before returning.  So, the steps to call a function are:

  - dealign the stack, as described above,
  - load the function arguments in reverse order onto the stack, with an additional empty argument to start if there is
    an even number of arguments,
  - call the function,
  - remove arguments from stack, including the possible additional empty argument,
  - restore the stack pointer as saved in the first step.

The steps for the function called are:

  - push the old frame pointer onto the stack;
  - set the new frame pointer by loading the stack pointer into the frame pointer;
  - allocate local variables;
  - do what you need to do, and leave the return value in the accumulator;
  - deallocate local variables;
  - pop the stack into the frame pointer; and
  - return.
