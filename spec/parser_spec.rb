require 'spec_helper'

describe Parser do
  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(Parser.new(Scanner.new("int x;"))).to be_a Parser
    end
  end

  describe "#parse" do
    it "returns a Program that is also an Ast" do
      p = Parser.new(Scanner.new("int x;")).parse
      expect(p).to be_a Program
      expect(p).to be_a Ast
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

      it "is a SimpleDeclaration that is also a VariableDeclaration" do
        expect(p).to be_a SimpleDeclaration
        expect(p).to be_a VariableDeclaration
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

      it "is a PointerDeclaration that is also a VariableDeclaration" do
        expect(p).to be_a PointerDeclaration
        expect(p).to be_a VariableDeclaration
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

      it "is a ArrayDeclaration that is also a VariableDeclaration" do
        expect(p).to be_a ArrayDeclaration
        expect(p).to be_a VariableDeclaration
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

    context "a SimpleExpression" do
      let(:p) { body("x;").statements[0].expression }

      it "is a SimpleExpression that is also an Expression" do
        expect(p).to be_a SimpleExpression
        expect(p).to be_a Expression
      end

      it "has an e" do
        expect(p.e).to be_a E
      end
    end

    context "an E" do
      let(:p) { body("x + y - z;").statements[0].expression.e }

      it "is a nested set of Es" do
        expect(p).to be_a E
        expect(p.e).to be_a E
        expect(p.e.e).to be_a E
        expect(p.e.e.e).to be_nil
      end

      it "is properly nested" do
        x = p.e.e
        y = p.e
        z = p

        expect(x.add_op).to be_nil
        # TODO F shouldn't actually act this way
        expect(x.t.f.factor.token.type).to eq(:id)
        expect(x.t.f.factor.token.value).to eq("x")

        expect(y.add_op).to be_a AddOp
        expect(y.add_op.token.type).to eq(:plus)
        # TODO F shouldn't actually act this way
        expect(y.t.f.factor.token.type).to eq(:id)
        expect(y.t.f.factor.token.value).to eq("y")

        expect(z.add_op).to be_a AddOp
        expect(z.add_op.token.type).to eq(:minus)
        # TODO F shouldn't actually act this way
        expect(z.t.f.factor.token.type).to eq(:id)
        expect(z.t.f.factor.token.value).to eq("z")
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int f(void) { x + y z; }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got id")

          p = Parser.new(Scanner.new("int f(void) { x ++ y + z; }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected id, got plus")
        end
      end
    end

    context "a T" do
      let(:p) { body("x * y / z % w;").statements[0].expression.e.t }

      it "is a nested set of Ts" do
        expect(p).to be_a T
        expect(p.t).to be_a T
        expect(p.t.t).to be_a T
        expect(p.t.t.t).to be_a T
        expect(p.t.t.t.t).to be_nil
      end

      it "is properly nested" do
        x = p.t.t.t
        y = p.t.t
        z = p.t
        w = p

        expect(x.mul_op).to be_nil
        # TODO F shouldn't actually act this way
        expect(x.f.factor.token.type).to eq(:id)
        expect(x.f.factor.token.value).to eq("x")

        expect(y.mul_op).to be_a MulOp
        expect(y.mul_op.token.type).to eq(:asterisk)
        # TODO F shouldn't actually act this way
        expect(y.f.factor.token.type).to eq(:id)
        expect(y.f.factor.token.value).to eq("y")

        expect(z.mul_op).to be_a MulOp
        expect(z.mul_op.token.type).to eq(:slash)
        # TODO F shouldn't actually act this way
        expect(z.f.factor.token.type).to eq(:id)
        expect(z.f.factor.token.value).to eq("z")

        expect(w.mul_op).to be_a MulOp
        expect(w.mul_op.token.type).to eq(:percent)
        # TODO F shouldn't actually act this way
        expect(w.f.factor.token.type).to eq(:id)
        expect(w.f.factor.token.value).to eq("w")
      end

      context "that is malformed" do
        it "raises SyntaxErrors" do
          p = Parser.new(Scanner.new("int f(void) { x * y z; }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got id")

          p = Parser.new(Scanner.new("int f(void) { x */ y + z; }"))
          expect{p.parse}.to raise_error(SyntaxError, "expected id, got slash")
        end
      end
    end

    context "arithmetic operations" do
      let(:p) { body("x + y * z - w / v;").statements[0].expression.e }

      it "are properly nested" do
        # p:
        #   add_op: -
        #   e:
        #     add_op: +
        #     e:
        #       add_op: nil
        #       e: nil
        #       t:
        #         mul_op: nil
        #         t: nil
        #         f: x
        #     t:
        #       mul_op: *
        #       t:
        #         mul_op: nil
        #         t: nil
        #         f: y
        #       f: z
        #   t:
        #     mul_op: /
        #     t:
        #       mul_op: nil
        #       t: nil
        #       f: w
        #     f: v
        y_times_z = p.e.t
        w_over_v = p.t
        x_plus_y_z = p.e
        minus = p

        expect(y_times_z.mul_op.token.type).to eq(:asterisk)
        expect(w_over_v.mul_op.token.type).to eq(:slash)
        expect(x_plus_y_z.add_op.token.type).to eq(:plus)
        expect(minus.add_op.token.type).to eq(:minus)

        x = p.e.e.t.f
        y = p.e.t.t.f
        z = p.e.t.f
        w = p.t.t.f
        v = p.t.f

        # TODO F shouldn't actually act this way
        expect(x.factor.token.value).to eq("x")
        # TODO F shouldn't actually act this way
        expect(y.factor.token.value).to eq("y")
        # TODO F shouldn't actually act this way
        expect(z.factor.token.value).to eq("z")
        # TODO F shouldn't actually act this way
        expect(w.factor.token.value).to eq("w")
        # TODO F shouldn't actually act this way
        expect(v.factor.token.value).to eq("v")
      end
    end

    context "a MinusF" do
      let(:p) { body("-x;").statements[0].expression.e.t.f }

      it "is a MinusF" do
        expect(p).to be_a MinusF
      end

      it "has an f" do
        expect(p.f).to be_a F
      end
    end

    context "a PointerF" do
      let(:p) { body("*x;").statements[0].expression.e.t.f }

      it "is a PointerF that is also an F" do
        expect(p).to be_a PointerF
        expect(p).to be_a F
      end

      it "has a factor" do
        expect(p.factor).to be_a Factor
      end
    end

    context "a AddressF" do
      let(:p) { body("&x;").statements[0].expression.e.t.f }

      it "is a AddressF that is also an F" do
        expect(p).to be_a AddressF
        expect(p).to be_a F
      end

      it "has a factor" do
        expect(p.factor).to be_a Factor
      end
    end

    context "a SimpleF" do
      let(:p) { body("x;").statements[0].expression.e.t.f }

      it "is a SimpleF that is also an F" do
        expect(p).to be_a SimpleF
        expect(p).to be_a F
      end

      it "has a factor" do
        expect(p.factor).to be_a Factor
      end
    end
  end
end
