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
      let(:p) { Parser.new(Scanner.new("int x; void *y; string z[2];")).parse }

      it "is a Program" do
        expect(p).to be_a Program
      end

      it "has a declarations that is an array" do
        expect(p.declarations).to be_a Array
      end
    end

    context "a declarations" do
      let(:p) { Parser.new(Scanner.new("int x; void *y; string z[2];")).parse.declarations }

      it "is an array of Declarations" do
        expect(p[0]).to be_a Declaration
        expect(p[1]).to be_a Declaration
        expect(p[2]).to be_a Declaration
        expect(p[3]).to be_nil
      end

      it "is properly formed" do
        x = p[0]
        y = p[1]
        z = p[2]

        expect(x).to be_a SimpleDeclaration
        expect(x.type_specifier.token.type).to eq(:int)
        expect(x.id.token.type).to eq(:id)
        expect(x.id.token.value).to eq("x")

        expect(y).to be_a PointerDeclaration
        expect(y.type_specifier.token.type).to eq(:void)
        expect(y.id.token.type).to eq(:id)
        expect(y.id.token.value).to eq("y")

        expect(z).to be_a ArrayDeclaration
        expect(z.type_specifier.token.type).to eq(:string)
        expect(z.id.token.type).to eq(:id)
        expect(z.id.token.value).to eq("z")
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int x; void *y;; string z[2];"))
          expect{p.parse}.to raise_error(SyntaxError, "expected eof, got semicolon")

          p = Parser.new(Scanner.new("int x; y; string z;"))
          expect{p.parse}.to raise_error(SyntaxError, "expected eof, got id")

          p = Parser.new(Scanner.new("int x; void *y string z[2];"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got string")
        end
      end
    end

    #######################
    # VariableDeclaration #
    #######################

    context "a SimpleDeclaration" do
      let(:p) { Parser.new(Scanner.new("int x;")).parse.declarations[0] }

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
      let(:p) { Parser.new(Scanner.new("int *x;")).parse.declarations[0] }

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
      let(:p) { Parser.new(Scanner.new("int x[2];")).parse.declarations[0] }

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
      let(:p) { Parser.new(Scanner.new("int f(void) { }")).parse.declarations[0] }

      it "is a FunctionDeclaration" do
        expect(p).to be_a FunctionDeclaration
      end

      it "has a type_specifier, id, params, and body" do
        expect(p.type_specifier).to be_a TypeSpecifier
        expect(p.id).to be_a Id
        expect(p.params).to be_a Array
        expect(p.body).to be_a CompoundStatement
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int f()"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got r_paren")

          p = Parser.new(Scanner.new("int f( { }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got l_brace")

          p = Parser.new(Scanner.new("int f(void) { "))
          expect{p.parse}.to raise_error(SyntaxError, "expected r_brace, got eof")

          p = Parser.new(Scanner.new("int f(void) } "))
          expect{p.parse}.to raise_error(SyntaxError, "expected l_brace, got r_brace")
        end
      end
    end

    ########################
    # Declaration Children #
    ########################

    context "a TypeSpecifier" do
      let(:p) { Parser.new(Scanner.new("int x;")).parse.declarations[0].type_specifier }

      it "is a TypeSpecifier" do
        expect(p).to be_a TypeSpecifier
      end

      it "has a token of the appropriate type" do
        expect(p.token).to be_a Token
        expect(p.token.type).to eq(:int)
      end
    end

    context "an Id" do
      let(:p) { Parser.new(Scanner.new("int x;")).parse.declarations[0].id }

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
      let(:p) { Parser.new(Scanner.new("int x[2];")).parse.declarations[0].size }

      it "is a Num" do
        expect(p).to be_a Num
      end

      it "has a token of the appropriate type and value" do
        expect(p.token).to be_a Token
        expect(p.token.type).to eq(:num)
        expect(p.token.value).to eq("2")
      end
    end

    context "an empty params" do
      let(:p) { Parser.new(Scanner.new("int f(void) { }")).parse.declarations[0].params }

      it "is an empty array" do
        expect(p).to be_a Array
        expect(p).to be_empty
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

    context "a params" do
      let(:p) { Parser.new(Scanner.new("int f(int x, int y, int z) { }")).parse.declarations[0].params }

      it "is an array of Params" do
        expect(p[0]).to be_a Param
        expect(p[1]).to be_a Param
        expect(p[2]).to be_a Param
        expect(p[3]).to be_nil
      end

      it "is properly formed" do
        x = p[0]
        y = p[1]
        z = p[2]

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

    ########
    # Body #
    ########

    context "a body" do
      let(:p) { body("") }

      it "is a CompoundStatement" do
        expect(p).to be_a CompoundStatement
      end

      it "has a local_declarations and a statements" do
        expect(p.local_declarations).to be_a Array
        expect(p.statements).to be_a Array
      end
    end

    context "a local_declarations" do
      let(:p) { body("int x; void *y; string z[2];").local_declarations }

      it "is an array of Declarations" do
        expect(p).to be_a Array
        expect(p[0]).to be_a Declaration
        expect(p[1]).to be_a Declaration
        expect(p[2]).to be_a Declaration
        expect(p[3]).to be_nil
      end

      it "is properly formed" do
        x = p[0]
        y = p[1]
        z = p[2]

        expect(x).to be_a SimpleDeclaration
        expect(x.type_specifier.token.type).to eq(:int)
        expect(x.id.token.type).to eq(:id)
        expect(x.id.token.value).to eq("x")

        expect(y).to be_a PointerDeclaration
        expect(y.type_specifier.token.type).to eq(:void)
        expect(y.id.token.type).to eq(:id)
        expect(y.id.token.value).to eq("y")

        expect(z).to be_a ArrayDeclaration
        expect(z.type_specifier.token.type).to eq(:string)
        expect(z.id.token.type).to eq(:id)
        expect(z.id.token.value).to eq("z")
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int f(void) { int x void y; string z[2]; }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got void")

          p = Parser.new(Scanner.new("int f(void) { int x *y; string z[2]; }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got asterisk")

          p = Parser.new(Scanner.new("int f(void) { int x; void y(void) { } string z[2]; }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got l_paren")
        end
      end
    end

    context "a statements" do
      let(:p) { body("x; y; z;").statements }

      it "is an array of Declarations" do
        expect(p).to be_a Array
        expect(p[0]).to be_a Statement
        expect(p[1]).to be_a Statement
        expect(p[2]).to be_a Statement
        expect(p[3]).to be_nil
      end
    end

    context "an ExpressionStatement" do
      let(:p) { body("x;").statements[0] }

      it "has an Expression" do
        expect(p.expression).to be_a Expression
      end
    end

    context "an empty ExpressionStatement" do
      let(:p) { body("x; ;").statements[1] }

      it "has a nil expression" do
        expect(p.expression).to be_nil
      end
    end
  end
end
