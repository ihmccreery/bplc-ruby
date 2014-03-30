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

      expect(p.lhs).to be_a SimpleVarExp
      expect(p.lhs.symbol).to eq("x")

      expect(p.rhs).to be_a SimpleVarExp
      expect(p.rhs.symbol).to eq("y")
    end

    it "chains AssignmentExps" do
      p = parse_exp("x = *y = *z")
      q = p.rhs

      expect(p).to be_a AssignmentExp
      expect(q).to be_a AssignmentExp

      expect(p.lhs).to be_a SimpleVarExp
      expect(p.lhs.symbol).to eq("x")

      expect(q.lhs).to be_a PointerVarExp
      expect(q.lhs.symbol).to eq("y")

      expect(q.rhs).to be_a PointerVarExp
      expect(q.rhs.symbol).to eq("z")
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
        expect_syntax_error("int f(void) { #{lhs} = &y }", "lhs not assignable")
      end
    end
  end

  describe "order of operations" do
    it "properly nests AssignmentExps"
    it "properly nests RelExps"
    it "properly nests AddExps and MulExps"
    it "properly nests NegExps"
    it "properly nests VarExps"
    it "raises errors on improperly nested variable expressions"
    it "properly nests LitExps"
    it "properly nests parenthesized Exps"
  end

  it "parses ex1.bpl properly" do
    expect(Parser.new(Scanner.new(File.new(EX1_FNAME))).parse).to be_a Ast
  end
end
