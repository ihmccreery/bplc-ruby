bplc-ruby
====

An implementation of a BPL language compiler in Ruby for the OCCS Compilers course.

Grammar
---

These are notes on the grammar as it appears in the BPL manual versus how it is implemented in `Ast`.

The LHS of every rule is implemented as a Ruby class.  The RHS of every rule is, unless otherwise specified, the children of the LHS.

Angle brackets, (e.g. `<Id>`,) indicate that the class is a `TokenAst`, meaning that it has exactly one child, the token it represents.  Any terminal symbol without angle brackets, (e.g. `;`,) is also a subclass of `TokenAst`.

### Implemented

	Program				::= DeclarationList
	DelcarationList		::= DeclarationList Declaration | Declaration
	Declaration			::= VariableDeclaration
	VariableDeclaration	::= <TypeSpecifier> <Id>;

### Not Implemented

	Declaration			::= FunctionDeclaration
	VariableDeclaration	::= <TypeSpecifier> *<Id>; | <TypeSpecifier> <Id>[<Num>];

... and everything else.