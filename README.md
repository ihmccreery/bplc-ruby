bplc-ruby
====

An implementation of a BPL language compiler in Ruby for the OCCS Compilers course.

Grammar
---

These are notes on the grammar as it appears in the BPL manual versus how it is implemented in `Ast`.

The LHS of every rule is implemented as a Ruby class.  The RHS of every rule is, unless otherwise specified, the
children of the LHS.

`>` indicates that, rather than the RHS having a child, it is simply a superclass of the LHS.

Angle brackets, (e.g. `<Id>`,) indicate that the class is a `TokenAst`, meaning that it has exactly one child, the token
it represents.  Any terminal symbol without angle brackets, (e.g. `;`,) is also a subclass of `TokenAst`.

### Implemented

- `Program ::= [Declaration, Declaration, ..., Declaration]`
  - A `Program` has a `declarations` child which is just an array of Declarations.  This is different than the
    grammar given in the BPL manual
- `Declaration > VariableDeclaration | FunctionDeclaration`
  - Note that in the BPL manual, a `Declaration` can produce a `VarDec` or `FunDec`.  We deviate from this, instead just
    letting a `Declaration` be one of two types: `VariableDeclaration` or `FunctionDeclaration`
    - `VariableDeclaration > SimpleDeclaration | PointerDeclaration | ArrayDeclaration`
        - `SimpleDeclaration ::= <TypeSpecifier> <Id>;`
        - `PointerDeclaration ::= <TypeSpecifier> *<Id>;`
        - `ArrayDeclaration ::= <TypeSpecifier> <Id>[<Num>];`
    - `FunctionDeclaration ::= <TypeSpecifier> <Id>([Param, Param, ..., Param]) CompoundStatement`
      - A `FunctionDeclaration` has a `params` child which is just an array of Params.  This is different than the
        grammar given in the BPL manual
- `Param > SimpleParam | PointerParam | ArrayParam`
  - `SimpleParam ::= <TypeSpecifier> <Id>`
  - `PointerParam ::= <TypeSpecifier> *<Id>`
  - `ArrayParam ::= <TypeSpecifier> <Id>[]`
- `CompoundStatement ::= { [Declaration, Declaration, ..., Declaration] [Statement, Statement, ..., Statement] }`
  - A `CompoundStatement` just has a `local_declarations`, which is just an array of `Declarations`, and a statements, which is
    just an array of `Statements`
  - `local_declarations` can only include `VariableDeclarations`, not `FunctionDeclarations`
- `Statement > ExpressionStatement`
  - Unlike the BPL manual, a `Statement` does not produce an `ExpressionStatement`, etc., but rather can be one of several
    types of `Statements`
- `ExpressionStatement ::= Expression; | ;`

### Not Implemented

- Statement > CompoundStatement | IfStatement | WhileStatement | ReturnStatement | WriteStatement
- everything else
