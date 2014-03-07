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

    ################
    # Declarations #
    ################

    context "a DeclarationList" do
      let(:p) { Parser.new(Scanner.new("int x; void y; string z;")).parse.declaration_list }

      it "is properly nested and has declarations" do
        z = p
        y = p.declaration_list
        x = p.declaration_list.declaration_list

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

    context "a SimpleDeclaration" do
      let(:p) { Parser.new(Scanner.new("int x;")).parse.declaration_list.declaration }

      it "is a VariableDeclaration that is also a SimpleDeclaration" do
        expect(p).to be_a VariableDeclaration
        expect(p).to be_a SimpleDeclaration
      end

      it "has a type_specifier and an id" do
        expect(p.type_specifier).to be_a TypeSpecifier
        expect(p.id).to be_a Id
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

    context "a PointerDeclaration" do
      let(:p) { Parser.new(Scanner.new("int *x;")).parse.declaration_list.declaration }

      it "is a VariableDeclaration that is also a PointerDeclaration" do
        expect(p).to be_a VariableDeclaration
        expect(p).to be_a PointerDeclaration
      end

      it "has a type_specifier and an id" do
        expect(p.type_specifier).to be_a TypeSpecifier
        expect(p.id).to be_a Id
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int x*;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got asterisk")

          p = Parser.new(Scanner.new("int *;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected id, got semicolon")

          p = Parser.new(Scanner.new("*x;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got asterisk")
        end
      end
    end

    context "an ArrayDeclaration" do
      let(:p) { Parser.new(Scanner.new("int x[2];")).parse.declaration_list.declaration }


      it "is a VariableDeclaration that is also a ArrayDeclaration" do
        expect(p).to be_a VariableDeclaration
        expect(p).to be_a ArrayDeclaration
      end
      it "is an ArrayDeclaration" do
        expect(p).to be_a ArrayDeclaration
      end

      it "has a type_specifier, id, and size" do
        expect(p.type_specifier).to be_a TypeSpecifier
        expect(p.id).to be_a Id
        expect(p.size).to be_a Num
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int [2]x;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected id, got l_bracket")

          p = Parser.new(Scanner.new("int x[2;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected r_bracket, got semicolon")

          p = Parser.new(Scanner.new("x[2];"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got id")
        end
      end
    end

    context "a FunctionDeclaration" do
      let(:p) { Parser.new(Scanner.new("int x(void)")).parse.declaration_list.declaration }

      it "is a FunctionDeclaration" do
        expect(p).to be_a FunctionDeclaration
      end

      it "has a type_specifier, id, params, and body" do
        expect(p.type_specifier).to be_a TypeSpecifier
        expect(p.id).to be_a Id
        expect(p.params).to be_a Params
        expect(p.body).to be_a CompoundStatement
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int x();"))
          expect{p.parse}.to raise_error(SyntaxError, "expected void, got r_paren")

          p = Parser.new(Scanner.new("int x(;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected void, got semicolon")
        end
      end
    end

    context "a TypeSpecifier" do
      let(:p) { Parser.new(Scanner.new("int x;")).parse.declaration_list.declaration.type_specifier }

      it "is a TypeSpecifier" do
        expect(p).to be_a TypeSpecifier
      end

      it "has a token of the appropriate type" do
        expect(p.token).to be_a Token
        expect(p.token.type).to eq(:int)
      end
    end

    context "an Id" do
      let(:p) { Parser.new(Scanner.new("int x;")).parse.declaration_list.declaration.id }

      it "is a Id" do
        expect(p).to be_a Id
      end

      it "has a token of the appropriate type and value" do
        expect(p.token).to be_a Token
        expect(p.token.type).to eq(:id)
        expect(p.token.value).to eq("x")
      end
    end

    context "a Num" do
      let(:p) { Parser.new(Scanner.new("int x[2];")).parse.declaration_list.declaration.size }

      it "is a Num" do
        expect(p).to be_a Num
      end

      it "has a token of the appropriate type and value" do
        expect(p.token).to be_a Token
        expect(p.token.type).to eq(:num)
        expect(p.token.value).to eq("2")
      end
    end
  end
end
