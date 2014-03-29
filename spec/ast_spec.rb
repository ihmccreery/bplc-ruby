require 'spec_helper'

###########
# Program #
###########

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
      expect(x.type).to eq(:int)
      expect(x.symbol).to eq("x")

      expect(y).to be_a PointerDeclaration
      expect(y.type).to eq(:void)
      expect(y.symbol).to eq("y")

      expect(z).to be_a ArrayDeclaration
      expect(z.type).to eq(:string)
      expect(z.symbol).to eq("z")
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

################
# Declarations #
################

describe SimpleDeclaration do
  let(:p) { Parser.new(Scanner.new("int x;")).parse.declarations[0] }

  it "is a SimpleDeclaration" do
    expect(p).to be_a SimpleDeclaration
  end

  it "extends VariableDeclaration" do
    expect(p.class.superclass).to eq(VariableDeclaration)
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

  it "is a PointerDeclaration" do
    expect(p).to be_a PointerDeclaration
  end

  it "extends VariableDeclaration" do
    expect(p.class.superclass).to eq(VariableDeclaration)
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

  it "is a ArrayDeclaration " do
    expect(p).to be_a ArrayDeclaration
  end

  it "extends VariableDeclaration" do
    expect(p.class.superclass).to eq(VariableDeclaration)
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
        expect(x.type).to eq(:int)
        expect(x.symbol).to eq("x")

        expect(y).to be_a Param
        expect(y.type).to eq(:int)
        expect(y.symbol).to eq("y")

        expect(z).to be_a Param
        expect(z.type).to eq(:int)
        expect(z.symbol).to eq("z")
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

##########
# Params #
##########

describe SimpleParam do
  let(:p) { Parser.new(Scanner.new("int f(int x) { }")).parse.declarations[0].params[0] }

  it "is a SimpleParam" do
    expect(p).to be_a SimpleParam
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
      p = Parser.new(Scanner.new("int f(x) { }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected type_specifier, got id")

      p = Parser.new(Scanner.new("int f(int) { }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected id, got r_paren")
    end
  end
end

describe PointerParam do
  let(:p) { Parser.new(Scanner.new("int f(int *x) { }")).parse.declarations[0].params[0] }

  it "is a PointerParam" do
    expect(p).to be_a PointerParam
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
      p = Parser.new(Scanner.new("int f(int x*) { }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got asterisk")

      p = Parser.new(Scanner.new("int f(int*) { }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected id, got r_paren")
    end
  end
end

describe ArrayParam do
  let(:p) { Parser.new(Scanner.new("int f(int x[]) { }")).parse.declarations[0].params[0] }

  it "is a ArrayParam" do
    expect(p).to be_a ArrayParam
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
      p = Parser.new(Scanner.new("int f(int x[) { }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected r_bracket, got r_paren")

      p = Parser.new(Scanner.new("int f(int[] x) { }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected id, got l_bracket")
    end
  end
end

##############
# Statements #
##############

describe ExpressionStatement do
  let(:p) { get_body("x;").statements[0] }

  it "is an ExpressionStatement" do
    expect(p).to be_a ExpressionStatement
  end

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

describe CompoundStatement do
  let(:p) { get_body("") }

  it "is a CompoundStatement" do
    expect(p).to be_a CompoundStatement
  end

  it "extends Statement" do
    expect(p.class.superclass).to eq(Statement)
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
        expect(x.type).to eq(:int)
        expect(x.symbol).to eq("x")

        expect(y).to be_a PointerDeclaration
        expect(y.type).to eq(:void)
        expect(y.symbol).to eq("y")

        expect(z).to be_a ArrayDeclaration
        expect(z.type).to eq(:string)
        expect(z.symbol).to eq("z")
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
        expect(x.expression.e.t.f.factor.id.value).to eq("x")

        expect(y).to be_a Statement
        expect(y.expression.e.t.f.factor.id.value).to eq("y")

        expect(z).to be_a Statement
        expect(z.expression.e.t.f.factor.id.value).to eq("z")
      end
    end
  end

  context "in another CompoundStatement" do
    let(:p) { get_body("{x;}").statements[0] }

    it "is an CompoundStatement" do
      expect(p).to be_a CompoundStatement
    end

    it "extends Statement" do
      expect(p.class.superclass).to eq(Statement)
    end
  end

  context "in another CompoundStatement in another CompoundStatement" do
    let(:p) { get_body("{{x;}}").statements[0].statements[0] }

    it "is an CompoundStatement" do
      expect(p).to be_a CompoundStatement
    end

    it "extends Statement" do
      expect(p.class.superclass).to eq(Statement)
    end
  end
end

describe IfStatement do
  let(:p) { get_body("if (x) y;").statements[0] }

  it "is an IfStatement" do
    expect(p).to be_a IfStatement
  end

  it "extends Statement" do
    expect(p.class.superclass).to eq(Statement)
  end

  describe "#condition" do
    it "is an Expression" do
      expect(p.condition).to be_a Expression
    end
  end

  describe "#body" do
    it "is a Statement" do
      expect(p.body).to be_a Statement
    end
  end

  describe "#else_body" do
    it "is nil" do
      expect(p.else_body).to be_nil
    end
  end

  context "with an else statement" do
    let(:p) { get_body("if (x) y; else z;").statements[0] }

    describe "#body" do
      it "is a Statement" do
        expect(p.body).to be_a Statement
      end
    end

    describe "#else_body" do
      it "is a Statement" do
        expect(p.else_body).to be_a Statement
      end
    end

    it "is properly formed" do
      expect(p.body.expression.e.t.f.factor.id.value).to eq("y")
      expect(p.else_body.expression.e.t.f.factor.id.value).to eq("z")
    end
  end

  context "with a compound body and else_body" do
    let(:p) { get_body("if (x) {y;} else {z;}").statements[0] }

    describe "#body" do
      it "is a CompoundStatement" do
        expect(p.body).to be_a CompoundStatement
      end
    end

    describe "#else_body" do
      it "is a CompoundStatement" do
        expect(p.else_body).to be_a CompoundStatement
      end
    end

    it "is properly formed" do
      expect(p.body.statements[0].expression.e.t.f.factor.id.value).to eq("y")
      expect(p.else_body.statements[0].expression.e.t.f.factor.id.value).to eq("z")
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      p = Parser.new(Scanner.new("int f(void) { if x {y;} }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected l_paren, got id")

      p = Parser.new(Scanner.new("int f(void) { if (x {y;} }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got l_brace")

      p = Parser.new(Scanner.new("int f(void) { if (x;) {y;} }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got semicolon")
    end
  end
end

describe WhileStatement do
  let(:p) { get_body("while (x) y;").statements[0] }

  it "is an WhileStatement" do
    expect(p).to be_a WhileStatement
  end

  it "extends Statement" do
    expect(p.class.superclass).to eq(Statement)
  end

  describe "#condition" do
    it "is an Expression" do
      expect(p.condition).to be_a Expression
    end
  end

  describe "#body" do
    it "is a Statement" do
      expect(p.body).to be_a Statement
    end
  end

  context "with a compound body" do
    let(:p) { get_body("while (x) {y;}").statements[0] }

    describe "#body" do
      it "is a CompoundStatement" do
        expect(p.body).to be_a CompoundStatement
      end
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      p = Parser.new(Scanner.new("int f(void) { while x {y;} }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected l_paren, got id")

      p = Parser.new(Scanner.new("int f(void) { while (x {y;} }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got l_brace")

      p = Parser.new(Scanner.new("int f(void) { while (x;) {y;} }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got semicolon")
    end
  end
end

describe ReturnStatement do
  let(:p) { get_body("return y;").statements[0] }

  it "is an ReturnStatement" do
    expect(p).to be_a ReturnStatement
  end

  it "extends Statement" do
    expect(p.class.superclass).to eq(Statement)
  end

  describe "#value" do
    it "is an Expression" do
      expect(p.value).to be_a Expression
    end
  end

  context "with no value" do
    let(:p) { get_body("return;").statements[0] }

    describe "#value" do
      it "is nil" do
        expect(p.value).to be_nil
      end
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      p = Parser.new(Scanner.new("int f(void) { return }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected id, got r_brace")

      p = Parser.new(Scanner.new("int f(void) { return x }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got r_brace")
    end
  end
end

describe WriteStatement do
  let(:p) { get_body("write(x);").statements[0] }

  it "is an WriteStatement" do
    expect(p).to be_a WriteStatement
  end

  it "extends Statement" do
    expect(p.class.superclass).to eq(Statement)
  end

  describe "#value" do
    it "is an Expression" do
      expect(p.value).to be_a Expression
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      p = Parser.new(Scanner.new("int f(void) { write(); }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected id, got r_paren")

      p = Parser.new(Scanner.new("int f(void) { write(x) }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got r_brace")

      p = Parser.new(Scanner.new("int f(void) { write(x;) }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got semicolon")
    end
  end
end

describe WritelnStatement do
  let(:p) { get_body("writeln();").statements[0] }

  it "is an WritelnStatement" do
    expect(p).to be_a WritelnStatement
  end

  it "extends Statement" do
    expect(p.class.superclass).to eq(Statement)
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      p = Parser.new(Scanner.new("int f(void) { writeln() }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected semicolon, got r_brace")

      p = Parser.new(Scanner.new("int f(void) { writeln(x); }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected r_paren, got id")

      p = Parser.new(Scanner.new("int f(void) { writeln }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected l_paren, got r_brace")
    end
  end
end

###############
# Expressions #
###############

describe SimpleExpression do
  let(:p) { get_body("x;").statements[0].expression }

  it "is a SimpleExpression" do
    expect(p).to be_a SimpleExpression
  end

  it "extends Expression" do
    expect(p.class.superclass).to eq(Expression)
  end

  describe "#e" do
    it "is an E" do
      expect(p.e).to be_a E
    end
  end
end

describe AssignmentExpression do
  let(:p) { get_body("x = y;").statements[0].expression }

  it "is a AssignmentExpression" do
    expect(p).to be_a AssignmentExpression
  end

  it "extends Expression" do
    expect(p.class.superclass).to eq(Expression)
  end

  describe "#lhs" do
    it "is a Var" do
      expect(p.lhs).to be_a Var
    end
  end

  describe "#rhs" do
    it "is an Expression" do
      expect(p.rhs).to be_a Expression
    end
  end

  it "is properly formed" do
    expect(p.lhs.id.value).to eq("x")
    expect(p.rhs.e.t.f.factor.id.value).to eq("y")
  end

  context "that are chained" do
    let(:p) { get_body("x = y = z;").statements[0].expression }

    it "are properly formed" do
      expect(p.lhs.id.value).to eq("x")
      expect(p.rhs.lhs.id.value).to eq("y")
      expect(p.rhs.rhs.e.t.f.factor.id.value).to eq("z")
    end
  end
end

describe Var do
  context "that is malformed" do
    it "raises SyntaxErrors" do
      p = Parser.new(Scanner.new("int f(void) { x + y = z; }"))
      expect{p.parse}.to raise_error(SyntaxError, "lhs not assignable")

      p = Parser.new(Scanner.new("int f(void) { x * y = z; }"))
      expect{p.parse}.to raise_error(SyntaxError, "lhs not assignable")

      p = Parser.new(Scanner.new("int f(void) { &x = y; }"))
      expect{p.parse}.to raise_error(SyntaxError, "lhs not assignable")

      p = Parser.new(Scanner.new("int f(void) { read() = y; }"))
      expect{p.parse}.to raise_error(SyntaxError, "lhs not assignable")
    end
  end
end

describe SimpleVar do
  let(:p) { get_body("x = y;").statements[0].expression.lhs }

  it "is a SimpleVar" do
    expect(p).to be_a SimpleVar
  end

  it "extends Var" do
    expect(p.class.superclass).to eq(Var)
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end
end

describe ArrayVar do
  let(:p) { get_body("x[1] = y;").statements[0].expression.lhs }

  it "is a ArrayVar" do
    expect(p).to be_a ArrayVar
  end

  it "extends Var" do
    expect(p.class.superclass).to eq(Var)
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end

  describe "#index" do
    it "is an Expression" do
      expect(p.index).to be_a Expression
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      p = Parser.new(Scanner.new("int f(void) { x [] = z; }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected id, got r_bracket")
    end
  end
end

describe PointerVar do
  let(:p) { get_body("*x = y;").statements[0].expression.lhs }

  it "is a PointerVar" do
    expect(p).to be_a PointerVar
  end

  it "extends Var" do
    expect(p.class.superclass).to eq(Var)
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      p = Parser.new(Scanner.new("int f(void) { x* = z; }"))
      expect{p.parse}.to raise_error(SyntaxError, "expected id, got gets")
    end
  end
end


describe ComparisonExpression do
  let(:p) { get_body("x == y;").statements[0].expression }

  it "is a ComparisonExpression" do
    expect(p).to be_a ComparisonExpression
  end

  it "extends Expression" do
    expect(p.class.superclass).to eq(Expression)
  end

  describe "#lhs" do
    it "is an E" do
      expect(p.lhs).to be_a E
    end
  end

  describe "#rhs" do
    it "is an E" do
      expect(p.rhs).to be_a E
    end
  end

  context "with a leq rel_op" do
    let(:p) { get_body("x <= y;").statements[0].expression }

    it "is properly formed" do
      expect(p.rel_op.type).to eq(:leq)
      expect(p.lhs.t.f.factor.id.value).to eq("x")
      expect(p.rhs.t.f.factor.id.value).to eq("y")
    end
  end

  context "with a lt rel_op" do
    let(:p) { get_body("x < y;").statements[0].expression }

    it "is properly formed" do
      expect(p.rel_op.type).to eq(:lt)
      expect(p.lhs.t.f.factor.id.value).to eq("x")
      expect(p.rhs.t.f.factor.id.value).to eq("y")
    end
  end

  context "with a eq rel_op" do
    let(:p) { get_body("x == y;").statements[0].expression }

    it "is properly formed" do
      expect(p.rel_op.type).to eq(:eq)
      expect(p.lhs.t.f.factor.id.value).to eq("x")
      expect(p.rhs.t.f.factor.id.value).to eq("y")
    end
  end

  context "with a neq rel_op" do
    let(:p) { get_body("x != y;").statements[0].expression }

    it "is properly formed" do
      expect(p.rel_op.type).to eq(:neq)
      expect(p.lhs.t.f.factor.id.value).to eq("x")
      expect(p.rhs.t.f.factor.id.value).to eq("y")
    end
  end

  context "with a gt rel_op" do
    let(:p) { get_body("x > y;").statements[0].expression }

    it "is properly formed" do
      expect(p.rel_op.type).to eq(:gt)
      expect(p.lhs.t.f.factor.id.value).to eq("x")
      expect(p.rhs.t.f.factor.id.value).to eq("y")
    end
  end

  context "with a geq rel_op" do
    let(:p) { get_body("x >= y;").statements[0].expression }

    it "is properly formed" do
      expect(p.rel_op.type).to eq(:geq)
      expect(p.lhs.t.f.factor.id.value).to eq("x")
      expect(p.rhs.t.f.factor.id.value).to eq("y")
    end
  end
end

##############
# arithmetic #
##############

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
    expect(x.t.f.factor.id.value).to eq("x")

    expect(y.add_op).to be_a AddOp
    expect(y.add_op.type).to eq(:plus)
    expect(y.t.f.factor.id.value).to eq("y")

    expect(z.add_op).to be_a AddOp
    expect(z.add_op.type).to eq(:minus)
    expect(z.t.f.factor.id.value).to eq("z")
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
    expect(x.f.factor.id.value).to eq("x")

    expect(y.mul_op).to be_a MulOp
    expect(y.mul_op.type).to eq(:asterisk)
    expect(y.f.factor.id.value).to eq("y")

    expect(z.mul_op).to be_a MulOp
    expect(z.mul_op.type).to eq(:slash)
    expect(z.f.factor.id.value).to eq("z")

    expect(w.mul_op).to be_a MulOp
    expect(w.mul_op.type).to eq(:percent)
    expect(w.f.factor.id.value).to eq("w")
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

describe AddressF do
  let(:p) { get_body("&x;").statements[0].expression.e.t.f }

  it "is a AddressF" do
    expect(p).to be_a AddressF
  end

  it "extends F" do
    expect(p.class.superclass).to eq(F)
  end

  describe "#factor" do
    it "is a Factor" do
      expect(p.factor).to be_a Factor
    end
  end
end

describe PointerF do
  let(:p) { get_body("*x;").statements[0].expression.e.t.f }

  it "is a PointerF" do
    expect(p).to be_a PointerF
  end

  it "extends F" do
    expect(p.class.superclass).to eq(F)
  end

  describe "#factor" do
    it "is a Factor" do
      expect(p.factor).to be_a Factor
    end
  end
end

describe SimpleF do
  let(:p) { get_body("x;").statements[0].expression.e.t.f }

  it "is a SimpleF" do
    expect(p).to be_a SimpleF
  end

  it "extends F" do
    expect(p.class.superclass).to eq(F)
  end

  describe "#factor" do
    it "is a Factor" do
      expect(p.factor).to be_a Factor
    end
  end
end

###########
# Factors #
###########

describe ExpressionFactor do
  let(:p) { get_factor("(x)") }

  it "is an ExpressionFactor" do
    expect(p).to be_a ExpressionFactor
  end

  it "extends Factor" do
    expect(p.class.superclass).to eq(Factor)
  end

  describe "#expression" do
    it "is an expression" do
      expect(p.expression).to be_a Expression
    end
  end
end

describe FunCallFactor do
  let(:p) { get_factor("f()") }

  it "is a FunCallFactor" do
    expect(p).to be_a FunCallFactor
  end

  it "extends Factor" do
    expect(p.class.superclass).to eq(Factor)
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end

  context "with no args" do
    describe "#args" do
      it "is an empty array" do
        expect(p.args).to be_a Array
        expect(p.args).to be_empty
      end
    end
  end

  context "with args" do
    let(:p) { get_factor("f(x, 2, y+z)") }

    describe "#args" do
      it "is an array of Expressions that is properly formed" do
        x = p.args[0]
        two = p.args[1]
        y_z = p.args[2]

        expect(p.args[3]).to be_nil

        expect(x).to be_a Expression
        expect(x.e.t.f.factor.id.type).to eq(:id)
        expect(x.e.t.f.factor.id.value).to eq("x")

        expect(two).to be_a Expression
        expect(two.e.t.f.factor.num.type).to eq(:num)
        expect(two.e.t.f.factor.num.token.value).to eq("2")

        expect(y_z).to be_a Expression
        expect(y_z.e.e.t.f.factor.id.value).to eq("y")
        expect(y_z.e.add_op.type).to eq(:plus)
        expect(y_z.e.t.f.factor.id.value).to eq("z")
      end
    end
  end
end

describe ReadFactor do
  let(:p) { get_factor("read()") }

  it "is an ReadFactor" do
    expect(p).to be_a ReadFactor
  end

  it "extends Factor" do
    expect(p.class.superclass).to eq(Factor)
  end

  describe "#read" do
    it "is a Read" do
      expect(p.read).to be_a Read
    end
  end
end

describe SimpleFactor do
  let(:p) { get_factor("x") }

  it "is a SimpleFactor" do
    expect(p).to be_a SimpleFactor
  end

  it "extends Factor" do
    expect(p.class.superclass).to eq(Factor)
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end
end

describe ArrayFactor do
  let(:p) { get_factor("x[y]") }

  it "is a ArrayFactor" do
    expect(p).to be_a ArrayFactor
  end

  it "extends Factor" do
    expect(p.class.superclass).to eq(Factor)
  end

  describe "#id" do
    it "is an Id" do
      expect(p.id).to be_a Id
    end
  end

  describe "#index" do
    it "is an Expression" do
      expect(p.index).to be_a Expression
    end
  end
end

describe NumFactor do
  let(:p) { get_factor("2") }

  it "is a NumFactor" do
    expect(p).to be_a NumFactor
  end

  it "extends Factor" do
    expect(p.class.superclass).to eq(Factor)
  end

  describe "#num" do
    it "is an Num" do
      expect(p.num).to be_a Num
    end
  end
end

describe StrFactor do
  let(:p) { get_factor('"str"') }

  it "is a StrFactor" do
    expect(p).to be_a StrFactor
  end

  it "extends Factor" do
    expect(p.class.superclass).to eq(Factor)
  end

  describe "#str" do
    it "is an Str" do
      expect(p.str).to be_a Str
    end
  end
end

#####################
# general terminals #
#####################

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

describe AddOp do
  let(:p) { get_body("x + y;").statements[0].expression.e.add_op }

  it "is a AddOp" do
    expect(p).to be_a AddOp
  end

  describe "#token" do
    it "is a token of the appropriate type and value" do
      expect(p.token).to be_a Token
      expect(p.token.type).to eq(:plus)
      expect(p.token.value).to eq("+")
    end
  end
end

describe MulOp do
  let(:p) { get_body("x * y;").statements[0].expression.e.t.mul_op }

  it "is a MulOp" do
    expect(p).to be_a MulOp
  end

  describe "#token" do
    it "is a token of the appropriate type and value" do
      expect(p.token).to be_a Token
      expect(p.token.type).to eq(:asterisk)
      expect(p.token.value).to eq("*")
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

describe Str do
  let(:p) { get_factor('"str"').str }

  it "is a Str" do
    expect(p).to be_a Str
  end

  describe "#token" do
    it "is a token of the appropriate type and value" do
      expect(p.token).to be_a Token
      expect(p.token.type).to eq(:str)
      expect(p.token.value).to eq("str")
    end
  end
end

describe Read do
  let(:p) { get_factor("read()").read }

  it "is a Read" do
    expect(p).to be_a Read
  end

  describe "#token" do
    it "is a token of the appropriate type" do
      expect(p.token).to be_a Token
      expect(p.token.type).to eq(:read)
    end
  end
end
