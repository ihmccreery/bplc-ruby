require 'spec_helper'

describe Program do
  let(:p) { Parser.new(Scanner.new("int x; void *y; string z[2];")).parse }

  it "is a Program" do
    expect(p).to be_a Program
  end

  describe "#declarations" do
    it "is an array" do
      expect(p.declarations).to be_a Array
    end

    it "is properly formed" do
      x = p.declarations[0]
      y = p.declarations[1]
      z = p.declarations[2]

      expect(p.declarations[3]).to be_nil

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

describe SimpleDeclaration do
  let(:p) { Parser.new(Scanner.new("int x;")).parse.declarations[0] }

  it "is a SimpleDeclaration that is also a VariableDeclaration" do
    expect(p).to be_a SimpleDeclaration
    expect(p).to be_a VariableDeclaration
  end

  describe "#type_specifier" do
    it "is a TypeSpecifier" do
      expect(p.type_specifier).to be_a TypeSpecifier
    end
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
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

describe PointerDeclaration do
  let(:p) { Parser.new(Scanner.new("int *x;")).parse.declarations[0] }

  it "is a PointerDeclaration that is also a VariableDeclaration" do
    expect(p).to be_a PointerDeclaration
    expect(p).to be_a VariableDeclaration
  end

  describe "#type_specifier" do
    it "is a TypeSpecifier" do
      expect(p.type_specifier).to be_a TypeSpecifier
    end
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
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

describe  ArrayDeclaration do
  let(:p) { Parser.new(Scanner.new("int x[2];")).parse.declarations[0] }

  it "is a ArrayDeclaration that is also a VariableDeclaration" do
    expect(p).to be_a ArrayDeclaration
    expect(p).to be_a VariableDeclaration
  end
  it "is an ArrayDeclaration" do
    expect(p).to be_a ArrayDeclaration
  end

  describe "#type_specifier" do
    it "is a TypeSpecifier" do
      expect(p.type_specifier).to be_a TypeSpecifier
    end
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end

  describe "#size" do
    it "is a Num" do
      expect(p.size).to be_a Num
    end
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

describe FunctionDeclaration do
  let(:p) { Parser.new(Scanner.new("int f(void) { }")).parse.declarations[0] }

  it "is a FunctionDeclaration" do
    expect(p).to be_a FunctionDeclaration
  end

  describe "#type_specifier" do
    it "is a TypeSpecifier" do
      expect(p.type_specifier).to be_a TypeSpecifier
    end
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end

  describe "#params" do
    it "is a Array" do
      expect(p.params).to be_a Array
    end
  end

  describe "#body" do
    it "is a CompoundStatement" do
      expect(p.body).to be_a CompoundStatement
    end
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

  context "with no params" do
    describe "#params" do
      it "is an empty array" do
        expect(p.params).to be_a Array
        expect(p.params).to be_empty
      end
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

  context "with params" do
    let(:p) { Parser.new(Scanner.new("int f(int x, int y, int z) { }")).parse.declarations[0] }

    describe "#params" do
      it "is an array of Params that is properly formed" do
        x = p.params[0]
        y = p.params[1]
        z = p.params[2]

        expect(p.params[3]).to be_nil

        expect(x).to be_a Param
        expect(x.type_specifier.token.type).to eq(:int)
        expect(x.id.token.type).to eq(:id)
        expect(x.id.token.value).to eq("x")

        expect(y).to be_a Param
        expect(y.type_specifier.token.type).to eq(:int)
        expect(y.id.token.type).to eq(:id)
        expect(y.id.token.value).to eq("y")

        expect(z).to be_a Param
        expect(z.type_specifier.token.type).to eq(:int)
        expect(z.id.token.type).to eq(:id)
        expect(z.id.token.value).to eq("z")
      end
    end

    context "that are malformed" do
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

########################
# Declaration Children #
########################

describe TypeSpecifier do
  let(:p) { Parser.new(Scanner.new("int x;")).parse.declarations[0].type_specifier }

  it "is a TypeSpecifier" do
    expect(p).to be_a TypeSpecifier
  end

  describe "#token" do
    it "is a token of the appropriate type" do
      expect(p.token).to be_a Token
      expect(p.token.type).to eq(:int)
    end
  end
end

########
# Body #
########

describe CompoundStatement do
  let(:p) { get_body("") }

  it "is a CompoundStatement" do
    expect(p).to be_a CompoundStatement
  end

  describe "#local_declarations" do
    it "is an array" do
      expect(p.local_declarations).to be_a Array
    end
  end

  describe "#statements" do
    it "is an array" do
      expect(p.statements).to be_a Array
    end
  end

  context "with local_declarations" do
    let(:p) { get_body("int x; void *y; string z[2];") }

    describe "#local_declarations" do
      it "is an array of Declarations that is properly formed" do
        x = p.local_declarations[0]
        y = p.local_declarations[1]
        z = p.local_declarations[2]

        expect(p.local_declarations[3]).to be_nil

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

  context "with statements" do
    let(:p) { get_body("x; y; z;") }

    describe "#statements" do
      it "is an array of Statements that is properly formed" do
        x = p.statements[0]
        y = p.statements[1]
        z = p.statements[2]

        expect(p.statements[3]).to be_nil

        expect(x).to be_a Statement
        expect(x.expression.e.t.f.factor.id.token.type).to eq(:id)
        expect(x.expression.e.t.f.factor.id.token.value).to eq("x")

        expect(y).to be_a Statement
        expect(y.expression.e.t.f.factor.id.token.type).to eq(:id)
        expect(y.expression.e.t.f.factor.id.token.value).to eq("y")

        expect(z).to be_a Statement
        expect(z.expression.e.t.f.factor.id.token.type).to eq(:id)
        expect(z.expression.e.t.f.factor.id.token.value).to eq("z")
      end
    end
  end
end

describe ExpressionStatement do
  let(:p) { get_body("x;").statements[0] }

  describe "#expression" do
    it "is an Expression" do
      expect(p.expression).to be_a Expression
    end
  end

  context "that is empty" do
    let(:p) { get_body("x; ;").statements[1] }

    describe "#expression" do
      it "is a nil expression" do
        expect(p.expression).to be_nil
      end
    end
  end
end

describe SimpleExpression do
  let(:p) { get_body("x;").statements[0].expression }

  it "is a SimpleExpression that is also an Expression" do
    expect(p).to be_a SimpleExpression
    expect(p).to be_a Expression
  end

  describe "#e" do
    it "is an E" do
      expect(p.e).to be_a E
    end
  end
end

describe E do
  let(:p) { get_body("x + y - z;").statements[0].expression.e }

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
    expect(x.t.f.factor.id.token.type).to eq(:id)
    expect(x.t.f.factor.id.token.value).to eq("x")

    expect(y.add_op).to be_a AddOp
    expect(y.add_op.token.type).to eq(:plus)
    expect(y.t.f.factor.id.token.type).to eq(:id)
    expect(y.t.f.factor.id.token.value).to eq("y")

    expect(z.add_op).to be_a AddOp
    expect(z.add_op.token.type).to eq(:minus)
    expect(z.t.f.factor.id.token.type).to eq(:id)
    expect(z.t.f.factor.id.token.value).to eq("z")
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

describe T do
  let(:p) { get_body("x * y / z % w;").statements[0].expression.e.t }

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
    expect(x.f.factor.id.token.type).to eq(:id)
    expect(x.f.factor.id.token.value).to eq("x")

    expect(y.mul_op).to be_a MulOp
    expect(y.mul_op.token.type).to eq(:asterisk)
    expect(y.f.factor.id.token.type).to eq(:id)
    expect(y.f.factor.id.token.value).to eq("y")

    expect(z.mul_op).to be_a MulOp
    expect(z.mul_op.token.type).to eq(:slash)
    expect(z.f.factor.id.token.type).to eq(:id)
    expect(z.f.factor.id.token.value).to eq("z")

    expect(w.mul_op).to be_a MulOp
    expect(w.mul_op.token.type).to eq(:percent)
    expect(w.f.factor.id.token.type).to eq(:id)
    expect(w.f.factor.id.token.value).to eq("w")
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

describe MinusF do
  let(:p) { get_body("-x;").statements[0].expression.e.t.f }

  it "is a MinusF" do
    expect(p).to be_a MinusF
  end

  describe "#f" do
    it "is an F" do
      expect(p.f).to be_a F
    end
  end
end

describe PointerF do
  let(:p) { get_body("*x;").statements[0].expression.e.t.f }

  it "is a PointerF that is also an F" do
    expect(p).to be_a PointerF
    expect(p).to be_a F
  end

  describe "#factor" do
    it "is a Factor" do
      expect(p.factor).to be_a Factor
    end
  end
end

describe AddressF do
  let(:p) { get_body("&x;").statements[0].expression.e.t.f }

  it "is a AddressF that is also an F" do
    expect(p).to be_a AddressF
    expect(p).to be_a F
  end

  describe "#factor" do
    it "is a Factor" do
      expect(p.factor).to be_a Factor
    end
  end
end

describe SimpleF do
  let(:p) { get_body("x;").statements[0].expression.e.t.f }

  it "is a SimpleF that is also an F" do
    expect(p).to be_a SimpleF
    expect(p).to be_a F
  end

  describe "#factor" do
    it "is a Factor" do
      expect(p.factor).to be_a Factor
    end
  end
end

describe SimpleFactor do
  let(:p) { get_factor("x") }

  it "is an SimpleFactor that is also a Factor" do
    expect(p).to be_a SimpleFactor
    expect(p).to be_a Factor
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end
end

describe Id do
  let(:p) { Parser.new(Scanner.new("int x;")).parse.declarations[0].id }

  it "is a Id" do
    expect(p).to be_a Id
  end

  describe "#token" do
    it "is a token of the appropriate type and value" do
      expect(p.token).to be_a Token
      expect(p.token.type).to eq(:id)
      expect(p.token.value).to eq("x")
    end
  end
end

describe Num do
  let(:p) { Parser.new(Scanner.new("int x[2];")).parse.declarations[0].size }

  it "is a Num" do
    expect(p).to be_a Num
  end

  describe "#token" do
    it "is a token of the appropriate type and value" do
      expect(p.token).to be_a Token
      expect(p.token.type).to eq(:num)
      expect(p.token.value).to eq("2")
    end
  end
end
