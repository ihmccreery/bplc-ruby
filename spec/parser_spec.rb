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
