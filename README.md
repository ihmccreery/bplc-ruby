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

- `Program ::= DeclarationList`
- `DelcarationList ::= DeclarationList Declaration | Declaration`
  - A `DeclarationList` always has a `declaration` child, and has `declaration_list` child that is either a `DeclarationList`
    or nil.
- `Declaration > VariableDeclaration | FunctionDeclaration`
  - Note that in the BPL manual, a `Declaration` can produce a `VarDec` or `FunDec`.  We deviate from this, instead just
    letting a `Declaration` be one of two types: `VariableDeclaration` or `FunctionDeclaration`
    - `VariableDeclaration > SimpleDeclaration | PointerDeclaration | ArrayDeclaration`
        - `SimpleDeclaration ::= <TypeSpecifier> <Id>;`
        - `PointerDeclaration ::= <TypeSpecifier> *<Id>;`
        - `ArrayDeclaration ::= <TypeSpecifier> <Id>[<Num>];`
    - `FunctionDeclaration ::= <TypeSpecifier> <Id>(Params) CompoundStatement`
- `Params > <VoidParams> | ParamsList`
- `ParamsList :: ParamsList, Param | Param`
  - A `ParamList` always has a `param` child, and has `param_list` child that is either a `ParamList` or nil.
- `Param > SimpleParam | PointerParam | ArrayParam`
  - `SimpleParam ::= <TypeSpecifier> <Id>`
  - `PointerParam ::= <TypeSpecifier> *<Id>`
  - `ArrayParam ::= <TypeSpecifier> <Id>[]`
- CompoundStatement

### Not Implemented

- everything else
