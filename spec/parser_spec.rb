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
      let(:p) { Parser.new(Scanner.new("int x; void y; string z;")).parse.declaration_list }

      it "is a set of nested DeclarationLists ending with nil" do
        expect(p).to be_a DeclarationList
        expect(p.declaration_list).to be_a DeclarationList
        expect(p.declaration_list.declaration_list).to be_a DeclarationList
        expect(p.declaration_list.declaration_list.declaration_list).to be_nil
      end

      it "is properly nested" do
        z = p.declaration
        y = p.declaration_list.declaration
        x = p.declaration_list.declaration_list.declaration

        expect(x.type_specifier.token.type).to eq(:int)
        expect(x.id.token.type).to eq(:id)
        expect(x.id.token.value).to eq("x")

        expect(y.type_specifier.token.type).to eq(:void)
        expect(y.id.token.type).to eq(:id)
        expect(y.id.token.value).to eq("y")

        expect(z.type_specifier.token.type).to eq(:string)
        expect(z.id.token.type).to eq(:id)
        expect(z.id.token.value).to eq("z")
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int x; void y;; string z;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected eof, got semicolon")

          p = Parser.new(Scanner.new("int x; y; string z;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected eof, got id")

          p = Parser.new(Scanner.new("int x; void y string z;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got string")
        end
      end
    end

    #######################
    # VariableDeclaration #
    #######################

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

    #######################
    # FunctionDeclaration #
    #######################

    context "a FunctionDeclaration" do
      let(:p) { Parser.new(Scanner.new("int f(void) { }")).parse.declaration_list.declaration }

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
          p = Parser.new(Scanner.new("int f()"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got r_paren")

          p = Parser.new(Scanner.new("int f( { }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got l_brace")
        end
      end
    end

    ########################
    # Declaration Children #
    ########################

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

    context "a VoidParams" do
      let(:p) { Parser.new(Scanner.new("int f(void) { }")).parse.declaration_list.declaration.params }

      it "is a VoidParams that is also a Params" do
        expect(p).to be_a VoidParams
        expect(p).to be_a Params
      end

      it "has a token of the appropriate type" do
        expect(p.token).to be_a Token
        expect(p.token.type).to eq(:void)
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int f() { }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got r_paren")

          p = Parser.new(Scanner.new("int f(void void) { }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got void")
        end
      end
    end

    context "a ParamList" do
      let(:p) { Parser.new(Scanner.new("int f(int x, int y, int z) { }")).parse.declaration_list.declaration.params }

      it "is a set of nested ParamLists ending with nil" do
        expect(p).to be_a ParamList
        expect(p).to be_a Params
        expect(p.param_list).to be_a ParamList
        expect(p.param_list).to be_a Params
        expect(p.param_list.param_list).to be_a ParamList
        expect(p.param_list.param_list).to be_a Params
        expect(p.param_list.param_list.param_list).to be_nil
      end

      it "is properly nested" do
        z = p.param
        y = p.param_list.param
        x = p.param_list.param_list.param

        expect(x.type_specifier.token.type).to eq(:int)
        expect(x.id.token.type).to eq(:id)
        expect(x.id.token.value).to eq("x")

        expect(y.type_specifier.token.type).to eq(:int)
        expect(y.id.token.type).to eq(:id)
        expect(y.id.token.value).to eq("y")

        expect(z.type_specifier.token.type).to eq(:int)
        expect(z.id.token.type).to eq(:id)
        expect(z.id.token.value).to eq("z")
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int f(int x, int y,, int z) { }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got comma")

          p = Parser.new(Scanner.new("int f(int x, y, int z) { }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got id")

          p = Parser.new(Scanner.new("int f(int x, int y int z) { }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got int")
        end
      end
    end
  end
end
