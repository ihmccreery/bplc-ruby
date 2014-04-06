require 'spec_helper'

describe Parser do
  let(:p) { Parser.new(Scanner.new("int x;")) }

  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(p).to be_a Parser
    end
  end

  describe "#parse" do
    it "returns an Ast" do
      expect(p.parse).to be_a Ast
    end

    it "can be called multiple times" do
      expect(p.parse).to eq(p.parse)
    end
  end

  describe "building AssignmentExps" do
    it "properly forms AssignmentExps" do
      p = parse_exp("x = y")

      expect(p).to be_a AssignmentExp
      expect(p.lhs.id).to eq("x")
      expect(p.rhs.id).to eq("y")
    end

    it "chains AssignmentExps" do
      p = parse_exp("x = *y = *z")

      expect(p).to be_a AssignmentExp

      expect(p.lhs.id).to eq("x")

      expect(p.rhs).to be_a AssignmentExp
      expect(p.rhs.lhs.id).to eq("y")
      expect(p.rhs.rhs.id).to eq("z")
    end

    it "handles assignable lhss" do
      ["x", "x[2]", "x[2+z*3]", "x[z]", "*x", "(x)"].each do |lhs|
        p = parse_exp("#{lhs} = y")

        expect(p).to be_a AssignmentExp
        expect(p.lhs).to be_a AssignableVarExp
      end
    end

    it "raises SyntaxErrors on bad lhss" do
      ["&x", "2", "x + z", "2 + x"].each do |lhs|
        expect_syntax_error_on_stmts("#{lhs} = &y;", "lhs not assignable")
      end
    end
  end

  describe "order of operations" do
    it "properly nests AssignmentExps" do
      p = parse_exp("x = y * z")

      expect(p).to be_a AssignmentExp

      expect(p.lhs.id).to eq("x")

      expect(p.rhs.op).to eq(:asterisk)
      expect(p.rhs.lhs.id).to eq("y")
      expect(p.rhs.rhs.id).to eq("z")
    end

    it "properly nests RelExps" do
      p = parse_exp("x * y <= z + w")

      expect(p).to be_a RelExp
      expect(p.op).to eq(:leq)
      expect(p.lhs.op).to eq(:asterisk)
      expect(p.rhs.op).to eq(:plus)
    end

    it "raises errors on chained RelExps" do
      expect_syntax_error_on_stmts("x * y <= z + w > v;", "expected semicolon, got gt")
    end

    it "properly nests AddExps and MulExps" do
      p = parse_exp("x * y + z / w - v")
      minus = p
      plus = minus.lhs
      times = plus.lhs
      divides = plus.rhs

      expect(minus.op).to eq(:minus)
      expect(minus.rhs.id).to eq("v")

      expect(plus.op).to eq(:plus)

      expect(times.op).to eq(:asterisk)
      expect(times.lhs.id).to eq("x")
      expect(times.rhs.id).to eq("y")

      expect(divides.op).to eq(:slash)
      expect(divides.lhs.id).to eq("z")
      expect(divides.rhs.id).to eq("w")
    end

    it "properly nests NegExps" do
      p = parse_exp("x + -y")
      q = parse_exp("x / -y")

      expect(p.rhs).to be_a NegExp
      expect(p.rhs.exp.id).to eq("y")

      expect(q.rhs).to be_a NegExp
      expect(q.rhs.exp.id).to eq("y")
    end

    it "properly nests VarExps" do
      p = parse_exp("&x[y] * *z")

      expect(p.lhs).to be_a AddrArrayVarExp
      expect(p.rhs).to be_a PointerVarExp
    end

    it "raises errors on improperly nested variable expressions" do
      expect_syntax_error_on_stmts("*(x);", "expected id, got l_paren")
      expect_syntax_error_on_stmts("*2+x;", "expected id, got num")
    end

    it "properly nests parenthesized Exps" do
      p = parse_exp("x * ((y + z) / w) - v")
      minus = p
      times = p.lhs
      divides = times.rhs
      plus = divides.lhs

      expect(minus.op).to eq(:minus)
      expect(minus.rhs.id).to eq("v")

      expect(times.op).to eq(:asterisk)
      expect(times.lhs.id).to eq("x")

      expect(divides.op).to eq(:slash)
      expect(divides.rhs.id).to eq("w")

      expect(plus.op).to eq(:plus)
      expect(plus.lhs.id).to eq("y")
      expect(plus.rhs.id).to eq("z")
    end
  end

  it "parses ex1.bpl properly" do
    expect(Parser.new(Scanner.new(File.new(EX1_FNAME))).parse).to be_a Ast
  end
end

###########
# Program #
###########

describe Program do
  let(:p) { parse("int x; void *y; string z[2];") }

  it "is a Program" do
    expect(p).to be_a Program
  end

  # #declarations

  it "has properly formed declarations" do
    expect(p.declarations[0].id).to eq("x")
    expect(p.declarations[1].id).to eq("y")
    expect(p.declarations[2].id).to eq("z")
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
    expect(p.type_specifier).to eq(:int)
    expect(p.id).to eq("x")
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
    expect(p.type_specifier).to eq(:int)
    expect(p.id).to eq("x")
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
    expect(p.type_specifier).to eq(:int)
    expect(p.id).to eq("x")
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
    expect(p.type_specifier).to eq(:int)
    expect(p.id).to eq("f")
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
      expect(p.params[0].id).to eq("x")
      expect(p.params[1].id).to eq("y")
      expect(p.params[2].id).to eq("z")
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
    expect(p.type_specifier).to eq(:int)
    expect(p.id).to eq("x")
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
    expect(p.type_specifier).to eq(:int)
    expect(p.id).to eq("x")
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
    expect(p.type_specifier).to eq(:int)
    expect(p.id).to eq("x")
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
    expect(p.variable_declarations[0].id).to eq("x")
    expect(p.variable_declarations[1].id).to eq("y")
    expect(p.variable_declarations[2].id).to eq("z")
    expect(p.variable_declarations[3]).to be_nil
  end

  it "has properly formed stmts" do
    expect(p.stmts[0].exp.id).to eq("x")
    expect(p.stmts[1].exp.id).to eq("y")
    expect(p.stmts[2].exp.id).to eq("z")
    expect(p.stmts[3]).to be_nil
  end

  it "properly nests" do
    expect(parse_stmt("{{x;}}").stmts[0]).to be_a CompoundStmt
    expect(parse_stmt("{{{x;}}}").stmts[0].stmts[0]).to be_a CompoundStmt
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error_on_stmts("int x void y;", "expected semicolon, got void")
      expect_syntax_error_on_stmts("int x; void y(void) { } string z[2];", "expected semicolon, got l_paren")
      expect_syntax_error_on_stmts("x; void y;", "expected r_brace, got void")
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
    expect(p.body.exp.id).to eq("y")
    expect(p.else_body.exp.id).to eq("z")
  end

  context "with no else stmt" do
    let(:p) { parse_stmt("if (x) y;") }

    it "has no else_body" do
      expect(p.else_body).to be_nil
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error_on_stmts("if x {y;}", "expected l_paren, got id")
      expect_syntax_error_on_stmts("if (x {y;}", "expected r_paren, got l_brace")
      expect_syntax_error_on_stmts("if (x;) {y;}", "expected r_paren, got semicolon")
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
      expect_syntax_error_on_stmts("while x {y;}", "expected l_paren, got id")
      expect_syntax_error_on_stmts("while (x {y;}", "expected r_paren, got l_brace")
      expect_syntax_error_on_stmts("while (x;) {y;}", "expected r_paren, got semicolon")
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
      expect_syntax_error_on_stmts("return", "expected expression, got r_brace")
      expect_syntax_error_on_stmts("return x", "expected semicolon, got r_brace")
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
      expect_syntax_error_on_stmts("write();", "expected expression, got r_paren")
      expect_syntax_error_on_stmts("write(x)", "expected semicolon, got r_brace")
      expect_syntax_error_on_stmts("write(x;)", "expected r_paren, got semicolon")
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
      expect_syntax_error_on_stmts("writeln()", "expected semicolon, got r_brace")
      expect_syntax_error_on_stmts("writeln(x);", "expected r_paren, got id")
      expect_syntax_error_on_stmts("writeln", "expected l_paren, got r_brace")
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
    expect(p.lhs.id).to eq("x")
    expect(p.rhs.id).to eq("y")
  end
end

describe RelExp do
  let(:p) { parse_exp("x<=y") }

  it "is a RelExp" do
    expect(p).to be_a RelExp
  end

  it "has the correct attributes" do
    expect(p.op).to eq(:leq)
    expect(p.lhs.id).to eq("x")
    expect(p.rhs.id).to eq("y")
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
    expect(p.lhs.id).to eq("x")
    expect(p.rhs.id).to eq("y")
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
    expect(p.lhs.id).to eq("x")
    expect(p.rhs.id).to eq("y")
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
    expect(p.exp.id).to eq("x")
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
    expect(p.id).to eq("x")
  end
end

describe ArrayVarExp do
  let(:p) { parse_exp("x[y]") }

  it "is a ArrayVarExp" do
    expect(p).to be_a ArrayVarExp
  end

  it "has the correct attributes" do
    expect(p.id).to eq("x")
    expect(p.index.id).to eq("y")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error_on_stmts("[2]x;", "expected r_brace, got l_bracket")
    end
  end
end

describe PointerVarExp do
  let(:p) { parse_exp("*x") }

  it "is a PointerVarExp" do
    expect(p).to be_a PointerVarExp
  end

  it "has the correct attributes" do
    expect(p.id).to eq("x")
  end
end

describe AddrVarExp do
  let(:p) { parse_exp("&x") }

  it "is a AddrVarExp" do
    expect(p).to be_a AddrVarExp
  end

  it "has the correct attributes" do
    expect(p.id).to eq("x")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error_on_stmts("x&;", "expected semicolon, got ampersand")
    end
  end
end

describe AddrArrayVarExp do
  let(:p) { parse_exp("&x[y]") }

  it "is a AddrArrayVarExp" do
    expect(p).to be_a AddrArrayVarExp
  end

  it "has the correct attributes" do
    expect(p.id).to eq("x")
    expect(p.index.id).to eq("y")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error_on_stmts("x&[2];", "expected semicolon, got ampersand")
    end
  end
end

describe FunCallExp do
  let(:p) { parse_exp("f()") }

  it "is a FunCallExp" do
    expect(p).to be_a FunCallExp
  end

  it "has the correct attributes" do
    expect(p.id).to eq("f")
  end

  # #args

  context "with no args" do
    it "has no args" do
      expect(p.args).to be_a Array
      expect(p.args).to be_empty
    end
  end

  context "with args" do
    let(:p) { parse_exp("f(x, *y + z, 2)") }

    it "has properly formed args" do
      expect(p.args[0].id).to eq("x")
      expect(p.args[1].op).to eq(:plus)
      expect(p.args[2].value).to eq(2)
      expect(p.args[3]).to be_nil
    end
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error_on_stmts("f(;", "expected expression, got semicolon")
      expect_syntax_error_on_stmts("f(x,);", "expected expression, got r_paren")
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

  it "has the correct attributes" do
    expect(p.value).to eq("read")
  end

  context "that is malformed" do
    it "raises SyntaxErrors" do
      expect_syntax_error_on_stmts("read);", "expected l_paren, got r_paren")
      expect_syntax_error_on_stmts("read(;", "expected r_paren, got semicolon")
    end
  end
end

describe NumLitExp do
  let(:p) { parse_exp("2") }

  it "is a NumLitExp" do
    expect(p).to be_a NumLitExp
  end

  it "has the correct attributes" do
    expect(p.value).to eq(2)
  end
end

describe StrLitExp do
  let(:p) { parse_exp('"bob"') }

  it "is a StrLitExp" do
    expect(p).to be_a StrLitExp
  end

  it "has the correct attributes" do
    expect(p.value).to eq("bob")
  end
end
