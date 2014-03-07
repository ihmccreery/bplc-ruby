bplc-ruby
====

An implementation of a BPL language compiler in Ruby for the OCCS Compilers course.

Grammar
---

These are notes on the grammar as it appears in the BPL manual versus how it is implemented in `Ast`.

### Implemented

	Program				::= DeclarationList
	DelcarationList		::= DeclarationList Declaration | Declaration
	Declaration			::= VariableDeclaration
	VariableDeclaration	::= <TypeSpecifier> <Id>;

### Not Implemented

	Declaration			::= FunctionDeclaration
	VariableDeclaration	::= <TypeSpecifier> *<Id>; | <TypeSpecifier> <Id>[<Num>];

... and everything else