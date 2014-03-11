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
- `Expression > SimpleExpression`
  - An `Expression` can be an `AssignmentExpression`, `ComparisonExpression`, or `SimpleExpression`.  This is just a way of
    clarifying the grammar given in the BPL manual.
  - `SimpleExpression ::= E`
- `E ::= E AddOp T | T`
  - Unlike other left-recursive rules, `E` is actually implemented left-recursively.  An `E` has children `add_op`, `e`, and
    `t`.  The left-most `E` of a nested set of `E`s has a nil `e` and a nil `add_op`.
- `T ::= T MulOp F | F`
  - Unlike other left-recursive rules, `T` is actually implemented left-recursively.  A `T` has children `mul_op`, `t`, and
    `f`.  The left-most `T` of a nested set of `T`s has a nil `t` and a nil `mul_op`.

### Not Implemented

- `Statement > CompoundStatement | IfStatement | WhileStatement | ReturnStatement | WriteStatement`
- `Expression > AssignmentExpression | ComparisonExpression`
  - `AssignmentExpression ::= Var = Expression`
  - `ComparisonExpression ::= E Relop E
- `F ::=` stuff
- everything else
