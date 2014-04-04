require 'spec_helper'

describe Resolver do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(Resolver.new(parse_program("int x; void main(void) { x; }"))).to be_a Resolver
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

    it "raises a SyntaxError if a variable is not declared" do
      expect{resolve("void main(void) { x; }")}.to raise_error(SyntaxError, "undeclared variable x")
    end

    it "raises a SyntaxError if a variable is referenced outside of its scope" do
      expect{resolve("void main(void) { {int x;} x; }")}.to raise_error(SyntaxError, "undeclared variable x")
    end

    it "raises a SyntaxError if a variable is declared more than once in the same scope" do
      expect{resolve("void main(void) { int x; string x; }")}.to raise_error(SyntaxError, "x has already been declared")
    end

    it "raises a SyntaxError if a variable is declared in the same scope as a parameter" do
      expect{resolve("void main(int x) { string x; }")}.to raise_error(SyntaxError, "x has already been declared")
    end

    # functions

    it "resolves a function reference" do
      a = resolve("void f(void) { f(); }")

      f_declaration = a.declarations[0]
      f_reference = a.declarations[0].body.stmts[0].exp

      expect(f_reference.declaration).to eq(f_declaration)
    end

    it "raises a SyntaxError if a function is not declared" do
      expect{resolve("void main(void) { f(); }")}.to raise_error(SyntaxError, "undeclared function f")
    end

    it "raises a SyntaxError if a function is declared more than once" do
      expect{resolve("void f(void) { } void f(void) { }")}.to raise_error(SyntaxError, "f has already been declared")
    end

    # resolutions in general

    it "resolves function references and variable references of the same symbol" do
      a = resolve("void f(void) { int f; f(); f; }")

      body = a.declarations[0].body
      f_fun_declaration = a.declarations[0]
      f_fun_reference = body.stmts[0].exp
      f_var_declaration = body.variable_declarations[0]
      f_var_reference = body.stmts[1].exp

      expect(f_fun_reference.declaration).to eq(f_fun_declaration)
      expect(f_var_reference.declaration).to eq(f_var_declaration)
    end
  end
end
