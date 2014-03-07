require 'spec_helper'

describe Parser do
  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(Parser.new(Scanner.new("int x;"))).to be_a Parser
    end
  end

  describe "#parse" do
    it "returns an Ast that is also a Program" do
      p = Parser.new(Scanner.new("int x;")).parse
      expect(p).to be_a Ast
      expect(p).to be_a Program
    end

    it "can be called multiple times" do
      p = Parser.new(Scanner.new("int x;"))
      expect(p.parse).to be_a Ast
      expect(p.parse).to be_a Ast
    end

    context "a Program" do
      let(:p) { Parser.new(Scanner.new("int x;")).parse }

      it "has a declaration_list" do
        expect(p.declaration_list).to be_a DeclarationList
      end
    end

    context "a DeclarationList" do
      let(:d) { Parser.new(Scanner.new("int x; void y; string z;")).parse.declaration_list }

      it "is properly nested and has declarations" do
        z = d
        y = d.declaration_list
        x = d.declaration_list.declaration_list

        expect(x).to be_a DeclarationList
        expect(x.declaration.type_specifier.token.type).to eq(:int)
        expect(x.declaration.id.token.type).to eq(:id)
        expect(x.declaration.id.token.value).to eq("x")

        expect(y).to be_a DeclarationList
        expect(y.declaration.type_specifier.token.type).to eq(:void)
        expect(y.declaration.id.token.type).to eq(:id)
        expect(y.declaration.id.token.value).to eq("y")

        expect(z).to be_a DeclarationList
        expect(z.declaration.type_specifier.token.type).to eq(:string)
        expect(z.declaration.id.token.type).to eq(:id)
        expect(z.declaration.id.token.value).to eq("z")
      end
    end

    context "a Declaration" do
      let(:d) { Parser.new(Scanner.new("int x;")).parse.declaration_list.declaration }

      it "has a type_specifier and an id" do
        expect(d.type_specifier).to be_a TypeSpecifier
        expect(d.id).to be_a Id
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("x;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got id")

          p = Parser.new(Scanner.new("int ;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected id, got semicolon")

          p = Parser.new(Scanner.new("int x"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got eof")
        end
      end
    end

    context "a TypeSpecifier" do
      let(:t) { Parser.new(Scanner.new("int x;")).parse.declaration_list.declaration.type_specifier }

      it "has a token of the appropriate type" do
        expect(t.token).to be_a Token
        expect(t.token.type).to eq(:int)
      end
    end

    context "an Id" do
      let(:i) { Parser.new(Scanner.new("int x;")).parse.declaration_list.declaration.id }

      it "has a token of the appropriate type and value" do
        expect(i.token).to be_a Token
        expect(i.token.type).to eq(:id)
        expect(i.token.value).to eq("x")
      end
    end
  end
end
