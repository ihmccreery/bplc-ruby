require 'spec_helper'

describe Resolver do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(Resolver.new(parse_program("int x; void main(void) { x; }"))).to be_a Resolver
    end
  end

  describe "#resolve" do
    it "resolves a global variable reference" do
      a = parse_and_resolve("int x; void main(void) { x; }")

      x_declaration = a.declarations[0]
      x_reference = a.declarations[1].body.stmts[0].exp

      expect(x_reference.declaration).to eq(x_declaration)
    end

    it "resolves a function reference" do
      a = parse_and_resolve("void f(void) { } void main(void) { f(); }")

      f_declaration = a.declarations[0]
      f_reference = a.declarations[1].body.stmts[0].exp

      expect(f_reference.declaration).to eq(f_declaration)
    end

    it "resolves a local variable references" do
      a = parse_and_resolve("void main(void) { int x; x; }")

      body = a.declarations[0].body
      x_declaration = body.variable_declarations[0]
      x_reference = body.stmts[0].exp

      expect(x_reference.declaration).to eq(x_declaration)
    end

    it "raises a SyntaxError if a variable is not declared" do
      expect{parse_and_resolve("void main(void) { x; }")}.to raise_error(SyntaxError, "undeclared variable x")
    end

    it "raises a SyntaxError if a variable is declared more than once in the same scope" do
      expect{parse_and_resolve("void main(void) { int x; string x; }")}.to raise_error(SyntaxError, "x has already been declared")
    end
  end
end
