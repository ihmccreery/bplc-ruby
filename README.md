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

Compiling is broken into !!! steps:

1. The **scanner** reads the `.bplc` file and converts it into tokens, such as `(`, `int`, or `"hello"`.
- The **parser** converts the scanner's stream of tokens into an **abstract syntax tree** (AST).  The structure of the
  AST is detailed below.
- The **resolver** walks the AST and resolves every variable reference by adding a `declaration` attribute to each
  `VarExp` node.
- The **type checker** walks the AST and assigns each `Exp` node a type, either by checking what kind of literal it is
  or by checking what types its children are, and complains if there is an invalid type.

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
