require 'spec_helper'

###########
# Program #
###########

describe Program do
  let(:p) { Parser.new(Scanner.new("int x; void *y; string z[2];")).parse }

  it "is a Program" do
    expect(p).to be_a Program
  end

  # #declarations

  it "has properly formed declarations" do
    expect(p.declarations[0].symbol).to eq("x")
    expect(p.declarations[1].symbol).to eq("y")
    expect(p.declarations[2].symbol).to eq("z")
    expect(p.declarations[3]).to be_nil
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int x; void *y;; string z[2];", "expected eof, got semicolon")
      expect_syntax_error("int x; y; string z;", "expected eof, got id")
      expect_syntax_error("int x; void *y string z[2];", "expected semicolon, got string")
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

  it "has the correct attributes" do
    expect(p.type).to eq(:int)
    expect(p.symbol).to eq("x")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("x;", "expected type_specifier, got id")
      expect_syntax_error("int ;", "expected id, got semicolon")
      expect_syntax_error("int x", "expected semicolon, got eof")
    end
  end
end

describe PointerDeclaration do
  let(:p) { Parser.new(Scanner.new("int *x;")).parse.declarations[0] }

  it "is a PointerDeclaration" do
    expect(p).to be_a PointerDeclaration
  end

  it "has the correct attributes" do
    expect(p.type).to eq(:int)
    expect(p.symbol).to eq("x")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int x*;", "expected semicolon, got asterisk")
      expect_syntax_error("int *;", "expected id, got semicolon")
      expect_syntax_error("*x;", "expected type_specifier, got asterisk")
    end
  end
end

describe  ArrayDeclaration do
  let(:p) { Parser.new(Scanner.new("int x[2];")).parse.declarations[0] }

  it "is a ArrayDeclaration " do
    expect(p).to be_a ArrayDeclaration
  end

  it "has the correct attributes" do
    expect(p.type).to eq(:int)
    expect(p.symbol).to eq("x")
    expect(p.size).to eq(2)
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int [2]x;", "expected id, got l_bracket")
      expect_syntax_error("int x[2;", "expected r_bracket, got semicolon")
      expect_syntax_error("x[2];", "expected type_specifier, got id")
    end
  end
end

describe FunctionDeclaration do
  let(:p) { Parser.new(Scanner.new("int f(void) { }")).parse.declarations[0] }

  it "is a FunctionDeclaration" do
    expect(p).to be_a FunctionDeclaration
  end

  it "has the correct attributes" do
    expect(p.type).to eq(:int)
    expect(p.symbol).to eq("f")
    expect(p.body).to be_a CompoundStatement
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f()", "expected type_specifier, got r_paren")
      expect_syntax_error("int f( { }", "expected type_specifier, got l_brace")
      expect_syntax_error("int f(void) { ", "expected r_brace, got eof")
      expect_syntax_error("int f(void) } ", "expected l_brace, got r_brace")
    end
  end

  # #params

  context "with no params" do
    it "has no params" do
      expect(p.params).to be_a Array
      expect(p.params).to be_empty
    end
  end

  context "with params" do
    let(:p) { Parser.new(Scanner.new("int f(int x, int *y, int z[]) { }")).parse.declarations[0] }

    it "has properly formed params" do
      expect(p.params[0].symbol).to eq("x")
      expect(p.params[1].symbol).to eq("y")
      expect(p.params[2].symbol).to eq("z")
      expect(p.params[3]).to be_nil
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f() { }", "expected type_specifier, got r_paren")
      expect_syntax_error("int f(void void) { }", "expected r_paren, got void")
      expect_syntax_error("int f(int x, int y,, int z) { }", "expected type_specifier, got comma")
      expect_syntax_error("int f(int x, y, int z) { }", "expected type_specifier, got id")
      expect_syntax_error("int f(int x, int y int z) { }", "expected r_paren, got int")
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

  it "has the correct attributes" do
    expect(p.type).to eq(:int)
    expect(p.symbol).to eq("x")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(x) { }", "expected type_specifier, got id")
      expect_syntax_error("int f(int) { }", "expected id, got r_paren")
    end
  end
end

describe PointerParam do
  let(:p) { Parser.new(Scanner.new("int f(int *x) { }")).parse.declarations[0].params[0] }

  it "is a PointerParam" do
    expect(p).to be_a PointerParam
  end

  it "has the correct attributes" do
    expect(p.type).to eq(:int)
    expect(p.symbol).to eq("x")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(int x*) { }", "expected r_paren, got asterisk")
      expect_syntax_error("int f(int*) { }", "expected id, got r_paren")
    end
  end
end

describe ArrayParam do
  let(:p) { Parser.new(Scanner.new("int f(int x[]) { }")).parse.declarations[0].params[0] }

  it "is a ArrayParam" do
    expect(p).to be_a ArrayParam
  end

  it "has the correct attributes" do
    expect(p.type).to eq(:int)
    expect(p.symbol).to eq("x")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(int x[) { }", "expected r_bracket, got r_paren")
      expect_syntax_error("int f(int[] x) { }", "expected id, got l_bracket")
    end
  end
end

##############
# Statements #
##############

describe CompoundStatement do
  let(:p) { get_body("int x; void *y; string z[2]; x; y; z;") }

  it "is a CompoundStatement" do
    expect(p).to be_a CompoundStatement
  end

  it "has properly formed declarations" do
    expect(p.local_declarations[0].symbol).to eq("x")
    expect(p.local_declarations[1].symbol).to eq("y")
    expect(p.local_declarations[2].symbol).to eq("z")
    expect(p.local_declarations[3]).to be_nil
  end

  # FIXME
  it "has properly formed statements" do
    expect(p.statements[0].expression.value).to eq("x")
    expect(p.statements[1].expression.value).to eq("y")
    expect(p.statements[2].expression.value).to eq("z")
    expect(p.statements[3]).to be_nil
  end

  it "properly nests" do
    expect(get_body("{x;}").statements[0]).to be_a CompoundStatement
    expect(get_body("{{x;}}").statements[0].statements[0]).to be_a CompoundStatement
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { int x void y; }", "expected semicolon, got void")
      expect_syntax_error("int f(void) { int x; void y(void) { } string z[2]; }", "expected semicolon, got l_paren")
      expect_syntax_error("int f(void) { x; void y; }", "expected r_brace, got void")
    end
  end
end

describe ExpressionStatement do
  let(:p) { get_body("x;").statements[0] }

  it "is an ExpressionStatement" do
    expect(p).to be_a ExpressionStatement
  end

  context "with an expression" do
    it "has an expression" do
      expect(p.expression).to be_a Expression
    end
  end

  context "that is empty" do
    let(:p) { get_body(";").statements[0] }

    it "has a nil expression" do
      expect(p.expression).to be_nil
    end
  end
end

describe IfStatement do
  let(:p) { get_body("if (x) y; else z;").statements[0] }

  it "is an IfStatement" do
    expect(p).to be_a IfStatement
  end

  it "has the correct attributes" do
    expect(p.condition).to be_a Expression
    expect(p.body).to be_a Statement
    expect(p.else_body).to be_a Statement
  end

  # FIXME
  it "is properly formed" do
    expect(p.body.expression.value).to eq("y")
    expect(p.else_body.expression.value).to eq("z")
  end

  context "with no else statement" do
    let(:p) { get_body("if (x) y;").statements[0] }

    it "has no else_body" do
      expect(p.else_body).to be_nil
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { if x {y;} }", "expected l_paren, got id")
      expect_syntax_error("int f(void) { if (x {y;} }", "expected r_paren, got l_brace")
      expect_syntax_error("int f(void) { if (x;) {y;} }", "expected r_paren, got semicolon")
    end
  end
end

describe WhileStatement do
  let(:p) { get_body("while (x) y;").statements[0] }

  it "is an WhileStatement" do
    expect(p).to be_a WhileStatement
  end

  it "has the correct attributes" do
    expect(p.condition).to be_a Expression
    expect(p.body).to be_a Statement
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { while x {y;} }", "expected l_paren, got id")
      expect_syntax_error("int f(void) { while (x {y;} }", "expected r_paren, got l_brace")
      expect_syntax_error("int f(void) { while (x;) {y;} }", "expected r_paren, got semicolon")
    end
  end
end

describe ReturnStatement do
  let(:p) { get_body("return y;").statements[0] }

  it "is an ReturnStatement" do
    expect(p).to be_a ReturnStatement
  end

  it "has the correct attributes" do
    expect(p.value).to be_a Expression
  end

  context "with no value" do
    let(:p) { get_body("return;").statements[0] }

    it "has a nil value" do
      expect(p.value).to be_nil
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { return }", "expected id, got r_brace")
      expect_syntax_error("int f(void) { return x }", "expected semicolon, got r_brace")
    end
  end
end

describe WriteStatement do
  let(:p) { get_body("write(x);").statements[0] }

  it "is an WriteStatement" do
    expect(p).to be_a WriteStatement
  end

  it "has the correct attributes" do
    expect(p.value).to be_a Expression
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { write(); }", "expected id, got r_paren")
      expect_syntax_error("int f(void) { write(x) }", "expected semicolon, got r_brace")
      expect_syntax_error("int f(void) { write(x;) }", "expected r_paren, got semicolon")
    end
  end
end

describe WritelnStatement do
  let(:p) { get_body("writeln();").statements[0] }

  it "is an WritelnStatement" do
    expect(p).to be_a WritelnStatement
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { writeln() }", "expected semicolon, got r_brace")
      expect_syntax_error("int f(void) { writeln(x); }", "expected r_paren, got id")
      expect_syntax_error("int f(void) { writeln }", "expected l_paren, got r_brace")
    end
  end
end

###############
# Expressions #
###############

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

# TODO
# describe Num do
#   let(:p) { get_factor('2').num }

#   it "is a Num" do
#     expect(p).to be_a Num
#   end

#   describe "#token" do
#     it "is a token of the appropriate type and value" do
#       expect(p.token).to be_a Token
#       expect(p.token.type).to eq(:num)
#       expect(p.token.value).to eq("2")
#     end
#   end
# end
