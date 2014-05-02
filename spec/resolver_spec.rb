require 'spec_helper'

describe Resolver do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(Resolver.new(parse("int x; void main(void) { x; }"))).to be_a Resolver
    end
  end

  describe "#resolve" do
    # global variable resolution

    it "resolves global variable references" do
      a = resolve("int x; void main(void) { x; }")

      x_declaration = a.declarations[0]
      x_reference = a.declarations[1].body.stmts[0].exp

      expect(x_reference.declaration).to eq(x_declaration)
    end

    # local variable resolution

    it "resolves local variable references" do
      a = resolve("int y; void main(void) { int x; int y; x; y; }")

      body = a.declarations[1].body
      x_declaration = body.variable_declarations[0]
      x_reference = body.stmts[0].exp
      # y should reference the local, not global, declaration
      y_declaration = body.variable_declarations[1]
      y_reference = body.stmts[1].exp

      expect(x_reference.declaration).to eq(x_declaration)
      expect(y_reference.declaration).to eq(y_declaration)
    end

    it "resolves nested local variable references" do
      a = resolve("void main(void) { int y; int z; if(1) {int x; int y; x; y; z;} }")

      body = a.declarations[0].body
      if_body = body.stmts[0].body
      x_declaration = if_body.variable_declarations[0]
      x_reference = if_body.stmts[0].exp
      # y should reference the locally scoped declaration
      y_declaration = if_body.variable_declarations[1]
      y_reference = if_body.stmts[1].exp
      # z should reference the local, out-of-immediate-scope, declaration
      z_declaration = body.variable_declarations[1]
      z_reference = if_body.stmts[2].exp

      expect(x_reference.declaration).to eq(x_declaration)
      expect(y_reference.declaration).to eq(y_declaration)
      expect(z_reference.declaration).to eq(z_declaration)
    end

    # param resolution

    it "resolves param variable references" do
      a = resolve("void main(int x) { x; }")

      x_declaration = a.declarations[0].params[0]
      x_reference = a.declarations[0].body.stmts[0].exp

      expect(x_reference.declaration).to eq(x_declaration)
    end

    # variables in general

    it "resolves variable references in expressions" do
      a = resolve("int x; void f(int y) { } void main(void) { int y; x[y+2]; f(x); }")

      body = a.declarations[2].body
      x_declaration = a.declarations[0]
      x_array_reference = body.stmts[0].exp
      x_arg_reference = body.stmts[0].exp
      y_declaration = body.variable_declarations[0]
      y_reference = body.stmts[0].exp.index.lhs

      expect(x_array_reference.declaration).to eq(x_declaration)
      expect(x_arg_reference.declaration).to eq(x_declaration)
      expect(y_reference.declaration).to eq(y_declaration)
    end

    it "raises a BplDeclarationError if a variable is not declared" do
      expect_declaration_error("undeclared variable x", 2) do
        resolve("void main(void) { \n x; \n }")
      end
    end

    it "raises a BplDeclarationError if a variable is referenced outside of its scope" do
      expect_declaration_error("undeclared variable x", 3) do
        resolve("void main(void) { \n {int x;} \n x; \n }")
      end
    end

    it "raises a BplDeclarationError if a variable is declared more than once in the same scope" do
      expect_declaration_error("x has already been declared", 3) do
        resolve("void main(void) { \n int x; \n string x; \n }")
      end
    end

    it "raises a BplDeclarationError if a variable is declared in the same scope as a parameter" do
      expect_declaration_error("x has already been declared", 2) do
        resolve("void main(int x) { \n string x; \n }")
      end
    end

    # functions

    it "resolves a function reference" do
      a = resolve("void f(void) { f(); }")

      f_declaration = a.declarations[0]
      f_reference = a.declarations[0].body.stmts[0].exp

      expect(f_reference.declaration).to eq(f_declaration)
    end

    it "raises a BplDeclarationError if a function is not declared" do
      expect_declaration_error("undeclared variable f", 2) do
        resolve("void main(void) { \n f(); \n }")
      end
    end

    it "raises a BplDeclarationError if a function is declared more than once" do
      expect_declaration_error("f has already been declared", 2) do
        resolve("void f(void) { } \n void f(void) { }")
      end
    end

    it "raises a BplDeclarationError if a function is declared with a variable of the same name" do
      expect_declaration_error("f has already been declared", 2) do
        resolve("int f; \n void f(void) { }")
      end
    end

    # return statements

    it "resolves return statements" do
      a = resolve("void f(void) { return 2; if(2 < 3) { return 3; while(3 < 4) { return 5; } } }")

      f = a.declarations[0]
      expect(f.body.stmts[0].parent_function_declaration).to eq(f)
      expect(f.body.stmts[1].body.stmts[0].parent_function_declaration).to eq(f)
      expect(f.body.stmts[1].body.stmts[1].body.stmts[0].parent_function_declaration).to eq(f)
    end

  end
end
