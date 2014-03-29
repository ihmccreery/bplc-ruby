require 'spec_helper'

###########
# Program #
###########

describe Program do
  let(:p) { parse_program("int x; void *y; string z[2];") }

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
  let(:p) { parse_declaration("int x;") }

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
  let(:p) { parse_declaration("int *x;") }

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
  let(:p) { parse_declaration("int x[2];") }

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
  let(:p) { parse_declaration("int f(void) { }") }

  it "is a FunctionDeclaration" do
    expect(p).to be_a FunctionDeclaration
  end

  it "has the correct attributes" do
    expect(p.type).to eq(:int)
    expect(p.symbol).to eq("f")
    expect(p.body).to be_a CompoundStmt
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
    let(:p) { parse_declaration("int f(int x, int *y, int z[]) { }") }

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
  let(:p) { parse_param("int x") }

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
  let(:p) { parse_param("int *x") }

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
  let(:p) { parse_param("int x[]") }

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

#########
# Stmts #
#########

describe CompoundStmt do
  let(:p) { parse_stmt("{int x; void *y; string z[2]; x; y; z;}") }

  it "is a CompoundStmt" do
    expect(p).to be_a CompoundStmt
  end

  it "has properly formed declarations" do
    expect(p.local_declarations[0].symbol).to eq("x")
    expect(p.local_declarations[1].symbol).to eq("y")
    expect(p.local_declarations[2].symbol).to eq("z")
    expect(p.local_declarations[3]).to be_nil
  end

  it "has properly formed stmts" do
    expect(p.stmts[0].exp.symbol).to eq("x")
    expect(p.stmts[1].exp.symbol).to eq("y")
    expect(p.stmts[2].exp.symbol).to eq("z")
    expect(p.stmts[3]).to be_nil
  end

  it "properly nests" do
    expect(parse_stmt("{{x;}}").stmts[0]).to be_a CompoundStmt
    expect(parse_stmt("{{{x;}}}").stmts[0].stmts[0]).to be_a CompoundStmt
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { int x void y; }", "expected semicolon, got void")
      expect_syntax_error("int f(void) { int x; void y(void) { } string z[2]; }", "expected semicolon, got l_paren")
      expect_syntax_error("int f(void) { x; void y; }", "expected r_brace, got void")
    end
  end
end

describe ExpStmt do
  let(:p) { parse_stmt("x;") }

  it "is an ExpStmt" do
    expect(p).to be_a ExpStmt
  end

  context "with an exp" do
    it "has an exp" do
      expect(p.exp).to be_a Exp
    end
  end

  context "that is empty" do
    let(:p) { parse_stmt(";") }

    it "has a nil exp" do
      expect(p.exp).to be_nil
    end
  end
end

describe IfStmt do
  let(:p) { parse_stmt("if (x) y; else z;") }

  it "is an IfStmt" do
    expect(p).to be_a IfStmt
  end

  it "has the correct attributes" do
    expect(p.condition).to be_a Exp
    expect(p.body).to be_a Stmt
    expect(p.else_body).to be_a Stmt
  end

  it "is properly formed" do
    expect(p.body.exp.symbol).to eq("y")
    expect(p.else_body.exp.symbol).to eq("z")
  end

  context "with no else stmt" do
    let(:p) { parse_stmt("if (x) y;") }

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

describe WhileStmt do
  let(:p) { parse_stmt("while (x) y;") }

  it "is an WhileStmt" do
    expect(p).to be_a WhileStmt
  end

  it "has the correct attributes" do
    expect(p.condition).to be_a Exp
    expect(p.body).to be_a Stmt
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { while x {y;} }", "expected l_paren, got id")
      expect_syntax_error("int f(void) { while (x {y;} }", "expected r_paren, got l_brace")
      expect_syntax_error("int f(void) { while (x;) {y;} }", "expected r_paren, got semicolon")
    end
  end
end

describe ReturnStmt do
  let(:p) { parse_stmt("return y;") }

  it "is an ReturnStmt" do
    expect(p).to be_a ReturnStmt
  end

  it "has the correct attributes" do
    expect(p.value).to be_a Exp
  end

  context "with no value" do
    let(:p) { parse_stmt("return;") }

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

describe WriteStmt do
  let(:p) { parse_stmt("write(x);") }

  it "is an WriteStmt" do
    expect(p).to be_a WriteStmt
  end

  it "has the correct attributes" do
    expect(p.value).to be_a Exp
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { write(); }", "expected id, got r_paren")
      expect_syntax_error("int f(void) { write(x) }", "expected semicolon, got r_brace")
      expect_syntax_error("int f(void) { write(x;) }", "expected r_paren, got semicolon")
    end
  end
end

describe WritelnStmt do
  let(:p) { parse_stmt("writeln();") }

  it "is an WritelnStmt" do
    expect(p).to be_a WritelnStmt
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(void) { writeln() }", "expected semicolon, got r_brace")
      expect_syntax_error("int f(void) { writeln(x); }", "expected r_paren, got id")
      expect_syntax_error("int f(void) { writeln }", "expected l_paren, got r_brace")
    end
  end
end

########
# Exps #
########

describe AssignmentExp do
  let(:p) { parse_exp("x = y") }

  it "is a AssignmentExp" do
    expect(p).to be_a AssignmentExp
  end

  it "has the correct attributes" do
    expect(p.lhs.symbol).to eq("x")
    expect(p.rhs.symbol).to eq("y")
  end
end

describe RelExp do
  let(:p) { parse_exp("x<=y") }

  it "is a RelExp" do
    expect(p).to be_a RelExp
  end

  it "has the correct attributes" do
    expect(p.op).to eq(:leq)
    expect(p.lhs.symbol).to eq("x")
    expect(p.rhs.symbol).to eq("y")
  end

  it "handles <=, <, ==, !=, >, and >=" do
    expect(parse_exp("x<=y").op).to eq(:leq)
    expect(parse_exp("x<y").op).to eq(:lt)
    expect(parse_exp("x==y").op).to eq(:eq)
    expect(parse_exp("x!=y").op).to eq(:neq)
    expect(parse_exp("x>y").op).to eq(:gt)
    expect(parse_exp("x>=y").op).to eq(:geq)
  end
end

describe AddExp do
  let(:p) { parse_exp("x+y") }

  it "is a AddExp" do
    expect(p).to be_a AddExp
  end

  it "has the correct attributes" do
    expect(p.op).to eq(:plus)
    expect(p.lhs.symbol).to eq("x")
    expect(p.rhs.symbol).to eq("y")
  end

  it "handles + and -" do
    expect(parse_exp("x+y").op).to eq(:plus)
    expect(parse_exp("x-y").op).to eq(:minus)
  end
end

describe MulExp do
  let(:p) { parse_exp("x*y") }

  it "is a MulExp" do
    expect(p).to be_a MulExp
  end

  it "has the correct attributes" do
    expect(p.op).to eq(:asterisk)
    expect(p.lhs.symbol).to eq("x")
    expect(p.rhs.symbol).to eq("y")
  end

  it "handles *, /, and %" do
    expect(parse_exp("x*y").op).to eq(:asterisk)
    expect(parse_exp("x/y").op).to eq(:slash)
    expect(parse_exp("x%y").op).to eq(:percent)
  end
end

describe NegExp do
  let(:p) { parse_exp("-x") }

  it "is a NegExp" do
    expect(p).to be_a NegExp
  end

  it "has the correct attributes" do
    expect(p.exp.symbol).to eq("x")
  end
end

###########
# VarExps #
###########

describe SimpleVarExp do
  let(:p) { parse_exp("x") }

  it "is a SimpleVarExp" do
    expect(p).to be_a SimpleVarExp
  end

  it "has the correct attributes" do
    expect(p.symbol).to eq("x")
  end
end

describe ArrayVarExp do
  let(:p) { parse_exp("x[2]") }

  it "is a ArrayVarExp" do
    expect(p).to be_a ArrayVarExp
  end

  it "has the correct attributes" do
    expect(p.symbol).to eq("x")
    expect(p.index).to eq(2)
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(int x) { [2]x; }", "expected r_brace, got l_bracket")
    end
  end
end

describe PointerVarExp do
  let(:p) { parse_exp("*x") }

  it "is a PointerVarExp" do
    expect(p).to be_a PointerVarExp
  end

  it "has the correct attributes" do
    expect(p.symbol).to eq("x")
  end
end

describe AddrVarExp do
  let(:p) { parse_exp("&x") }

  it "is a AddrVarExp" do
    expect(p).to be_a AddrVarExp
  end

  it "has the correct attributes" do
    expect(p.symbol).to eq("x")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(int x) { x&; }", "expected semicolon, got ampersand")
    end
  end
end

describe AddrArrayVarExp do
  let(:p) { parse_exp("&x[2]") }

  it "is a AddrArrayVarExp" do
    expect(p).to be_a AddrArrayVarExp
  end

  it "has the correct attributes" do
    expect(p.symbol).to eq("x")
    expect(p.index).to eq(2)
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(int x) { x&[2]; }", "expected semicolon, got ampersand")
    end
  end
end

###########
# LitExps #
###########

describe ReadLitExp do
  let(:p) { parse_exp("read()") }

  it "is a ReadLitExp" do
    expect(p).to be_a ReadLitExp
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error("int f(int x) { read) }", "expected l_paren, got r_paren")
      expect_syntax_error("int f(int x) { read( }", "expected r_paren, got r_brace")
    end
  end
end

#####################
# general terminals #
#####################

describe TypeSpecifier do
  let(:p) { parse_declaration("int x;").type_specifier }

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
  let(:p) { parse_declaration("int x;").id }

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
