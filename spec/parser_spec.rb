require 'spec_helper'
require 'ex1_tokens'

describe Parser do
  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(Parser.new(Scanner.new("a"))).to be_a Parser
    end
  end

  describe "#parse" do
    context "a VariableDeclaration" do
      it "should parse a variable declaration" do
        parse = Parser.new(Scanner.new("int x;")).parse.variable_declaration
        expect(parse).to be_a Ast::VariableDeclaration
        expect(parse.type_specifier).to be_a Ast::TypeSpecifier
        expect(parse.id).to be_a Ast::Id
        expect(parse.semicolon).to be_a Ast::Semicolon
      end
    end

    context "a DeclarationList" do
      it "should parse to a tiered tree of declarations" do
        p = Parser.new(Scanner.new("int x; void y; string z;")).parse
        expect(p).to be_a Ast::DeclarationList
        expect(p.variable_declaration).to be_a Ast::VariableDeclaration
        expect(p.declaration_list).to be_a Ast::DeclarationList
        expect(p.declaration_list.variable_declaration).to be_a Ast::VariableDeclaration
        expect(p.declaration_list.declaration_list).to be_a Ast::DeclarationList
        expect(p.declaration_list.declaration_list.variable_declaration).to be_a Ast::VariableDeclaration
      end
    end
  end

  # TODO it "parses ex1.bpl properly"
end
