require 'spec_helper'

describe Parser do
  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(Parser.new(Scanner.new("int x;"))).to be_a Parser
    end
  end

  describe "#parse" do
    it "returns an Ast" do
      expect(Parser.new(Scanner.new("int x;")).parse).to be_a Ast
    end

    it "returns a Program" do
      p = Parser.new(Scanner.new("int x;")).parse
      expect(p).to be_a Program
    end

    context "a Program" do
      let(:p) { Parser.new(Scanner.new("int x;")).parse }

      it "has a DeclarationList" do
        expect(p.declaration_list).to be_a DeclarationList
      end
    end

    context "a DeclarationList" do
      let(:d) { Parser.new(Scanner.new("int x;")).parse.declaration_list }

      it "has a nil DeclarationList and a Declaration" do
        expect(d.declaration_list).to be_nil
        expect(d.declaration).to be_a Declaration
      end
    end

    context "a Declaration" do
      let(:d) { Parser.new(Scanner.new("int x;")).parse.declaration_list.declaration }

      it "has a TypeSpecifier and an Id" do
        expect(d.type_specifier).to be_a TypeSpecifier
        expect(d.id).to be_a Id
      end
    end
  end
end
